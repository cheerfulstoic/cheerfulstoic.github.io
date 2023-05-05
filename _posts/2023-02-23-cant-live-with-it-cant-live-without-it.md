---
title: Can’t Live `with` It, Can’t Live `with`out It
layout: single
date: 2023-02-23 00:00
canonical_url: https://www.erlang-solutions.com/blog/cant-live-with-it-cant-live-without-it
categories:
- elixir
tags:
- elixir
---



I’d like to share some thoughts about Elixir’s `with` keyword.  `with` is a wonderful tool, but in my experience it is a bit overused.  To use it best, we must understand how it behaves in all cases.  So, let’s briefly cover the basics, starting with pipes in Elixir.

# Pipes are a wonderful abstraction

But like all tools, you should think about when it is best used…

Pipes are **at their best** when you expect your functions to accept and return basic values. But often we don’t have only simple values because we need to deal with **error cases**. For example:

```elixir
region 
|> Module.fetch_companies()
|> Module.fetch_departments()
|> Enum.map(& &1.employee_count)
|> calculate_average()
```

If our `fetch_*` methods return list values there isn’t a problem. But often we fetch data from an external source, which means we introduce the possibility of an `error`. Generally in Elixir this means `{:ok, _}` tuples for success and `{:error, _}` tuples for failure. Using pipes that might become:

```elixir
region
|> Module.fetch_companies()
|> case do
  {:ok, companies} -> Module.fetch_departments(companies)
  {:error, _} = error -> error
end
|> case do
  {:ok, departments} ->
    departments
    |> Enum.map(& &1.employee_count)
    |> calculate_average()
  {:error, _} = error -> error
end
```

Not horrible, but certainly not beautiful. Fortunately, Elixir has `with`!

# `with` is a wonderful abstraction

But like all tools, you should think about when it’s best used…

`with` is **at it’s best** when dealing with the **happy paths** of a set of calls which **all return similar things**. What do I mean by that? Let’s look at what this code might look like using `with`?

```elixir
with {:ok, companies} <- Module.fetch_companies(region),
     {:ok, departments} <- Module.fetch_departments(companies) do
  departments
  |> Enum.map(& &1.employee_count)
  |> calculate_average()
end
```

That’s definitely better!

 * We separated out the parts of our code which might fail (remember that failure is a sign of a side-effect and in functional programming we want to isolate side-effects).
 * The body is only the things that we don’t expect to fail.
 * We don’t need to explicitly deal with the `{:error, _}` cases (in this case `with` will return any clause values which don’t match the pattern before `<-`).

But this is a great example of a **happy path** where the set of calls **all return similar things**. But where are some examples of where we might go wrong with `with`?

## Non-standard failure

What if `Module.fetch_companies` returns `{:error, _}` but `Module.fetch_departments` returns just `:error`? That means your `with` is going to return two different error results. If your `with` is the end of your function call then that complexity is now the caller’s responsibility. You might not think that’s a big deal because we can do this:

```elixir
else
  :error -> {:error, "Error fetching departments"}
```

But this breaks to more-or-less important degrees because:

 * … once you add an `else` clause, you need to take care of *every* non-happy path case (e.g. above we should match the `{:error, _}` returned by `Module.fetch_companies` which we didn’t need to explicitly match before) 😤
 * … if either function is later refactored to return another pattern (e.g. `{:error, _, _}`) – there will be a `WithClauseError` exception (again, because once you add an `else` the fallback behavior of non-matching `<-` patterns doesn’t work) 🤷‍♂️
 * … if `Module.fetch_departments` is later refactored to return `{:error, _}` – we’ll then have an unused handler 🤷‍♂️
 * … if another clause is added which also returns `:error` the message `Error fetching departments` probably won’t be the right error 🙈
 * … if you want to refactor this code later, you need to understand *everything* that the called functions might potentially return, leading to code which is hard to refactor.  If there are just two clauses and we’re just calling simple functions, that’s not as big of a deal.  But with many `with` clauses which call complex functions, it can become a nightmare 🙀

So the first major thing to know when using `with` is what happens **when a clause doesn’t match it’s pattern**:

 * If `else` **is not** specified then the non-matching clause is returned.
 * If `else` **is** specified then the code for the first matching `else` pattern is evaluated. If no `else` pattern matches , a `WithClauseError` is raised.

As [Stratus3D](http://stratus3d.com/blog/2022/06/01/the-problem-with-elixirs-with/) excellently put it: "`with` blocks are the only Elixir construct that implicitly uses the same else clauses to handle return values from different expressions. The lack of a one-to-one correspondence between an expression in the head of the `with` block and the clauses that handle its return values makes it impossible to know when each `else` clause will be used". There are a couple of well known solutions to address this.  One is using "tagged tuples":

```elixir
with {:fetch_companies, {:ok, companies} <- {:fetch_companies, Module.fetch_companies(region)},
     {:fetch_departments, {:ok, departments} <- {:fetch_departments, Module.fetch_departments(companies)},
  departments
  |> Enum.map(& &1.employee_count)
  |> calculate_average()
else
  {:fetch_companies, {:error, reason}} -> ...
  {:fetch_departments, :error} -> ...
end
```

Though tagged tuples should be avoided for various reasons:

 * They make the code a lot more verbose
 * `else` is now being used, so we need to match all patterns that might occur
 * We need to keep the clauses and `else` in sync when adding/removing/modifying clauses, leaving room for bugs.
 * **Most importantly**: the value in an abstraction like `{:ok, _}` / `{:error, _}` tuples is that you can handle things generically without needing to worry about the source

A generally better solution is to create functions which normalize the values matched in the patterns.  This is covered well in [a note in the docs for `with`](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#with/1-beware) and I recommend checking it out.  One addition I would make: in the above case you could leave the `Module.fetch_companies` alone and just surround the `Module.fetch_departments` with a local `fetch_departments` to turn the `:error` into an `{:error, reason}`.

## Non-standard *success*

We can even get unexpected results when `with` succeeds! To start let’s look at the `parse/1` function from the excellent `decimal` library. It’s typespec tells us that it can return `{Decimal.t(), binary()}` or `:error`. If we want to match a decimal value without extra characters, we could have a `with` clause like this:

```elixir
with {:ok, value} <- fetch_value(),
     {decimal, ""} <- Decimal.parse(value) do
  {:ok, decimal}
```

But if `value` is given as `"1.23 "` (with a space at the end), then `Decimal.parse/1` will return `{#Decimal<1.23>, " "}`. Since that doesn’t match our pattern (string with a space vs. an empty string), the body of the `with` will be skipped. If we don’t have an `else` then instead of returning a `{:ok, _}` value, we return `{#Decimal<1.23>, " "}`.

The solution may seem simple: match on `{decimal, _}`! But then we match strings like `"1.23a"` which is what we were trying to avoid. Again, we’re likely better off defining a local `parse_decimal` function which returns `{:ok, _}` or `{:error, _}`.

There are other, similar, situations:

 * `{:ok, %{"key" => value}} <- fetch_data(...)` – the value inside of the `{:ok, _}` tuple may not have a `"key"` key.
 * `[%{id: value}] <- fetch_data(...)` – the list returned may have more or less than one item, or if it does only have one item it may not have the `:id` key
 * `value when length(value) > 2 <- fetch_data(...)` – the `when` might not match. There are two cases where this might surprise you:
   * If `value` is a list, the length of the list being 2 or below will return the list.
   * If `value` is a string, `length` isn’t a valid function (you’d probably want `byte_size`). Instead of an exception, the guard simply fails and the pattern doesn’t match.

The problem in all of these cases is that the intermediate value from `fetch_data` will be returned, not what the body of the `with` would return. This means that our `with` returns "uneven" results. We can handle these cases in the `else`, but again, once we introduce `else` we need to take care of all potential cases.

I might even go to the extent of recommending that you don’t define `with` clause patterns which are at all deep in their pattern matching unless you are very sure the **success case** will be able to match the **whole pattern**.  One example where you might take a risk is when matching `%MyStruct{key: value} <- …` where you **know** that a `MyStruct` value is going to be returned and you know that `key` is one of the keys defined for the struct. No matter the case, dialyzer is one tool to gain confidence that you will be able to match on the pattern (at least for your own code or libraries which also use dialyzer).

One of the simplest and most standard ways to avoid these issues is to make sure the functions that you are calling return `{:ok, variable}` or `{:error, reason}` tuples. Then `with` can fall through cleanly (*definitely* check out Chris Keathley’s discussion of "Avoid else in with blocks" in his post ["Good and Bad Elixir"](https://keathley.io/blog/good-and-bad-elixir.html)).

With all that said, I recommend using `with` statements whenever you can! Just make sure that you think about fallback cases that might happen. Even better: write tests to cover all of your potential cases! If you can strike a balance and use `with` carefully, your code can be both cleaner **and** more reliable.


