---
title: Master Data Management Scoring Examples
layout: posts
date: 2015-05-14 16:10 GMT
tags:
- neo4j
- master-data-management
---

A while ago my colleague [Michael](https://twitter.com/mesirii) suggested to me that I draw out some examples of how my [record linkage]({% post_url 2015-03-08-making_master_data_management_fun_with_neo4j_-_part_3 %}) algorithm did it's thing.  In order to do that, I've picked some users from both GitHub and StackOverflow which are big names in the Neo4j community to give you the idea.  

For each user in my list of famous Neo4jers I find the user on the other site which my algorithm matches best based on the matching score meeting a threshold.
In that algorithm I match users via attribute pairings (e.g. `name` on GitHub and `display_name` on StackOverflow).
Below I show how these property pairs contribute to each user's score.

### The selected users

Below are the users which I selected.  I selected a set from both GitHub and StackOverflow so that I could test matching in both directions.

#### GitHub

| [Michael Hunger](https://github.com/jexp) | [Stefan Armbruster](https://github.com/sarmbruster) | [Max De Marzi](https://github.com/maxdemarzi) | [Peter Neubauer](https://github.com/peterneubauer)
| [Christophe Willemsen](https://github.com/ikwattro) | [Wes Freeman](https://github.com/wfreeman) | [moxious](https://github.com/moxious) | [Mark Needham](https://github.com/mneedham)
| [Chris Grigg](https://github.com/subvertallchris) | [Brian Underwood](https://github.com/cheerfulstoic) | [Philippe Ombredanne](https://github.com/pombredanne) | [Anders Nawroth](https://github.com/nawroth)
| [Andreas Kollegger](https://github.com/akollegger) | [Tobias Lindaaker](https://github.com/thobe) | [Jacob Hansson](https://github.com/jakewins) | [Julian Simpson](https://github.com/simpsonjulian)
| [Andreas Ronge](https://github.com/andreasronge) | [Thomas Baum](https://github.com/tbaum)

#### StackOverflow

| [FrobberOfBits](http://stackoverflow.com/users/2920686) | [Luanne](http://stackoverflow.com/users/232671) | [Dave Bennett](http://stackoverflow.com/users/4187346) | [cybersam](http://stackoverflow.com/users/974731)
| [albertoperdomo](http://stackoverflow.com/users/2061244) | [jjaderberg](http://stackoverflow.com/users/2481199) | [Nicholas](http://stackoverflow.com/users/256108) | [David Makogon](http://stackoverflow.com/users/272109)


### Property Matching Chart

Here is a chart which shows all of the users.  The total bar size represents their total score while each section represents a pair of properties which were chosen for matching.  You'll notice that seven of the 25 users aren't matched.

<div style="text-align: center">
  <img src="/assets/neo4j-mdm/famous_peeps.png">
</div>

### Score Details

Here I dig down into the nitty details of the values of interest for each user pair and the scores given for matches on those values.  For each property pair for each user pair I show:

 * the weight
 * the base score
 * the total score

The weights for each property pair are constant from user to user and are based on an my analysis comparing my human identified results with various weights and thresholds to maximize [precision and recall](http://en.wikipedia.org/wiki/Precision_and_recall).

The total score for for each user (not shown here) is the sum of the total scores of the property pairs.  The user pairs which I am displaying below are considered matches because they have the largest score among other pairs and because they match a minimum threshold.

<style>
table {
  border-collapse: collapse;
}
table, th, td {
  border: 1px solid #CCC;
  padding: 0.3em;
}

</style>

| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | cybersam | cybersam | 1.5 | 1.0 | 1.5 |
| name | display_name | Sam | cybersam | 1.5 | 0.0 | 0.0 |
| location | location | Silicon Valley | Silicon Valley | 3.5 | 1.0 | 3.5 |
| usernames | usernames | ["cybersam"] | ["cybersam"] | 3.5 | 1.0 | 3.5 |
| uncommon_domains | uncommon_domains | [] | [] | 4.5 | 0.0 | 0.0 |
| blog | website_url |  |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 77601 | 51509 | 4.5 | 0.73 | 3.3 |
| login | github_username | cybersam |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | davestern | Dave Bennett | 1.5 | 0.83 | 1.2 |
| name | display_name | Dave Stern | Dave Bennett | 1.5 | 0.87 | 1.3 |
| location | location |  | Calgary | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["davestern"] | ["dave bennett"] | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | [] | [] | 4.5 | 0.0 | 0.0 |
| blog | website_url |  |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 76872 | 51521 | 4.5 | 0.0 | 0.0 |
| login | github_username | davestern |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name |  | FrobberOfBits | 1.5 | 0.0 | 0.0 |
| name | display_name |  | FrobberOfBits | 1.5 | 0.0 | 0.0 |
| location | location |  | East Coast, USA | 3.5 | 0.0 | 0.0 |
| usernames | usernames |  | ["frobberofbits"] | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains |  | [] | 4.5 | 0.0 | 0.0 |
| blog | website_url |  |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison |  | 51799 | 4.5 | 0.0 | 0.0 |
| login | github_username |  |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | NicholasAStuart | Nicholas | 1.5 | 0.93 | 1.4 |
| name | display_name | Nicholas A. Stuart | Nicholas | 1.5 | 0.9 | 1.3 |
| location | location | San Francisco, CA | San Francisco, CA | 3.5 | 1.0 | 3.5 |
| usernames | usernames | ["nicholasastuart"] | ["nicholas"] | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | [] | [] | 4.5 | 0.0 | 0.0 |
| blog | website_url | https://github.com/NicholasAStuart |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 64519 | 52854 | 4.5 | 0.0 | 0.0 |
| login | github_username | NicholasAStuart |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | lucciano | Luanne | 1.5 | 0.78 | 1.2 |
| name | display_name | Luciano Andrade | Luanne | 1.5 | 0.76 | 1.1 |
| location | location |  | Mumbai, India | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["lucciano"] | ["luanne", "luannem"] | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | [] | ["thought-bytes.blogspot.in"] | 4.5 | 0.0 | 0.0 |
| blog | website_url |  | thought-bytes.blogspot.in | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 60299 | 53143 | 4.5 | 0.0 | 0.0 |
| login | github_username | lucciano |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  | luannem | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | albertoperdomo | albertoperdomo | 1.5 | 1.0 | 1.5 |
| name | display_name | Alberto Perdomo | albertoperdomo | 1.5 | 0.99 | 1.5 |
| location | location | Las Palmas de Gran Canaria, Spain | Spain | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["albertoperdomo"] | ["albertoperdomo"] | 3.5 | 1.0 | 3.5 |
| uncommon_domains | uncommon_domains | ["albertoperdomo.net"] | ["graphenedb.com"] | 4.5 | 0.0 | 0.0 |
| blog | website_url | http://albertoperdomo.net | graphenedb.com | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 62234 | 54027 | 4.5 | 0.0 | 0.0 |
| login | github_username | albertoperdomo |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | johanlundberg | jjaderberg | 1.5 | 0.77 | 1.1 |
| name | display_name | Johan Lundberg | jjaderberg | 1.5 | 0.75 | 1.1 |
| location | location | Stockholm |  | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["johanlundberg"] | ["jjaderberg"] | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | ["snakedesert.se"] | ["d.phil"] | 4.5 | 0.0 | 0.0 |
| blog | website_url | http://www.snakedesert.se |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 65150 | 55433 | 4.5 | 0.0 | 0.0 |
| login | github_username | johanlundberg |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | maxdemarzi | Max De Marzi | 1.5 | 0.96 | 1.4 |
| name | display_name | Max De Marzi | Max De Marzi | 1.5 | 1.0 | 1.5 |
| location | location | 60601 | Chicago, IL | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["maxdemarzi"] | ["max de marzi"] | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | ["maxdemarzi.com"] | ["maxdemarzi.com"] | 4.5 | 1.0 | 4.5 |
| blog | website_url | maxdemarzi.com | maxdemarzi.com | 4.5 | 1.0 | 4.5 |
| image_comparison | image_comparison | 60207 | 59296 | 4.5 | 0.0 | 0.0 |
| login | github_username | maxdemarzi |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | tbaum | Thomas | 1.5 | 0.0 | 0.0 |
| name | display_name | Thomas Baum | Thomas | 1.5 | 0.93 | 1.4 |
| location | location | Germany / Dresden | Germany | 3.5 | 0.88 | 3.1 |
| usernames | usernames | ["tbaum"] | ["thomas"] | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | [] | ["google.de"] | 4.5 | 0.0 | 0.0 |
| blog | website_url |  | google.de | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 60777 | 52946 | 4.5 | 0.0 | 0.0 |
| login | github_username | tbaum |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | sarmbruster | Stefan Armbruster | 1.5 | 0.78 | 1.2 |
| name | display_name | Stefan Armbruster | Stefan Armbruster | 1.5 | 1.0 | 1.5 |
| location | location | Munich, Germany | Munich, Germany | 3.5 | 1.0 | 3.5 |
| usernames | usernames | ["sarmbruster"] | ["stefan armbruster"] | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | ["blog.armbruster-it.de"] | ["blog.armbruster-it.de"] | 4.5 | 1.0 | 4.5 |
| blog | website_url | http://blog.armbruster-it.de | blog.armbruster-it.de | 4.5 | 0.77 | 3.5 |
| image_comparison | image_comparison | 60881 | 51506 | 4.5 | 0.0 | 0.0 |
| login | github_username | sarmbruster |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | mneedham | Mark Needham | 1.5 | 0.82 | 1.2 |
| name | display_name | Mark Needham | Mark Needham | 1.5 | 1.0 | 1.5 |
| location | location | London, United Kingdom | United Kingdom | 3.5 | 0.74 | 2.6 |
| usernames | usernames | ["mneedham"] | ["mark needham"] | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | ["markhneedham.com"] | ["markhneedham.com"] | 4.5 | 1.0 | 4.5 |
| blog | website_url | http://www.markhneedham.com/blog | markhneedham.com/blog | 4.5 | 0.76 | 3.4 |
| image_comparison | image_comparison | 60963 | 53357 | 4.5 | 0.0 | 0.0 |
| login | github_username | mneedham |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | pombredanne |  | 1.5 | 0.0 | 0.0 |
| name | display_name | Philippe Ombredanne |  | 1.5 | 0.0 | 0.0 |
| location | location |  |  | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["pombredanne"] |  | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | [] |  | 4.5 | 0.0 | 0.0 |
| blog | website_url |  |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 61003 |  | 4.5 | 0.0 | 0.0 |
| login | github_username | pombredanne |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | jexp | Michael Hunger | 1.5 | 0.0 | 0.0 |
| name | display_name | Michael Hunger | Michael Hunger | 1.5 | 1.0 | 1.5 |
| location | location | Dresden, Germany | Dresden, Germany | 3.5 | 1.0 | 3.5 |
| usernames | usernames | ["jexp"] | ["michael hunger", "mesirii", "jexp"] | 3.5 | 1.0 | 3.5 |
| uncommon_domains | uncommon_domains | ["jexp.de"] | ["spring.neo4j.org", "die-buchbar.de", "mg.mud.de"] | 4.5 | 0.0 | 0.0 |
| blog | website_url | http://jexp.de | neo4j.com | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 61063 | 51548 | 4.5 | 0.0 | 0.0 |
| login | github_username | jexp | jexp | 4.5 | 1.0 | 4.5 |
| twitter_username | twitter_username |  | mesirii | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | akollegger | akollegger | 1.5 | 1.0 | 1.5 |
| name | display_name | Andreas Kollegger | akollegger | 1.5 | 0.75 | 1.1 |
| location | location | San Francisco, CA | California | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["akollegger"] | ["akollegger"] | 3.5 | 1.0 | 3.5 |
| uncommon_domains | uncommon_domains | [] | [] | 4.5 | 0.0 | 0.0 |
| blog | website_url | http://neo4j.com | neo4j.com | 4.5 | 0.85 | 3.8 |
| image_comparison | image_comparison | 61069 | 58359 | 4.5 | 0.0 | 0.0 |
| login | github_username | akollegger |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | simpsonjulian |  | 1.5 | 0.0 | 0.0 |
| name | display_name | Julian Simpson |  | 1.5 | 0.0 | 0.0 |
| location | location | Auckland, New Zealand |  | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["simpsonjulian"] |  | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | ["build-doctor.com"] |  | 4.5 | 0.0 | 0.0 |
| blog | website_url | http://www.build-doctor.com |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 61073 |  | 4.5 | 0.0 | 0.0 |
| login | github_username | simpsonjulian |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | jakewins | jakewins | 1.5 | 1.0 | 1.5 |
| name | display_name | Jacob Hansson | jakewins | 1.5 | 0.0 | 0.0 |
| location | location | Sweden | Stockholm, Sweden | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["jakewins"] | ["jakewins"] | 3.5 | 1.0 | 3.5 |
| uncommon_domains | uncommon_domains | ["voltvoodoo.com"] | ["jakewins.com"] | 4.5 | 0.0 | 0.0 |
| blog | website_url | http://voltvoodoo.com | jakewins.com | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 61077 | 57589 | 4.5 | 0.0 | 0.0 |
| login | github_username | jakewins |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | peterneubauer | Peter Neubauer | 1.5 | 0.98 | 1.5 |
| name | display_name | Peter Neubauer | Peter Neubauer | 1.5 | 1.0 | 1.5 |
| location | location | Malmö, Sweden |  | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["peterneubauer"] | ["peter neubauer", "peterneubauer"] | 3.5 | 1.0 | 3.5 |
| uncommon_domains | uncommon_domains | [] | ["mapillary.com"] | 4.5 | 0.0 | 0.0 |
| blog | website_url |  | mapillary.com | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 61089 | 55637 | 4.5 | 0.0 | 0.0 |
| login | github_username | peterneubauer |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  | peterneubauer | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | thobe |  | 1.5 | 0.0 | 0.0 |
| name | display_name | Tobias Lindaaker |  | 1.5 | 0.0 | 0.0 |
| location | location |  |  | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["thobe"] |  | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | ["journal.thobe.org"] |  | 4.5 | 0.0 | 0.0 |
| blog | website_url | http://journal.thobe.org |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 61097 |  | 4.5 | 0.0 | 0.0 |
| login | github_username | thobe |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | nawroth |  | 1.5 | 0.0 | 0.0 |
| name | display_name | Anders Nawroth |  | 1.5 | 0.0 | 0.0 |
| location | location | Skåne, Sweden |  | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["nawroth"] |  | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | ["anders.nawroth.se"] |  | 4.5 | 0.0 | 0.0 |
| blog | website_url | www.anders.nawroth.se |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 61099 |  | 4.5 | 0.0 | 0.0 |
| login | github_username | nawroth |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | wfreeman | Wes Freeman | 1.5 | 0.88 | 1.3 |
| name | display_name | Wes Freeman | Wes Freeman | 1.5 | 1.0 | 1.5 |
| location | location | Fairfax, VA | Fairfax, VA | 3.5 | 1.0 | 3.5 |
| usernames | usernames | ["wfreeman"] | ["wes freeman"] | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | ["wes.skeweredrook.com"] | ["wes.skeweredrook.com"] | 4.5 | 1.0 | 4.5 |
| blog | website_url | http://wes.skeweredrook.com | wes.skeweredrook.com | 4.5 | 0.91 | 4.1 |
| image_comparison | image_comparison | 61111 | 53606 | 4.5 | 0.0 | 0.0 |
| login | github_username | wfreeman |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | ikwattro |  | 1.5 | 0.0 | 0.0 |
| name | display_name | Christophe Willemsen |  | 1.5 | 0.0 | 0.0 |
| location | location | Belgium |  | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["ikwattro"] |  | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | [] |  | 4.5 | 0.0 | 0.0 |
| blog | website_url | https://twitter.com/#!/ikwattro |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 61128 |  | 4.5 | 0.0 | 0.0 |
| login | github_username | ikwattro |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | subvertallchris | subvertallchris | 1.5 | 1.0 | 1.5 |
| name | display_name | Chris Grigg | subvertallchris | 1.5 | 0.0 | 0.0 |
| location | location | Brooklyn, NY | Brooklyn, NY | 3.5 | 1.0 | 3.5 |
| usernames | usernames | ["subvertallchris", "subvertallmedia"] | ["subvertallchris", "subvertallmedia", "neo4jrb"] | 3.5 | 2.0 | 7.0 |
| uncommon_domains | uncommon_domains | [] | ["blog.subvertallmedia.com"] | 4.5 | 0.0 | 0.0 |
| blog | website_url | https://twitter.com/subvertallmedia | blog.subvertallmedia.com | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 61285 | 51540 | 4.5 | 0.0 | 0.0 |
| login | github_username | subvertallchris | neo4jrb | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username | subvertallmedia | subvertallmedia | 4.5 | 1.0 | 4.5 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | cheerfulstoic | Brian Underwood | 1.5 | 0.0 | 0.0 |
| name | display_name | Brian Underwood | Brian Underwood | 1.5 | 1.0 | 1.5 |
| location | location | Travelling | Travelling | 3.5 | 1.0 | 3.5 |
| usernames | usernames | ["cheerfulstoic"] | ["brian underwood", "cheerfulstoic", "neo4jrb"] | 3.5 | 1.0 | 3.5 |
| uncommon_domains | uncommon_domains | ["brian-underwood.codes"] | ["grandadventures-householdchores.com", "brian-underwood.codes"] | 4.5 | 1.0 | 4.5 |
| blog | website_url | http://www.brian-underwood.codes/ | brian-underwood.codes | 4.5 | 0.77 | 3.5 |
| image_comparison | image_comparison | 61327 | 51500 | 4.5 | 0.0 | 0.0 |
| login | github_username | cheerfulstoic | neo4jrb | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  | cheerfulstoic | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | moxious |  | 1.5 | 0.0 | 0.0 |
| name | display_name |  |  | 1.5 | 0.0 | 0.0 |
| location | location |  |  | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["moxious"] |  | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | [] |  | 4.5 | 0.0 | 0.0 |
| blog | website_url |  |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 61948 |  | 4.5 | 0.0 | 0.0 |
| login | github_username | moxious |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username |  |  | 4.5 | 0.0 | 0.0 |



| GH Prop | SO Prop | GH Value | SO Value | Weight | Base Score | Weighted Score |
|----------------------------
| login | display_name | andreasronge | Andreas Ronge | 1.5 | 0.99 | 1.5 |
| name | display_name | Andreas Ronge | Andreas Ronge | 1.5 | 1.0 | 1.5 |
| location | location | Malmö, Sweden |  | 3.5 | 0.0 | 0.0 |
| usernames | usernames | ["andreasronge", "ronge"] | ["andreas ronge"] | 3.5 | 0.0 | 0.0 |
| uncommon_domains | uncommon_domains | [] | [] | 4.5 | 0.0 | 0.0 |
| blog | website_url | http://twitter.com/ronge |  | 4.5 | 0.0 | 0.0 |
| image_comparison | image_comparison | 62280 | 55831 | 4.5 | 0.73 | 3.3 |
| login | github_username | andreasronge |  | 4.5 | 0.0 | 0.0 |
| twitter_username | twitter_username | ronge |  | 4.5 | 0.0 | 0.0 |


