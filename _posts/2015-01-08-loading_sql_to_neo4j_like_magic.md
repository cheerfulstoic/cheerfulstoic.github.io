---
layout: posts
title: Loading SQL to Neo4j Like Magic
categories:
- sql
- neo4j
- neo4apis
- activerecord
- announcements
tags:
- neo4j
- tools
- sql
---

When using neo4j for the first time, most people want to import data from another database to start playing around.  There are a lot of options including [LOAD CSV](http://neo4j.com/docs/stable/query-load-csv.html), [batch-import](https://github.com/jexp/batch-import), and even using [Groovy](http://jexp.de/blog/2014/10/flexible-neo4j-batch-import-with-groovy/).  All of these require some setup and configuration.  I wanted to create the simplest SQL to Neo4j import process possible.

**Enter [neo4apis-activerecord](https://github.com/neo4jrb/neo4apis-activerecord)!**

You may be thinking: "Brian, I'm not a Ruby programmer!  I don't know anything about ActiveRecord".

No worries!  I'll get you there in 2 simple steps: setup and running the command

## Setup

Firstly, if you don't already have neo4j on your computer, find installation instructions for your computer in the [neo4j manual](http://neo4j.com/docs/stable/server-installation.html).

Simply use RubyGems ([RubyGems installation](https://rubygems.org/pages/download)):

    gem install neo4apis-activerecord

Then install the database adapter gem:

    gem install pg

This can be `pg` for PostgreSQL, `mysql2` for MySQL, or `sqlite3` for SQLite

Then create a `config/database.yml` file which looks something like this:

    development:
      adapter: postgresql
      encoding: unicode
      pool: 5
      host: localhost
      port: 5432
      database: your_database_name
      username: james
      password: reallysecret

For examples on how to configure mysql or sqlite, see [this github gist](https://gist.github.com/erichurst/961978) or the [official documentation](http://guides.rubyonrails.org/configuring.html#configuring-a-database)
      
## The Command

Then to import all your data it is as simple as:

    neo4apis activerecord all_tables --identify-model --import-all-associations

Let's break that command down:

 * The `all_tables` command finds all tables in the database and imports them.
 * By default [ActiveRecord table naming conventions](http://guides.rubyonrails.org/active_record_basics.html#convention-over-configuration-in-active-record) will be used.  The `--identify-model` option however will use a looser set of assumptions and configure ActiveRecord models according to the tables it finds in your database.  
 * The `--import-all-associations` option will import [ActiveRecord associations](http://guides.rubyonrails.org/association_basics.html) and create Neo4j relationships from them.  When no existing ActiveRecord models are used, those associations come from using the `--identify-model` option.

Using the above command, I was able to easily and cleanly import the [Chinook Database](http://chinookdatabase.codeplex.com/) (which doesn't follow ActiveRecord table naming) into neo4j:

<a href="/assets/neo4apis-activerecord/chinook_in_neo4j.png" target="_blank">
  <img style="margin: 0.6em; width: 100%" src="/assets/neo4apis-activerecord/chinook_in_neo4j.png">
</a>

## The One Small Catch

Is it perfect?  Close, but not quite!

Taking the Chinook Database as an example, the `Customer` table has a `SupportRepId` column which references the `Employee` table.  There's no way to know from examining the column name what table it is refering to.  These cases require a little bit of configuration on your part.  To do that, you should create a `config/environment.rb` file like this:

    config = YAML.load(File.read('config/database.yml'))['development']

    ActiveRecord::Base.establish_connection(config)

    class Customer < ActiveRecord::Base
      belongs_to :support_rep, foreign_key: 'SupportRepId', class_name: 'Employee'
    end

The `config` and the `establish_connection` lines are there because `neo4apis-activerecord` assumes that this file makes the connection to ActiveRecord and won't try to do it itself.  The `belongs_to` is part of ActiveRecord`s [well documented](http://guides.rubyonrails.org/association_basics.html) and heavily used API.

And of course, for those of you using ActiveRecord already this will all work out of the box!

If you want to get really down and dirty with the Ruby programming, there's even an API for doing your own custom import of your ActiveRecord models.  See the [README](https://github.com/neo4jrb/neo4apis-activerecord) for details!

