---
layout: posts
title: Normalizing Religion in Ireland
categories:
- investigations
- neo4j
- irish census
---

> When I told the people of Northern Ireland that I was an atheist,
> a woman in the audience stood up and said, 'Yes, but is it the God
> of the Catholics or the God of the Protestants in whom you don't believe?'
>
> -- <cite>Quentin Crisp</cite>


I've been staying at an AirBNB in Ireland recently and my host told me about the [Irish National Census website](http://www.census.nationalarchives.ie/).  On this site many of the census records from around the turn of the 20th century have been transcribed and are available on their website, including all of the census records from the years 1901 and 1911.  My host was interested in downloading records from his home county, but I thought it would be fun to download all counties for both years, load them into a Neo4j database, and see what I could do with them.

The site has no API, but the HTML data on the site is very well structured and it was easy to write a ruby script using nokogiri to crawl the site and produce CSV files.  Since there are a lot of data and since I would be running the script many times I created a local cache for the HTML pages so that whenever I run the script it uses what it already had.

It turns out that not only are there a lot of records (about 4 million residents for each year), but the data is quite variable.  After informally playing with the data I decided that to do any use ful analysis I would need to clean up the data first.  The first target: religion

At the start there were 24,258 distinct strings entered by census takers / residents.  To facilitate the cleaning I wrote a rake task which allowed me to quickly choose how the data should be normalized.  The task makes a query for all distinct strings from the `religion` property and the number of times that string occurs, sorts the result so that the most common values are first, and then presents a prompt asking for an alternative string.  An enumerated list is presented so that I can quickly choose a previously entered value.  Simply hitting return causes the value to be mapped to itself.  After a series of inputs the prompt looks like this:


    Choices:
    0> Roman Catholic
    1> Church of Ireland
    2> Presbyterian
    3> Catholic
    4> Methodist
    5> Church of England
    6> -
    7> Episcopalian
    8> Baptist
    9> Unitarian
    10> Reformed Presbyterian
    11> Congregationalist
    Current unmapped value: Presbeterian (2430 occurances)
    Suggestions:
     2>  Presbyterian (distance: 1)
     9>  Unitarian (distance: 7)
    (7615 more / 'QUIT' to quit) >

The suggestions come from finding the closest string (via the Levenshtein distance algorithm) from the data which has already been mapped and getting it's mapped value.

By the way, you can't believe how many ways that "Roman Catholic" is represented in this data.  From a simple "R C" to the specific "Catholic Commonly Described in Acts of Parliament As Roman Catholic".  Likely because of the wide range of dialects and education levels there's also "Roman Catholce", "Roman Caiholec", "Roman Catcklick", "Roman Katchrlick", and so so much more.  Though I think my favorite so far is "Romeman Catholic"

Each time the prompt is responded to a YAML file representing a `Hash` is saved with the origional strings as keys and the normalized strings as values.  This looks like:

    ---
    Roman Catholic: Roman Catholic
    Church of Ireland: Church of Ireland
    Presbyterian: Presbyterian
    R Catholic: Roman Catholic
    Catholic: Catholic
    R C: Roman Catholic
    Methodist: Methodist
    Irish Church: Church of Ireland
    Church of England: Church of England
    "-": "-"
    Catholic Church: Catholic

My [colleage](https://github.com/subvertallchris) on the neo4j gem project suggested building a prompt to quickly go through strings and do passes of yes/no on one particular religion.  I ended up doing this is the low-tech manner of filtering the list of strings for things like `rom` and `pres`, working on the results in a text editor, and then manually putting them into the YAML file.

Doing this I was able to make a lot of progress, but with thousands of unique strings to go through, it's still ongoing.  For now I've got enough to move onto standardizing other fields and then eventually I will be able to use the standardized data to do some analysis.  More to come...

