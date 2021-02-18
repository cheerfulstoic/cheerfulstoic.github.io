---
title: Making Master Data Management Fun with Neo4j - Part 1
layout: posts
date: 2015-02-16 08:00

tags:
- neo4j
- master-data-management
- clojure
- stackoverflow
---

Joining multiple disparate data-sources, commonly dubbed [Master Data Management](http://en.wikipedia.org/wiki/Master_data_management) (MDM), is usually not a fun exercise. I would like to show you how to use a graph database (Neo4j) and an interesting dataset (developer-oriented collaboration sites) to make MDM an enjoyable experience. This approach will allow you to quickly and sensibly merge data from different sources into a consistent picture and query across the data efficiently to answer your most pressing questions.

To start I’ll just be importing one data source: StackOverflow questions tagged with `neo4j` and their answers. In future blog posts I will discuss how to integrate other data sources into a single graph database to provide a richer view of the world of Neo4j developers' online social interactions.

I've created a [GraphGist](http://graphgist.neo4j.com/#!/gists/7e8ec61f9104017430af) to explore questions about the imported data, but in this post I’d like to briefly discuss the process of getting data from StackOverflow into Neo4j.

## The model

<img style="float: right; width: 350px; margin: 0.6em;" src="https://raw.githubusercontent.com/cheerfulstoic/stackoverflow-graphgist/master/model.png">

Modeling the StackOverflow data was mostly straightforward. I decided to stick with questions, answers, tags, and users for now. If I wanted to get more complex I could have included comments and edits, but a lot can be shown without them.

Also, at first I had prefixed all labels with `StackOverflow` (so that for example question nodes had the label `StackOverflowQuestion`). This was an attempt to avoid conflict with later imports where I might want to use the same label (`User` is a prime example). After some feedback, though, I gave all nodes a `StackOverflow` label in addition to their specific labels. This is a simple but powerful way to model different data sources.

## The import code

I decided to try out Clojure ([GitHub repo](https://github.com/cheerfulstoic/stackoverflow-graphgist)) to further the demonstration of using Neo4j as a central location for collecting and analyzing different sources of data together.  Using my script I was able to import all 6,571 neo4j questions along with associated tags, answers, and users.

[The code](https://github.com/cheerfulstoic/stackoverflow-graphgist/blob/master/src/stackoverflow_graphgist/core.clj) may be easy to read for those used to a programming language that is like [lego made out of lego](https://twitter.com/frankdegroot/status/543341971943989248) or [wearing your underwear on the outside](https://twitter.com/StarryKari/status/565713195143532545), but for everybody else I'll explain it.

The actual import revolves around a function called `merge-props`:

    (defn merge-props [label props merge-prop neo4j-conn]
      (if-not (nil? (props merge-prop))
        (cypher/tquery
          neo4j-conn
          (str "MERGE (node:`" label "` {" merge-prop ": {props}." merge-prop
            "}) SET node:StackOverflow, node = {props} RETURN node") {"props" props})
        )
    )

The idea behind `merge-props` is to use Neo4j's [`MERGE`](http://neo4j.com/docs/stable/query-merge.html) to import an object if it doesn't already exist.  You specify a Neo4j label, a set of property/value pairs, and the property for `MERGE` to check.  For a `User`, this might be called like this:

    (merge-props
      "User"
      {"user_id" "12345", "display_name" "Brian Underwood", "reputation" "1791"}
      "user_id"
      neo4j-conn)

And it would generate the following cypher:

    MERGE (node:`User` {user_id: {props}.user_id})
      SET node:StackOverflow, node = {props}
      RETURN node

The main import functions are `import-question`, `import-tag`, `import-answer`, and `import-user` which are responsible for defining the properties to import and for calling other `import-` functions to `MERGE` dependent relationships.  All of that is then wrapped in a loop to import pages of questions until the API returns `false` for `has_more`.

To speed up processing I considered taking advantage of Clojure's natural ability to execute in parallel as well as using Neo4j's [transactional endpoints](http://neo4j.com/docs/stable/rest-api-transactional.html) to batch cypher statements.  However, since all of the questions imported within about 20 minutes I'm happy for now.

## Next time

This post was just an introduction to the idea of Master Data Management in Neo4j.  In the next post I'll bring in another data source, show how I linked the data together, and demonstrate the sort of bigger picture that one can get from this approach.

**UPDATE: [Part 2]({% post_url 2015-02-22-making_master_data_management_fun_with_neo4j_-_part_2 %}) now available**
