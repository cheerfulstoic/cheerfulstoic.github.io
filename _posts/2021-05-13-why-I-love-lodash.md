---
title: Why I Love Lodash
layout: single
toc: true
date: 2021-05-13 22:26
categories:
- javascript
tags:
- javascript
---

I love [Lodash](https://lodash.com/), but I'm not here to tell you to use Lodash.  It's up to you to decide if a tool is useful for you or your project.  It will come down to the needs of the project (file size, browser/Node.js, how much you use it, etc...).  But my new team was surprised by my passion for it and so I wanted to share my thoughts.  Specifically: I want to focus in this post on those things which I like, including things which I think people often miss.

## Checking types

To start with something simple, let's look at identifying variable types.  I'll take the examples from [this post](https://dev.to/jmitchell38488/it-s-time-to-let-go-of-lodash-221f):

```javascript
Array.isArray(foo);

foo === null;

foo !== null && typeof foo === "object" && Object(foo) === {};

typeof foo === 'boolean'
```

All of that works, technically, but it's so inconsistent.  This is especially true of the third example checking if something is an object.  Such a check requires a deeper understanding of Javascript objects that not everybody has and it might not always be implemented correctly.

Also, regarding the last example for checking boolean, I should admit that I lied a bit: it isn't from the post I linked to!  The example they gave was: `Boolean(foo)`, but in the comments somebody pointed out that truthy values like `Boolean(1)` would return `true`.  For me, all of this is more complex and error prone than just doing:

```javascript
_.isArray(foo);
_.isNull(foo);
_.isObject(foo);
_.isBoolean(foo);
```

With those, I'm a lot less likely to come back to my code later because of a bug due to my understanding of type checking.

## Chaining

I very often have a need to transform a data structure in multiple steps:

```javascript
// Find adults, group by age (ten-year spans), and find if any in each group own a pet
let people = [{id: 1, name: 'Jane Doe', age: 33, ownsPet: true}, ...]

let adults = people.filter((person) => person.age >= 18)
let groupedAdults = adults.reduce((result, adult) => {
  let groupingNumber = Math.floor(adult.age / 10) * 10;
  if (result[groupingNumber] == null) { result[groupingNumber] = [] }
  result[groupingNumber].push(adult);
  return(result);
}, {})
let petExistsForGroup = {}
Object.keys(groupedAdults).forEach((key) => {
  let petExists = false;
  groupedAdults[key].forEach((adult) => {
    petExists = petExists || adult.ownsPet;
  })

  petExistsForGroup[key] = petExists;
})
```

Seem about what you expect from Javascript?  Maybe not the nicest bit of code in the world, but it does the job.  Good enough, right?  Let's try using Lodash chaining, along with other helpers:

```javascript
let people = [{id: 1, name: 'Jane Doe', age: 33, ownsPet: true}, ...]

let petExistsForGroup =
  _(people)
    .filter((person) => person.age >= 18)
    .groupBy((adult) => Math.floor(adult.age / 10) * 10)
    .mapValues((adults) => _.some(adults, 'ownsPet'))
    .value()

```

It's another way of thinking, right?  Shorter for sure, but also higher-level and more declarative.  The mechanics drop away and we're left with our code business logic.

This is one of the big things that I love about Lodash.  If you take the time to learn it, it allows you to work at a higher level, not worrying about small details.  For that reason I enjoy just browsing through the documentation sometimes, like browsing an IKEA catalog and thinking to myself "oooh, that could be nice...".  It's good to know what's there, even if you're not sure why you would use it.  I've found `_.partition` surprisingly useful!

Did I choose an example that plays to Lodash's strengths?  Absolutely!  But I challenge anybody to make the first example shorter while still being readable using pure Javascript.

It's also worth mentioning that Lodash has methods which basically just duplicate the functionality of their javascript counterparts (e.g. `_.concat` or `_.fill`).  This maybe seems unnecessary to people who are skeptical of Lodash, but remember that because Lodash offers chaining it needs to provide all of the potential methods that you might use.

## Iteratee shorthand

You may have noted the `_.some(adults, 'ownsPet')` bit above.  By passing in a string instead of a function, Lodash automatically uses an identity function.  This would be the equivilent of: `_.some(adults, (adult) => adult.ownPet)`.  True the second version isn't much longer, but the first is more at-a-glance readable.

But it doesn't stop there!  You can use the string syntax for nested paths:

```javascript
let things = [{name: 'Car', owner: {contactDetails: {phoneNumber: '123-456-7890', email: 'me@thingowner.com'}}}, ...]

_.map(things, 'owner.contactDetails.phoneNumber')
_.find(things, ['owner.contactDetails.email', 'me@thingowner.com'])
// ... more?
```

Not only does it provide a simple syntax for going deep, but if any step along the way doesn't exist (say, the `contactDetails` field is `null` or `undefined`), it will simply return `undefined`, similar to Javascript's `?.` operator.

## Javascript as the "write it yourself" language

Having been a Ruby programmer for a long time, I will often search for a way to manipulate some data in Ruby and very often there will by either a simple function to call or a discussion on how to write something concise but readable.  Whenever I'm working with Javascript, however, the answer very often seems to be either "write it yourself" or "copy a solution".  Here is a small selection that I gathered relatively quickly:

 * [How to subtract one array from another, element-wise, in javascript](https://stackoverflow.com/questions/45342155/how-to-subtract-one-array-from-another-element-wise-in-javascript) (`_.difference`)
 * [Getting a random value from a JavaScript array](https://stackoverflow.com/questions/4550505/getting-a-random-value-from-a-javascript-array) (`_.sample`)
 * [Sorting an array of objects by property values](https://stackoverflow.com/questions/979256/sorting-an-array-of-objects-by-property-values)(`_.sortBy`)
 * [How do I zip two arrays in JavaScript?](https://stackoverflow.com/questions/22015684/how-do-i-zip-two-arrays-in-javascript) (`_.zip`)

Sometimes you'll even get answers, like with [How to randomize (shuffle) a JavaScript array?](https://stackoverflow.com/questions/2450954/how-to-randomize-shuffle-a-javascript-array) (`_.shuffle`) which talks about the ideal algorithm (the "Fisher-Yates (aka Knuth) Shuffle" in this case).  Academically I enjoy learning about different algorithms, but when I'm trying to get higher-level done I just want something that works well.  I'm not sure if the performance of my sorting / shuffling algorithm has ever been a practical concern.

Some of these solutions are very complex, but some are pretty simple, even if they aren't as simple as just calling a Lodash function.  So what's so bad about using pure Javascript to zip two arrays?

```javascript
a.map(function(e, i) {
  return [e, b[i]];
});
```

The problem, as I see it, is that it:

 * is not immediately obvious
 * is a distraction from the task that you're trying to accomplish
 * leaves room for custom functions to be implemented in broken, odd, or inconsistent ways

The more time that I've spent programming, the less I trust myself and the more I trust open source solutions which have been developed and vetted by a community.  Also, most of my experience in programming comes from working in teams.  When working in teams the goal is for code to be readable and maintainable.  If you scatter the codebase with versions of functions that have been implemented over and over again elsewhere (almost certainly in a better way), you're generally just spending extra time and slowing others down.

Of course there's nothing wrong with enjoying the challenge of writing your own algorithms!  I just think it's much better done in https://exercism.io rather than your codebase.

## Being fair to Javascript

All of the above said, Javascript has come a long way in recent years.  Some examples:

 * I love the fact that I can use `{a: 'b', ...obj}` instead of `_.merge({a: 'b'}, obj)` (as long as it's not part of a larger flow which works better as a Lodash chain)
 * I often want to return the unique items from an array, and so `[...new Set(array)]` provides a reasonably readable solution (if only slightly more verbose and less obvious than `_.uniq(array)`)
 * In ES2019 arrays now have `flat()` and `flatMap()` functions

## Summing up

Lodash is self-consistent and holistically designed.  "The principle of least astonishment" is a way to not get bogged down in details, be less prone to errors, and increase overall developer happiness.  When bringing in a new developer it's easier for them to come up-to-speed quickly.

And my favorite response to "You Don't Need Lodash":

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">I guess not, but I want it. &quot;You don&#39;t need Lodash/Underscore&quot; <a href="https://t.co/keLJ43U0pa">https://t.co/keLJ43U0pa</a></p>&mdash; Tero Parviainen (@teropa) <a href="https://twitter.com/teropa/status/692280179666898944?ref_src=twsrc%5Etfw">January 27, 2016</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script> 

