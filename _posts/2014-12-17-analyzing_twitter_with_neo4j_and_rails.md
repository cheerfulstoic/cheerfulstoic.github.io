---
layout: posts
title: Analyzing Twitter with Neo4j and Rails
categories:
- ruby
- rails
- neo4j
tags:
- neo4j
excerpt_separator: <!--more-->
---

<img style="float: right; width: 450px; margin: 0.6em;" src="/assets/twitter_analytics/tag_view.png">

Having recently become interested in making it easy to pull data from Twitter with [neo4apis-twitter]({% post_url 2014-11-03-neo4apis %}) I also decided that I wanted to be able to visualize and browse the data that I've downloaded.  Therefore I created the [twitter_analytics](https://github.com/neo4jrb/twitter_analytics) rails app!

<!--more-->

### What cool stuff does this do?

#### Dashboard

My first goal was to create a dashboard.  I had run across Keen IO's [bootstrap dashboard templates](https://github.com/keen/dashboards) (on [twitter](https://twitter.com/keen_io/status/529767639220908033), of course) and decided this would be a great chance to use one.  I liked the [split-centered](https://github.com/keen/dashboards/tree/gh-pages/layouts/split-centered) template the best and, after converting it to [slim](http://slim-lang.com/), I built a nice DRY way to dump whatever [chartkick](https://github.com/ankane/chartkick.js) charts I wanted to in each panel (see [the source](https://github.com/neo4jrb/twitter_analytics/blob/master/app/assets/javascripts/dashboard.js.coffee))

#### Tweet cards

I used the twitter API to dump [tweet card](https://dev.twitter.com/cards/overview) HTML into my views which make tweets visually interesting.  I cache the results in the database because the API is relatively slow and it helps avoid hitting API query limits.  Also as a bonus I noticed that tweets with included images seem to always go to the "Top Tweets" metrics, so that give me some insight as well.

<img style="float: right; width: 350px; margin: 0.6em;" src="/assets/twitter_analytics/hashtag_graph_visualization.png">

#### Hashtag graph visualization

On the hashtag detail page you can also see a graph visualization (using [sigma.js](http://sigmajs.org/)) of the local network of related hashtags up to two hops away.  In this case "related" means that the hashtags are both used in at least one tweet.  The current hashtag is shown as a large white circle, the directly adjacent hashtags are medium sized green circles, and the hastags two hops away are small red circles.  Also the thickness of the line between two hashtags represents how many times those hashtags were used together.

#### User summary

When you browse to the user detail page you can see all of the user's properties from the API.  This overview also has graphs to show top hashtags and original/retweet ratios for the user's tweets.


### How to use it

No doubt this gotten you excited to analyze some tweets!  All you need to do is:

 * Clone the [github repository](https://github.com/neo4jrb/twitter_analytics/)
 * Download and start the neo4j server (see the [README](https://github.com/neo4jrb/twitter_analytics/blob/master/README.md))
 * Create a `config/twitter.yml` file (see [config/twitter.yml.example](https://github.com/neo4jrb/twitter_analytics/blob/master/config/twitter.yml.example))
 * Import data from twitter (again, see the [README](https://github.com/neo4jrb/twitter_analytics/blob/master/README.md))
 * Start up the app and view the results (by default at [`http://localhost:3000`](http://localhost:3000))

Of course you can always browse the data using neo4j's excellent web console (by default at [`http://localhost:7474`](http://localhost:7474)):

<img style="margin: 0.6em;" src="/assets/twitter_analytics/web_console.png">

### Want to help out?

The app is still a work in progress so I welcome any contributions!  There are some ideas and issues on the [github issues page](https://github.com/neo4jrb/twitter_analytics/issues) for a start.

There are also some really cool high level things which I'd really like to see such as:

 * Centrality analysis to find important users, hashtags, and tweets
 * Cluster analysis to identify groups of users
 * Natural language processing to expand on hashtag analysis

Happy analyzing!

