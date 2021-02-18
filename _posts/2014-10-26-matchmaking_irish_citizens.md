---
layout: posts
title: Matchmaking Irish Citizens
categories:
- investigations
- neo4j
- irish census
tags:
- neo4j
---

> I am he as you are he as you are me and we are all together
>
> -- <cite>[The Beatles][1]</cite>

[1]:http://en.wikipedia.org/wiki/I_Am_the_Walrus

For a while now I have been working in my spare time on a project involving [the 1901 and 1911 Irish national censuses]({% post_url 2014-09-02-normalizing_religion_in_ireland %}).  I have been casually exploring the data, but as a larger goal I want to find a way to programatically link together the citizens of the two years to each other.  With this I hope to be able ask larger questions of the data such as:

 * How often did Irish citizens move over this ten year period in Irish history?
 * How often did Irish citizens change professions?
 * Can we track children which have moved out to different locations?

As to matching residents there are a number of challenges.  For example:

 * Transcription errors from the records to the computer (fortunately we can at least verify information via PDFs available online)
 * There are many instances of ages being off by 1-5 years even when it is clear the resident is the same (even though the censuses were conducted the March 31st, 1901 and April 2nd, 1911)
 * Given names are sometimes different, either as given by the resident or written down by the enumerator
 * As the census was performed by the British government, Irish residents didn't always want to give full truthful information to those who they might have seen as an occupying force

So, my first step is a bit of code I call `ObjectScorer`.  I've employed it in my `Resident` class with the following methods:

      def similarity_to(other_resident)
        object_scorer.percentage_score(other_resident)
      end

      def object_scorer
        @object_scorer ||= ObjectScoring::ObjectScorer.new(self,
                                                           field_scorers,
                                                           field_weights,
                                                           field_options)
      end

      def field_weights
        {
          forename: 10,
          surname: 4,
          religion: 5,
          age: 10,
          sex: 10,
          latitude: 5,
          longitude: 5,
          ded_name: 5,
          townland_street_name: 5
        }
      end

      def field_scorers
        {
          forename: :insensitive_levenshtein_nearness,
          surname: :insensitive_levenshtein_nearness,
          religion: :exact,
          age: :nearness,
          sex: :exact,
          latitude: :nearness,
          longitude: :nearness,
          ded_name: :insensitive_levenshtein_nearness,
          townland_street_name: :insensitive_levenshtein_nearness
        }
      end

      def field_options
        {
          forename: {max_distance: 5},
          surname: {max_distance: 5},
          age: {max_distance: 5, value: age_in(other_census_year)},
          ded_name: {max_distance: 5},
          townland_street_name: {max_distance: 5},
        }
      end


The concept is pretty simple: I define a set of fields on which I want to compare two objects, define how to match them and how much I care about those fields matching, and then ObjectScorer gives me a percentage match.

Taking the `age` field, I specify a simple integer nearness metric.  So for the ages of `21` and `23` we:

 * subtract and take the absolute value to get `2`
 * subtracting from and dividing that by the maximum distance we get `0.6`
 * multiplying by the weight (`10`) we get `6`.

Taking the `forename` field, I specify a case-insensitive [Levenshtein distance](http://en.wikipedia.org/wiki/Levenshtein_distance) with a weight of `10` and a maximum distance of `5`.  If I'm comparing the two forenames `John` and `Jon`, we:

 * get a distance of `1`
 * subtract that from the maximum distance to get `4`
 * divide that by the maximum distance to get `.8`
 * multiply by the weight to get `8`.

If these were the only two fields we were comparing we would add up our results and divide by the sum of the weights as in `(8 + 6) / (10 + 10)` and we'd wind up with a score of `0.7`.  Taken all together this gives us a nice way to compare many records together and sort them by which is the best match.

But of course we can't just load up all of the records in the database and compare them in memory.  We need to find a reasonable subset to run these comparisons on.  In my case when looking for candidates for a particular records I look for records which:

 * Are in the other census year
 * Have the same value or null for `sex`
 * Have an age which would have been / will be within five years of being correct in the other census
 * Match the forename and surname with a maximum "edit distance" of 4 characters

These queries are done with [elasticsearch](http://www.elasticsearch.org/) first and then turned into Neo4j ActiveNode objects in memory.  And thus I get a reasonable algorithm which can allow me to compare records to each other!
