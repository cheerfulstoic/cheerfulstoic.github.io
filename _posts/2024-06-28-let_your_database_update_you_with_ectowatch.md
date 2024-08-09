---
title: Let Your Database Update You with EctoWatch
layout: single
date: 2024-06-27 00:00
canonical_url: https://www.erlang-solutions.com/blog/let-your-database-update-you-with-ectowatch/
categories:
- elixir
tags:
- elixir
render_with_liquid: false
---

Elixir allows application developers to create very parallel and very complex systems. Tools like Phoenix PubSub and LiveView thrive on this property of the language, making it very easy to develop functionality that requires continuous updates to users and clients.

But one thing that has often frustrated me is how to cleanly design an application to respond to database record updates.

A typical pattern that I’ve used is to have a dedicated function which makes a database change (e.g `Shipping.insert_event`). This function can contain a post-update step which sends out, for example, a PubSub broadcast. But this relies on the team using that function consistently. If there are other update functions (e.g. `Shipping.insert_delivery`) they also need to do the broadcast.

But the most fool-proof solution would be to have the **database** update the **application** whenever there is a change. Not only would this avoid needing to make sure all update functions send out broadcasts, but it also makes sure that the correct actions are taken whenever some external task or application updates the database directly.

While I knew that PostgreSQL had functionality to inform my applications about updates it always seemed intimidating. So I finally decided to figure out how it worked and to make a library! I’d like to introduce EctoWatch which is my attempt to implement this pattern in the simplest way possible.

# Why Broadcast Database Updates?

Aside from the obvious case of updating LiveViews, there are a number of things you might want to do in response to record changes:

 * redoing a calculation/cache when source information changes
 * sending out emails about a change
 * sending out webhook requests
 * updating a GraphQL subscription

For example, if you insert a new status event for a tracked package, you may want to:

 * update any webpages/applications currently tracking the package
 * send updates about important events (like the package being delivered)
 * recalculate and update the estimated delivery date

# Using EctoWatch

EctoWatch allows you to set up watchers in your application’s supervision tree which can track inserts, updates, and deletes on Ecto schemas which are backed by PostgreSQL tables:

```elixir
{EctoWatch,
  repo: MyApp.Repo,
  pub_sub: MyApp.PubSub,
  watchers: [
    {Accounts.User, :inserted},
    {Accounts.User, :updated},
    {Accounts.User, :deleted},
    {Shipping.Package, :inserted},
    {Shipping.Package, :updated}
  ]}
```

Then processes can subscribe to the broadcasts sent by the watchers:

```elixir
EctoWatch.subscribe({Accounts.User, :inserted})
EctoWatch.subscribe({Accounts.User, :updated})
EctoWatch.subscribe({Accounts.User, :deleted})

EctoWatch.subscribe({Shipping.Package, :inserted})
EctoWatch.subscribe({Shipping.Package, :updated})
```

If your process just needs to get updates about a specific record an ID can be given:

```elixir
EctoWatch.subscribe({Accounts.Package, :updated}, package.id)
```

Then finally the module that implements your process (LiveView, GenServer, etc…) can handle messages about records:

```elixir
# LiveView example
def handle_info(
    {{Accounts.User, :inserted}, %{id: id}},
    socket
  ) do
  user = Accounts.get_user(id)
  socket = stream_insert(socket, :users, user)

  {:noreply, socket}
end

def handle_info(
    {{Accounts.User, :updated}, %{id: id}},
    socket
  ) do
  user = Accounts.get_user(id)
  socket = stream_insert(socket, :users, user)

  {:noreply, socket}
end

def handle_info(
    {{Accounts.User, :deleted},%{id: id}},
    socket
  ) do
  socket = stream_delete_by_dom_id(socket, :songs, "users-#{id}")

  {:noreply, socket}
end
```

You can also define which columns trigger messages on updates as well as which values (in addition to the ID) to send with messages. Definitely check out the [repo’s README](https://github.com/cheerfulstoic/ecto_watch) for more details on how to use EctoWatch!

Conclusion

I believe that [EctoWatch](https://github.com/cheerfulstoic/ecto_watch) can be a powerful new way to simplify how we deal with database changes. Allowing a quick configuration of watchers and using simple message passing with Phoenix PubSub, you can separate the concern of **making a change** from the concern of **what happens as a result** of the change. This allows your code to be more easily readable and refactorable.
