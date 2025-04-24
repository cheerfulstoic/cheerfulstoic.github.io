---
title: "Reduce, Reuse... Refactor: Clearer Elixir with the Enum Module"
layout: single
date: 2025-04-24 00:00
categories:
- elixir
tags:
- elixir
render_with_liquid: false
---

> "When an operation cannot be expressed by any of the functions in the Enum module, developers will most likely resort to reduce/3."
>
> From the docs for Enum.reduce/3

In many Elixir applications, I find `Enum.reduce` is used frequently. `Enum.reduce` can do anything, but that doesn't mean it should. In many cases, other `Enum` functions are more readable, practically as fast, and easier to refactor.

I would also like to discuss situations that **are** a good fit for `Enum.reduce` and also introduce you to a custom `credo` check I've created, which can help you identify places where `Enum.reduce` could be replaced with a simpler option.

## Readability

Here are a few common reduce patterns—and their simpler alternatives.  For example, here's something I see quite often:

```elixir
Enum.reduce(numbers, [], fn i, result -> [i * 10 | result] end)
|> Enum.reverse()
```

This is a situation that the `Enum.map` function was designed for:

```elixir
Enum.map(numbers, & &1 * 10)
```

Perhaps you know about `Enum.map`, but you might see a call to `reduce` like this:

```elixir
Enum.reduce(numbers, 0, fn number, result -> (number * 2) + result end)
```

Let me introduce you to `Enum.sum_by`!

```elixir
Enum.sum_by(numbers, & &1 * 2)
```

Let’s look at something a bit more complex:

```elixir
Enum.reduce(numbers, [], fn item, acc ->
  if rem(item, 2) == 0 do
    [item * 2 | acc]
  else
    acc
  end
end)
|> Enum.reverse()
```

This is a perfect case for piping together two `Enum` functions:

```elixir
numbers
|> Enum.filter(& rem(&1, 2) == 0)
|> Enum.map(& &1 * 2)
```

Another option for this case could even be to use `Enum.flat_map`:

```elixir
Enum.flat_map(numbers, fn number ->
  if rem(number, 2) == 0 do
    [number * 2]
  else
    []
  end
end)
```

This is a decent option, but while this achieves the purpose of both filtering and mapping in a single pass, it may not be as intuitive for everybody.

Lastly, say you see something like this and think that it would be difficult to improve:

```elixir
Enum.reduce(invoices, {[], []}, fn invoice, result ->
  Enum.reduce(invoice.items, result, fn item, {no_tax, with_tax} ->
    if Invoices.Items.taxable?(item) do
      tax = tax_for_value(item.amount, item.product_type)
      item = Map.put(item, :tax, tax)

      if Decimal.equal?(tax, 0) do
        {no_tax ++ [item], with_tax}
      else
        {no_tax, with_tax ++ [item]}
      end
    else
      {no_tax, with_tax}
    end
  end)
end)
```

But this is just the same:

```elixir
invoices
|> Enum.flat_map(& &1.items)
|> Enum.filter(&Invoices.Items.taxable?/1)
|> Enum.map(& Map.put(&1, :tax, tax_for_value(&1.amount, &1.product_type)))
|> Enum.split_with(& Decimal.equal?(&1.tax, 0))
```

Aside from improving readability, splitting code out into pipes like this can make it easier to see the different parts of your logic.  Especially once you've created more than a few lines of pipes, it becomes easier to see how I can pull out different pieces when refactoring.  In the above, for example, you might decide to create a `calculate_item_taxes` function which takes a list of items and performs the logic of the `Enum.map` line.

## Performance

You may have already thought of a counterpoint: when you pipe functions together you end up creating new lists, which means more work to be done as well as more memory usage (which means more garbage collection).  This is absolutely true, and you should be thinking about this!

But 99% of the time I find that the amount of data I'm working with shows a negligible performance difference between these approaches. If you find that your code is slow because of the amount of data that you need to process, you might try using the `Stream` module — it has many of the same functions as Enum, but works lazily.  If that doesn't work, then by all means create a `reduce` (and maybe put it into a well-named function)!

As Joe Armstrong said:

> "Make it work, then make it beautiful, then if you really, really have to, make it fast."

For some information about benchmarks that I've run to understand this better, see [this analysis and discussion](https://github.com/cheerfulstoic/credo_unnecessary_reduce/wiki/Performance).

## Good Opportunities for `Enum.reduce`

Aside from occasional performance reasons, `Enum.reduce` can often be the simplest solution when you want to:

* Build a data structure based on an enumerable (like [a fragment in an Ecto query](https://github.com/plausible/analytics/blob/master/lib/plausible/stats/sql/where_builder.ex#L23-L27))
* Transform a data structure (like [replacing variable references in a string](https://github.com/plausible/analytics/blob/master/lib/plausible/segments/segments.ex#L365-L368))

## Find Cases in Your Own Code With `credo_unnecessary_reduce`

If you’re sold on writing clearer code (and I hope you are), I built a Credo check to help spot where reduce can be swapped for something simpler.

You can drop it into your project and start catching these anti-patterns automatically.

<https://github.com/cheerfulstoic/credo_unnecessary_reduce>

Simply add it to your `mix.exs` file:

    {:credo_unnecessary_reduce, "~> 0.1.0"}

...and then enable it in your `.credo.exs` file:

    {CredounnecessaryReduce.Check, []}
