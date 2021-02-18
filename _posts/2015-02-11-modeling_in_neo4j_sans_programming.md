---
title: Modeling in Neo4j Sans Programming
layout: posts
date: 2015-02-04 18:09
categories:
- ruby
- rails
- neo4j
- announcements
tags:
- neo4j
- tools
- neo4j.rb
---

<a href="http://www.xkcd.com/917/" target="_blank">
  <img style="float: right; width: 450px; margin: 0.6em;" src="/assets/neo4j-meta_model/hofstadter.png">
</a>

I have a bit of a problem.

Sometimes I have a hard time implementing a specific solution to a problem.  Sometimes I think: *"If I just took a step back, I could create a tool which anybody could use to do anything!"*  If I do it right, nobody will ever need to write a piece of software again!

I'm not there yet, but I'd like to announce a big step on my journey: **[neo4j-meta_model](https://github.com/neo4jrb/neo4j-meta_model)**

`neo4j-meta_model` is a tool for managing Neo4j [graph databases](http://neo4j.com/developer/graph-database/) in [Ruby on Rails](http://rubyonrails.org/) apps.  A big goal of the project is to create something which, while a very powerful tool for programmers, can also be used by **non-programmers**.  This is such an important goal that I created a Rails app (creatively named [neo4j-meta_model-app](https://github.com/neo4jrb/neo4j-meta_model-app)) which you need only to download, install, and run to set up a user-friendly interface for working with Neo4j databases.

## What does it do?

`neo4j-meta_model` provides a web-based user interface for doing two things:

 * Defining the structure of your data in Neo4j
 * Browsing and managing your data

### Defining the structure of your data

An administrative section is provided to allow users to define models and associations.  Since the [neo4j Ruby library](https://github.com/neo4jrb/neo4j)'s [ActiveNode](https://github.com/neo4jrb/neo4j/wiki/Neo4j%3A%3AActiveNode) is used behind the scenes, models and associations correspond to Neo4j's nodes and relationships.  A quick primer:

#### Models

Models correspond to Neo4j [Labels](http://neo4j.com/docs/stable/graphdb-neo4j-labels.html) which define entity tyes like `User`, `Product`, etc...  For a model, you can define

 * Properties (such as `name` or `price`) with which we are concerned
 * Data validations and other business logic
 * [Inheritance](https://github.com/neo4jrb/neo4j/wiki/Neo4j.rb-v3-Inheritance) for when we want one model to have mostly the same properties as another

Currently `neo4j-meta_model` supports properties and inheritance but not validation or custom business logic.

#### Associations

Associations specify which nodes are related to a node under consideration.  For example, if there are `Person` and `Article` models with a `WROTE_ARTICLE` relationship between them, one might define an `articles` association for the `Person` model and an `author` association for the `Article` model.  In `neo4j-meta_model`, both associations are always defined at the same time.


<img style="float: right; margin: 0.6em;" src="/assets/neo4j-meta_model/association_diagram.png">

To the right is the diagram which is shown when creating associations.  The diagram represents a pair of associations and changes in real time as the pair of associations is defined.  In this case it indicates a one-to-many relationship where:

 * the `Song` model has one `artist`
 * the `Person` model has many `songs`
 * there is a `WRITTEN_BY` relationship type in Neo4j which goes from Songs to People and it is used to find nodes for the associations


### Browsing and managing your data

<div style="float: right; width: 350px; margin: 0.6em">
  <a href="/assets/neo4j-meta_model/gist_view.png" target="_blank">
    <img style="float: right; width: 350px; margin: 0" src="/assets/neo4j-meta_model/gist_view.png">
  </a>
  <em style="font-size: 0.8em">A `Gist` record with associated `UseCase` and `Domain` records</em>
</div>

Once the database model has been established users can browse and edit the data itself.  A simple [CRUD](http://en.wikipedia.org/wiki/Create,_read,_update_and_delete) interface is provided for records of the defined models.  When a record is found all other records known via associations are displayed (see screenshot to the right which shows a `Gist` and it's associated `UseCases` and `Domains`).  When editing a record properties can be edited but associations can also be selected to create/destroy relationships.  For `has one` relationships this is done via a simple drop-down, but for `has many` relationships an add/remove list interface is provided.

## Try it!

I've deployed an instance of [neo4j-meta_model-app](https://github.com/neo4jrb/neo4j-meta_model-app) at [http://neo4j-meta-model-app.herokuapp.com/](http://neo4j-meta-model-app.herokuapp.com/) so that you can play around with it.  Let me know what you think and if you have any issues feel free to report them on the [project page](https://github.com/neo4jrb/neo4j-meta_model)!

## The Technical Stuff

`neo4j-meta_model` is a [Rails engine](http://guides.rubyonrails.org/engines.html), which means it is a Rails application inside a Rails application.  It must be given a route inside the host rails application to provide the user interface for the Neo4j database.  In the case of [neo4j-meta_model-app](https://github.com/neo4jrb/neo4j-meta_model-app), this is simply the root ('/') route.

The admin side of the engine is built as an [Ember.js](http://emberjs.com/) application, while the CRUD record management side is built with standard Rails server-side rendering (with a touch of [Rivets.js](http://rivetsjs.com/) and [Backbone.js](http://backbonejs.org/) where needed)

## The Future

The current version of this project is a bare bones starting point.  Some things that I'd like to see in the near future:

 * Search, filtering, and pagination when browsing records
 * Permissions for the admin side as well as individual models
 * Visual data browsing (see [Graph Visualization and Neo4j](http://maxdemarzi.com/2012/01/11/graph-visualization-and-neo4j/) and [The Last Mile](http://maxdemarzi.com/2013/07/03/the-last-mile/))
 * Tools for running graph analytics metrics

