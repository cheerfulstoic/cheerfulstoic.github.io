---
title: Running a Neo4j Cypher Introduction Workshop
layout: posts
date: 2015-04-16 14:23
tags:
- neo4j
---

Last night I ran a very successful workshop at the [Friends of Neo4j Stockholm](http://www.meetup.com/Friends-of-Neo4j-Stockholm/) meetup group.  The format was based on a workshop that I attended in San Francisco while the World Cup was going on and was based around investigating a dataset of previous World Cup matches.  Roughly the format was:

 * A short presentation introducing the [Cypher query language](http://neo4j.com/developer/cypher-query-language/)
 * A one to two hour section allowing people to apply what they've learned in the Neo4j web console by formulating questions and creating queries to answer those questions
 * A presentation section where participants are invited up to present

During the World Cup, Mark Needham and the Neo4j team put together a great [resource website](http://worldcup.neo4j.org/) sharing results and information about the dataset which can be loading via [this GitHub repository](https://github.com/mneedham/neo4j-worldcup).

## Beforehand

Before [the workshop](http://www.meetup.com/Friends-of-Neo4j-Stockholm/events/221673524/) I had asked people to [install Neo4j](https://www.youtube.com/watch?v=V7f2tGsNSck) and set up either the World Cup dataset or a [Summer Olympics](https://github.com/cheerfulstoic/neo4j_summer_olympics) dataset which I had also created for their use.  Both datasets had instructions and load scripts to make it easy to set up.

## The Presentation

I used a [slideshow from Max De Marzi](http://www.slideshare.net/maxdemarzi/cypher-12154713) which I updated for Neo4j 2.x and simplified for an introduction session.  You can see my slideshow [here](http://www.slideshare.net/BrianUnderwood2/intro-to-cypher-47072474).

I also improvised a bit as I presented.  One of the biggest things that I wish I had put in was an introduction to Neo4j concepts:

* **Nodes**
	* Hold properties (key-value stores)
	* Have **zero or more "labels"** (somewhat analogous to SQL tables)

* **Relationships**
	* Also hold properties
	* Have **exactly one "type"** (describing how/why the relationship is connecting the nodes)
	* Always specify a direction from one node to another
	* Relationships can be queried in either direction or without regard to direction without a performance cost

I also discussed a number of other issues which aren't explicitly laid out in the presentation:

* I talked about Neo4j internal IDs and how they shouldn't be used for long-term identification of nodes (as future versions of Neo4j may shuffle them around for performance)
* I explained parameters and talked about why they should be used (for performance and to prevent injection vulnerabilities)
* I paused briefly to ask for questions after introducing each new concept

## The Working Session

As much as I love to hear myself talk, I really enjoyed walking around and checking in with people and answering their questions.  I can very hard to address every possible concern, but it's much better to see how people try to do things and help them as they go.  For example, in my presentation I mentioned Neo4j's syntax for matching values:

    MATCH (p:Person {name: 'Jim'})

... works the same as ...

    MATCH (p:Person) WHERE p.name = 'Jim'

Of course I forgot to explain that this syntax is only for exact matches and doesn't work for things like regular expressions or `IN` clauses.  

## Project Presentations

When I attended the World Cup workshop in San Francisco there were a few nice presentations about what people had been working on.  During my session nobody wanted to present.  Everybody was very engaged in working on their queries, however, so I didn't push it.

## Conclusion

The workshop was a really fun way to get people using Neo4j really quickly.  It can feel a bit strange to simply give people some datasets and ask them to do something with it, but the freedom to be creative helped both the participants and me be really excited about working with Neo4j.  I look forward to doing more workshops again in the future!

