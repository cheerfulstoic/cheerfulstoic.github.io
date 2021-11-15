An exception is the occurrence of an abnormal condition during the execution of a software element. 
A failure is the inability of a software element to satisfy its purpose.   When a method/function has failed to fulfill it’s contract
An error is the presence in the software of some element not satisfying its specification.  A defect or a bug
...Note that failures cause exceptions... and are in general due to errors. 
—————

Note the difference in ruby between:
 * `raise` or `fail` -> `rescue` (for when a bad situation has happened that we want to deal with)
 * `throw` -> `catch` (for when we want to implement normal business logic by stopping early)

In Ruby, `raise` and `fail` are synonymous.  Many people use `raise`, but in some projects I've worked on `fail` is used generally and `raise` is only used when you've caught an exception and you are raising a new one.  Javascript doesn't have an alternative to `throw` (AFAIK), but it's useful to be thinking about this distinction.


We rarely have even a notion that a function has a contract.  Often functions are just a holding place for a bunch of code
A contract is about
 * the functions inputs
 * it’s output and/or any side-effects that might occur
 * invariants (i.e. only one of these three variables can be true at once)


I should learn about what it means to handle exceptions in Node.js.  Apparently the advice is to let the process crash, but WTF?  Ask Sentry team?

`finally`: What happens if there is an exception in `catch` or `finally`?  Gotta think about these things
