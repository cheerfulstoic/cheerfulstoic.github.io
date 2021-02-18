---
title: "GraphStarter: Getting a Neo4j Rails app up and running quickly"
layout: posts
date: 2015-10-27 09:55 UTC
hidden: true

tags:
- neo4j
- neo4j.rb
- ruby gem
---

For a while now I've been building various [Neo4j.rb](http://neo4jrb.io/) educational resources using the example of an [asset portal](http://github.com/neo4j-examples/asset_portal).  There has been:

 * a screencast series (the [first half](http://neo4j.com/blog/create-a-ruby-on-rails-app-with-neo4j-screencast-series/) and the [second half](http://neo4j.com/blog/advanced-ruby-on-rails-with-neo4j/))
 * a [SitePoint article](http://www.sitepoint.com/why-you-should-use-neo4j-in-your-next-ruby-app/) on building recommendations and access control
 * a [webinar](https://www.youtube.com/watch?v=dlRL-3XZvHs) on advanced access control
 * a [introduction course](http://neo4j.com/developer/ruby-course/) for Neo4j using Ruby

As part of this process I've wanted to use what I've been building and allow anybody to easily create a UI for their own assets in Rails.  I'm pleased to say that I've got a good start with the [graph_starter](https://github.com/neo4j-examples/graph_starter) gem.

The `graph_starter` gem is a Rails engine, which means that it can be placed within a Rails application.  The goal is to be able to quickly set up a basic UI for your entities, but to also be able to override it when you want to provide custom logic.

Setting up a `graph_starter` application is as simple as the following steps:

## Installation

Using `graph_starter` is easy!

First create a Rails application if you don't already have one:

    rails new application_name

Include the `graph_starter` gem (it will include the Neo4j.rb gems for you):

    # Gemfile

    gem 'graph_starter'

Mount the engine:

    # config/routes.rb

    mount GraphStarter::Engine => '/'

Create some asset models:

    # app/models/product.rb

    class Product < GraphStarter::Asset
      # `title` property is added automatically

      property :name
      property :description
      property :price, type: Integer

      has_images

      has_one :in, :vendor, type: :SELLS_PRODUCT
    end

    # app/models/vendor.rb

    class Vendor < GraphStarter::Asset
      property :brand_name
      property :code

      name_property :brand_name

      has_many :out, :products, origin: :vendor
    end

These models are simply Neo4j.rb `ActiveNode` models so you can refer to the [Neo4j.rb documentation](http://neo4jrb.readthedocs.org/) to define them.  They do have some special methods, however, which let you control how GraphStarter works.  In the above `Product` model, for example, `has_images` has been called to indicate that products have images which defines a separate `Image` model along with the neccessary association.  See the [graph_starter README](https://github.com/neo4j-examples/graph_starter#models) for documentation on how to configure aspects of your models.

Once that framework is in place you can define a way to import data, if desired.  For this I would suggest making a rake task:

    # lib/tasks/store.rake

    namespace :store do
      task :import do
        CSV.open(File.read('vendors.csv')).each do |row|
          Vendor.create(name: row['brand_name'],
                        code: row['code'])
        end

        CSV.open(File.read('products.csv')).each do |row|
          product = Product.create(name: row['name'],
                                   description: row['description'],
                                   price: row['price'].to_i)

          product.vendor = Vendor.find_by(code: row['vendor_code'])
        end
      end
    end

And that's all!

When everything is in place you can simply start up your Rails server (by running `rails server`) and you get a UI which looks like this example site I made using data from the [Natural History Museum](http://www.nhm.ac.uk/) in London:

<img style="width: 100%; display: block; margin: 0 auto" src="/assets/graph_starter/assets_index.png">

<img style="width: 100%; display: block; margin: 0 auto" src="/assets/graph_starter/assets_show.png">

You can [browse the app](http://nhm-portal.herokuapp.com/) on Heroku and [checkout the repository](https://github.com/neo4j-examples/nhm_asset_portal) on Github

I'll be working on a new project to create a [GraphGist portal](http://graphgist.neo4j.com/) based on the `graph_starter` gem so I plan to continue improving it!
