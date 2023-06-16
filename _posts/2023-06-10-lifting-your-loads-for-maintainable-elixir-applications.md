---
title: Lifting Your Loads for Maintainable Elixir Applications
layout: single
date: 2023-06-15 00:00
canonical_url: https://www.erlang-solutions.com/blog/lifting-your-loads-for-maintainable-elixir-applications/
categories:
- elixir
tags:
- elixir
---

(This post was originally created for the Erlang Solutions blog.  The original can be found [here](https://www.erlang-solutions.com/blog/lifting-your-loads-for-maintainable-elixir-applications/))

This post will discuss one particular aspect of designing Elixir applications using the Ecto library: separating data loading from using the data which is loaded.  I will lay out the situations and present some solutions, including a new library called [ecto_require_associations](https://github.com/cheerfulstoic/ecto_require_associations).

Applications will differ, but let's look at [this example](https://github.com/plausible/analytics/blob/7d935b79bf516deaa0175ffe1b07784a8c72f3c2/lib/plausible/billing/plans.ex#LL39C1-L71C1) from the Plausible Analytics repo[1]:

```elixir
def plans_for(user) do
  user = Repo.preload(user, :subscription)
  # … other code …

  raw_plans =
  cond do
    contains?(v1_plans, user.subscription) ->
      v1_plans

    contains?(v2_plans, user.subscription) ->
      v2_plans

    contains?(v3_plans, user.subscription) ->
      v3_plans

    contains?(sandbox_plans, user.subscription) ->
      sandbox_plans

    true ->
      # … other code …
  end

  # … other code …
end


```

Here the `subscription` association is preloaded for the given user, which is then immediately used as part of the logic of `plans_for/1`.  I'd like to try to convince you that in cases like this, it would be better to "lift" that loading of data out of the function.

Let's start with a brief background on Ecto:

# The Ecto Library

Ecto was uses the "repository pattern". With Elixir being a language drawing a lot of people from the Ruby community, this was a departure from the "active record pattern" used in the "ActiveRecord" library made popular by Ruby on Rails. This pattern uses classes to fetch data (e.g. `User.find(id)`) and object methods to update data (e.g. `user.save`). Since "encapsulation" is a fundamental aspect of object-oriented programming, it seems logical at first to hide away the database access in this way. Many found, however, that while encapsulation of business logic makes sense, also encapsulating the database logic often led to complexity when trying to control the lifecycle of a record.

The repository pattern – as implemented by Ecto – requires explicit use of a "Repo" module for all queries to and from the database. With this separation of database access, `Ecto.Schema` modules can focus on defining application data and `Ecto.Changeset` module focus on validating and transforming application data.

This separation is made very clear in Ecto's `README` which states: "Ecto is also commonly used to map data from any source into Elixir structs, whether they are backed by a database or not."

Even if you're fairly familiar with Ecto, I highly recommend watching Darin Wilson's ["Thinking in Ecto"](https://www.youtube.com/watch?app=desktop&v=YQxopjai0CU) presentation for a really good overview of the hows and whys of Ecto.

Ecto's separation of a repository layer makes even more sense in the context of functional programming.  For context in discussing solutions to the problem presented above, it's important to understand a bit about functional programming.

One big idea in functional programming (or specifically ["purely functional programming"](https://en.wikipedia.org/wiki/Purely_functional_programming)) is the notion of minimising and isolating side-effects. A function with side-effects is one which interacts with some global state such as memory, a file, or a database. Side-effects are commonly thought of as changing global state, but *reading* global state means that the output of the function could change depending on when it's run.

What benefits does avoiding side-effects give us?

 * Separating database access from operations on data is a great separation of concerns which can lead to more modular and therefore more maintainable code.
 * Defining a function where the output depends completely on the input makes the function easier to understand and therefore easier to use and maintain.
 * Automated tests for functions without side-effects can be much simpler because you don't need to setup external state.

# A Solution

A first approach to lifting the `Repo.preload` in the example above would be to do just that. That would suddenly make the function "pure" and dependent only on the caller passing in a value for the user's `subscription` field. The problem comes when the person writing code which calls `plans_for/1` forgets to preload. Since Ecto defaults associations on schema structs to have an `%Ecto.Association.NotLoaded{}` value, this approach would lead to a confusing error message like:

```
(KeyError) key :paddle_plan_id not found in:
#Ecto.Association. NotLoaded association :subscription is not loaded>
```

This is because the [`contains/2`](https://github.com/plausible/analytics/blob/7d935b79bf516deaa0175ffe1b07784a8c72f3c2/lib/plausible/billing/plans.ex#L139-L146) function accesses `subscription.paddle_plan_id`.

So, it would probably be better to explicitly look to see if the subscription is loaded. We could do this with pattern matching in an additional function definition:

```
def plans_for(%{subscription: %Ecto.Association.NotLoaded{}}), do: raise "Expected subscription to be preloaded"
```

Or, if we want to avoid referencing the `Ecto.Association.NotLoaded` module in your application's code, there's even a function Ecto provides to allow you to check at runtime:

```
def plans_for(user) do
  if(!Ecto.assoc_loaded?(user.subscription) do
    raise "Expected subscription to be preloaded")
  end

  # …
```

This can get repetitive and potentially error-prone if you have a larger set of associations that you would like your function to depend on. I've created a small library called [`ecto_require_associations`](https://github.com/cheerfulstoic/require_associations_test) to take care of the details for you. If you'd like to load multiple associations you can use the same syntax used by Ecto's `preload` function:

```
def plans_for(user) do
  EctoRequireAssociations.ensure!(user, [:subscriptions, site_memberships: :site])

  # …
```


The above call would check:

 * If the `subscriptions` association has been loaded for the user
 * If the `site_memberships` association has been loaded for the user
 * If the `site` association has been loaded on each site membership

If, for example, one or more of the `site` memberships hasn't been loaded then an exception is raised like:

```
(ArgumentError) Expected association to be set: `site_memberships.site`
```

It can even work on a list of records given to it, just like `Repo.preload`.

# Going Too Far The Other Way

Hopefully I've convinced you that the above approach can be helpful for creating more maintainable code. At the same time, I want to caution against another potential problem on the "other side". Let's say we have a function to get a user like this:

```
defmodule MyApp.Users do
  def get_user(id) do
    MyApp.Repo.get(id)
    |> MyApp.Repo.preload([:api_keys, :subscriptions, site_memberships: :site])
  end

  def get_admins do
    from(user in User, where: user.is_admin)
    |> MyApp.Repo.all()
    |> MyApp.Repo.preload([:api_keys, :subscriptions, site_memberships: :site])
  end
```

When loading data to support pure functions, it could be tempting to load everything that might be needed by all functions which have a user argument. The risk then becomes one of loading too much data. Functions like `get_user` and `get_admins` are likely to be used all over your application, and generally you won't need all of the associations loaded. This is a scaling problem that isn't a problem until your application gets popular.One common pattern to solve this is to simply have a `preloads` argument:

```
defmodule MyApp.Users do
    def get_user(id, preloads \\ []) do
        MyApp.Repo.get(id)
        |> MyApp.Repo.preload(preloads)
    end

    def get_admins(preloads \\ []) do
        from(user in User, where: user.is_admin)
        |> MyApp.Repo.all()
        |> MyApp.Repo.preload(preloads)
    end
end

# Usage
MyApp.Users.get_admins([:api_keys])
```

This does solve the problem and allows you to load associations only where you need them. I would say, however, that this code falls into the same trap as the Active Record library by intertwining database and application logic.

The Ecto library, your schemas, and your associations aren't secrets.  You absolutely should encapsulate things like your complex query logic, the details for how you calculate numbers, or the decisions you make based on data. But it's fine to ask Ecto to preload the associations and let your query functions just do querying. This can give you a clean separation of concerns:

```
defmodule MyApp.Users do
  def get_user(id), do: MyApp.Repo.get(id)

  def get_admins do
    from(user in User, where: user.is_admin)
    |> MyApp.Repo.all()
  end
end

# Usage:
MyApp.Users.get_admins()
|> MyApp.Repo.preload(:api_keys)
```

That said, if you have associations you need for specific functions, you may want to create functions which can preload without the caller knowing the details. This saves repetition and helps clarify overlapping dependencies:


```
defmodule MyApp.Users do
  # You can call `preload_for_access_check(user)` to load the required data
  def can_access?(user, resource) do
    EctoRequireAssociations.ensure!(user, [:roles, :permissions])

    # …
  end

  def preload_for_access_check(user) do
    MyApp.Repo.preload(user, [:roles, :permissions])
  end

  def preload_for_something_else(user) do
    MyApp.Repo.preload(user, [:roles, :regions])
  end
end
```

Remember that `Repo.preload` won't load data if it's already been set on the struct unless you specify `force: true`!

So if we shouldn't put our data loading along with our business logic or with our queries, where should it go? The answer to this is fuzzier, but it makes sense to think about what parts of your code should exist as "coordination" points. Let's talk about some good options:

## Phoenix Controllers, Channels, LiveViews, and Email handlers

Controllers, LiveViews, and email handlers are all places where we render a template, and generally we are loading some sort of data to be able to do that. Channels and LiveViews are dealing with events which are also often a place where we'll need to load data to provide some sort of update to a client. In both cases, this is the place where we know what data will be needed, so it makes sense to keep the responsibility of choosing what data to load in this code.

## Absinthe Resolvers

Absinthe is a library for implementing a GraphQL API. Not only will you need to preload data, sometimes you may use the [Dataloader](https://github.com/absinthe-graphql/dataloader) to efficiently load data outside of manual preloading. This highlights how loading of associated data is a separate concern from evaluating it.

## Scripts and Tasks

Scripts and `mix` tasks are another place for coordinating loading and logic. This code might even be one-off and/or short-lived, so it may not even make sense to define functions inside of context modules. Depending on the importance and lifecycle of a script/task it could be that none of the above discussion is applicable.

## High Level Context Functions

The discussion above suggests pushing loading logic up and out of [context](https://hexdocs.pm/phoenix/contexts.html)-type modules. However, if you have a high-level function which is an entrypoint into some complex code, then it may make sense to coordinate your loading and logic there. This is especially true if the function is used from multiple places in your application.

# Conclusion

It seems like a small detail, but making more functions purely functional and isolating your database access can have compounding effects on the maintainability of your code. This can be especially true when the codebase is maintained by more than one person, making it easier for everybody to change the code without worrying about side-effects. Try it out and see!

[1]: Please don't see this as me picking on the Plausible Analytics folks in any way. I think that their project is great and the fact that they open-sourced it makes it a great resource for real-world examples like this one!

