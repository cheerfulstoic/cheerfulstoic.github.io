---
title: Using Graph Structure Record Linkage on Irish Census Data with Neo4j
layout: posts
date: 2015-08-20 09:55 ART

tags:
- neo4j
- master-data-management
---

For just over a year I've been obsessed on-and-off with a project ever since I stayed in the town of Skibbereen, Ireland.  Taking data from the [1901 and 1911 Irish censuses](http://www.census.nationalarchives.ie/) I hoped I would be able to find a way to reliably link resident records from the two together to identify the same residents.  Since then I've learned a bit about [master data management and record linkage](/tag/master-data-management) and so I thought I would give it another stab.  Here I'd like to talk about how I've been matching records based on the local data space around objects to improve my record linkage scoring.

The data model of the imported data is very linear:

<img style="width: 100%; display: block; margin: 0 auto" src="/assets/neo4j-mdm/irish_census_wrah.png">

In this post, however, I'm going to be focusing on Houses and Residents and creating relationships between them based on their properties.

## Relations to the Head

To view an example of what a census record from 1911 Ireland looks like you can have a look at the McCarthys of [1901](http://www.census.nationalarchives.ie/pages/1901/Cork/Cloghdowell/Barnagowlane/1154382/) and [1911](http://www.census.nationalarchives.ie/pages/1911/Cork/Cloghdonnell/Barnagowlane/440559/).  Charles is the head of the family with his wife Hannah, mother Ellen, children (two in 1901 and seven in 1911), and a servant (Timothy Walsh in 1901 and William Regan in 1911).

<style>
table {
  border-collapse: collapse;
  margin: 0 auto !important;
}
table, th, td {
  border: 1px solid #CCC;
  padding: 0.3em;
}
</style>

<table>
  <tr>
    <td style="font-weight: 0.8em; font-weight: bold; text-align: center">
      <a href="http://www.census.nationalarchives.ie/pages/1901/Cork/Cloghdowell/Barnagowlane/1154382/">
        <img style="width: 350px; display: block; margin: 0 auto" src="/assets/neo4j-mdm/mccarthy_census_1901.png">
        The McCarthy family of Barnagowlane, Cloghdowell, Cork, 1901
      </a>
    </td>
    <td style="font-weight: 0.8em; font-weight: bold; text-align: center">
      <a href="http://www.census.nationalarchives.ie/pages/1911/Cork/Cloghdonnell/Barnagowlane/440559/">
        <img style="width: 350px; display: block; margin: 0 auto" src="/assets/neo4j-mdm/mccarthy_census_1911.png">
        The McCarthy family of Barnagowlane, Cloghdonnell, Cork, 1911
      </a>
    </td>
  </tr>
</table>


| Surname   | Forename | Age | Sex  | Relation to Head | Religion | | Surname | Forename | Age | Sex  | Relation to Head | Religion
|-----------|----------|-----|------|------------------|----------|-|---------|----------|-----|------|------------------|---------
| McCarthy | Charles | 37 | Male | Head of Family | Roman Catholic | | McCarthy | Charles | 47 | Male | Head of Family | Roman Catholic
| McCarthy | Hannah | 25 | Female | Wife | Roman Catholic | | McCarthy | Hannah | 35 | Female | Wife | Roman Catholic
| McCarthy | William | 1 | Male | Son | Roman Catholic | | McCarthy | William | 11 | Male | Son | Roman Catholic
| McCarthy | Bridget | | Female | Daughter | Roman Catholic | | McCarthy | Bridget | 10 | Female | Daughter | Roman Catholic 
| | | | | | | | McCarthy | Ellen | 8 | Female | Daughter | Roman Catholic
| | | | | | | | McCarthy | Kate | 6 | Female | Daughter | Roman Catholic
| | | | | | | | McCarthy | Florence | 4 | Male | Son | Roman Catholic
| | | | | | | | McCarthy | Charles Peter | 2 | Male | Son | Roman Catholic
| | | | | | | | McCarthy | Annie |  | Female | Daughter | Roman Catholic
| McCarthy | Ellen | 65 | Female | Mother | Roman Catholic | | McCarthy | ? Ellen | 75 | Female | Mother | Roman Catholic
| Walsh | Timothy | 25 | Male | Servant | Roman Catholic |
| | | | | | | | Regan | William | 24 | Male | Servant | Roman Catholic



The McCarthys are an almost exact match between two census records between 1901 and 1911.  The names, ages, occupations, and relationships all match perfectly.  Unfortunately the story for other records is not so simple.  Many times houses, which to the human eye seem to be the same house, can have wildly varying details.  For example Hannah might go be listed as Hana or Anne in a different census.  Likewise ages vary a lot more than you might think.  In examining the records I regularly found ages varying by a year or two and have even found a few houses with ages off by as much as 10-15 years.

In both censuses there is a field for residents to fill out called "Relation to Head".  This gives us information about how each resident is related to the head of the house.  In the case of the McCarthys, Charles is listed as "Head of Fa<D-i>mily" in both years.  The rest of the family has a nice representation of things that we often see in the data: "Wife", "Son", "Daughter", and "Servant".

We might be tempted to say "This person was the head in 1901, so they must be the same person who was the head in 1911".  Often, however, the head of the family can die or retire leaving the roll of head of the family to their wife or child.  Can the "Relation to Head" values still be useful to us to match any given resident from 1901 to another resident in 1911?

First let's cover the general the process of record linkage I have been using.  To find a match for a resident I start by using an `elasticsearch` server (which contains a duplicate of my Neo4j census data) to quickly find a list of other residents with a match on very rough criteria:

 * Is the resident in the other census?
 * Does the sex match (or it it `NULL`)?
 * Is the resident's age within 15 years of what it would be expected to be in the other census?
 * Does the name match roughly (within an edit distance of 4)

This comes back with anywhere from zero to hundreds of results.  I call these "similarity candidates" and for each I create a relationship between the original record and the candidate.

With this list I can compare the attributes of the two records (using the [record_linkage](https://rubygems.org/gems/record_linkage) gem I created) to see how closely they match.  The closer their name, sex, age, etc.. matches, the higher score they get.  Ideally the real match should have the highest score, but that isn't always true and can take [some tuning](http://127.0.0.1:4000/2015/05/14/master_data_management_scoring_examples/).

In addition to this simple comparison of attributes, I have now added a process to take advantage of the similarity candidate relationships to compare family relationships.  Let's start with this example of a sub-graph pattern:

<img style="width: 850px; margin: 0.6em;" src="/assets/neo4j-mdm/mccarthy_charles_comparison.png">

The relationship `CHILD_OF` is created whenever there is a "Son" or "Daughter" in the "Realation to Head" field.  Likewise we can create other gender-neutral relationships like `MARRIED_TO`, `SIBLING_OF`, `NIECE_NEPHEW_OF`, etc...

In this case the resident in question is the 1901 record for William.  When we are evaluating the 1911 record of William as a potential match we can explore other residents in the same house as evidence of similarity.  The diagram above shows that both records have a `CHILD_OF` relationship to the two "Charles" records which furthermore are linked via a `SIMILARITY_CANDIDATE` relationship.  Because of this we can say that there is a greater chance that the two "William" records represent the same person.

This only gives us the ability to find these relationships between the head of the family and other residents.  What about generically matching based on the relationship of any two residents of a house?  Let's say that Charles died sometime between 1901 and 1911.  If his wife Hannah takes over as the head of the family we would have a sub-graph which looks like this:

<img style="width: 850px; margin: 0.6em;" src="/assets/neo4j-mdm/mccarthy_hannah_comparison.png">

We could say that when we have the paths `-CHILD_OF-><-MARIED_TO-` and `-CHILD_OF->` on either side that we can build our case for a match a bit more.  This kind of matching can be used on all of the other residents of the house with `SIMILARITY_CANDIDATE` relationships.  For example, `-CHILD_OF-><-CHILD_OF-` could be matched to `-CHILD_OF-><-CHILD_OF-` even in this case where the wife becomes the head of the house.  Or if a child becomes the head then it could be compared to a `-SIBLING_OF-` relationship.

## The Code

So how do we actually do this?  First let's take our sub-graph and turn our nodes into variables:

<img style="width: 850px; margin: 0.6em;" src="/assets/neo4j-mdm/irish_census_relationship_mapping.png">

In this example let's take resident `h1 r1` (house 1, resident 1) as the resident in question and `h2 r1` as the candidate that we want to compare it to.  This is the sort of query that Neo4j is wonderful at both performing quickly and making easy to formulate.  Let's look at part of the Ruby code:


<pre><code class="language-ruby">

def get_similarity_candidate_relationship_paths
  self.query_as(:h1_r1)
    .match('(h1:House), (h2:House)')
    .match('h1<-[:LIVES_IN]-h1_r1-[sc_1:similarity_candidate]-(h2_r1)-[:LIVES_IN]->h2')
    .match('h1<-[:LIVES_IN]-h1_r2-[sc_2:similarity_candidate]-(h2_r2)-[:LIVES_IN]->h2')
    .match('path1=h1_r1-[:born_to|married_to|grandchild_of|niece_nephew_of|sibling_of|cousin_of|child_in_law_of|step_child_of*1..2]-h1_r2')
    .match('path2=h2_r1-[:born_to|married_to|grandchild_of|niece_nephew_of|sibling_of|cousin_of|child_in_law_of|step_child_of*1..2]-h2_r2')
    .pluck(
      :h2_r1,
      'collect([path1, rels(path1), path2, rels(path2)])'
      ).each_with_object({}) do |(r2, data), result|

    result[r2] = data.inject(0) do |total, (path1, rels1, path2, rels2)|
      relations1 = relation_string_from_path_and_rels(path1, rels1)
      relations2 = relation_string_from_path_and_rels(path2, rels2)

      if relations1 == relations2
        1.0
      elsif score = (RELATION_EQUIVILENCE_SCORES[relations1] || {})[relations2]
        score
      else
        -2.0
      end + total
    end
  end
end

</code></pre>

Here we start with a Cypher query using the `Query` API from neo4j.rb.  The object upon which we've called `get_similarity_candidate_relationship_paths` is our `h1_r1` anchor.  Note here that we match paths with a length of either one or two relationships long from between two residents of the same house.  Then we return all residents found via the `SIMILARITY_CANDIDATE` relationship from our anchor and the family relationship paths aggregated into an Array.

Once the Cypher query returns data we call `relation_string_from_path_and_rels` which is a way of transforming the path into a string like `-BORN_TO-><-BORN_TO`.  This string gives us a simple way to express the path between the two residents as a string.

We then can give a score based on the two paths.  If the paths are the same then we say that the score is 1.0.  If the pair of paths is something like `-BORN_TO-><-BORN_TO` and `-SIBLING_OF->` then we can give a score based on a lookup.  We add these scores up to give us a total score comparing our anchor resident and each of it's similarity candidates.  All with just one query to the database.

### Challenges

There are a couple of things that I needed to do to make this work:

Previously I was simply grabbing one resident at a time, finding all of the similarity candidates, and then creating a set of relationships to link the resident with the candidates and to store the record linkage scores (both the individual scores for fields and the total score).  However this approach requires all of the candidates in the house to have `SIMILARITY_CANDIDATE` relationships in order to compare family relationships.  So I first process all residents for a house to create the similarity candidate relationships and store the record linkage scores and then go through them again with the graph-based comparisons and store that score and update the total.

Beyond that there is the conceptual problem of determining the scoring when comparing paths.  For example, if somebody was `BORN_TO` the head one year but their spouse takes over as the head, could we say that they're `BORN_TO` the spouse if they are are a step-child?  Family relationships are complicated and don't always fit neatly into our properties and algorithms.

### Conclusion

Most record linkage focuses on the properties of an object, but we need to remember that relationships are data about our entities too.  With Neo4j we have a powerful tool for analyzing those relationships natuarally and quickly.  Additionally I have found that the ability to create relationships on the fly to aggregate calculations like the ones discussed above is a wonderful way to find the best solution quickly.

