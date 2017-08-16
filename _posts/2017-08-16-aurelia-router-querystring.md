---
layout: post
title: QueryString Parameters and the Aurelia Router
---

*This post forms an attempt to show a process of thinking through a problem, not just the solution. I think the process will be helpful to younger programmers. And maybe to more experienced programmers who want to see the intermediate steps to the solution, not just the solution. I also hope it encourages more programmers to look at the source code of libraries they use.*

I've been fiddling with some Aurelia Code. I basically want to be able to append a parameter to the route without having to reconfigure the route. In other words, I want to be able to do `router.navigate('/bookLists/24?page=2)` -- that is, specify a page on a bookList. But I have multiple pages on my application that will use pagination, and I don't want to have to reconfigure the route for each of them to have a page parameter. So I was a little confused.

Which brings me to an aside:
> I have a growing disdain for reading documentation. Most of the time I find documentation (even good documentation) leaves me feeling confused, and uncertain if my edge case will work. I find a growing tendency to look at source code for answers to questions I have about how to use certain libraries. I think this is part of a broader thought: In this world, far too much time is spent regurgitating information. The Internet is a vast library of the world's information, but a quick google search for an interesting topic will often reveal that much of that information is simply duplicating what Wikipedia says. If you combine that with a growing distrust of almost all media outlets, I think you find that there is a growing need to go to the source materials. In the case of the media, read the transcript of a speech given by the French President, rather than what a news article says about the speech. In the case of software development, read the source code of the library you are using, rather than trying to parse the (most likely) incomplete documentation.

Aside over, I did that with the aurelia router, because none of the google searches I could generate gave me results that actually answered my question. (Full disclosure: I think my google-fu is fairly poor). So I broke down and read [the source of the aurelia-router](https://github.com/aurelia/router/blob/master/src/router.js). Very quickly I was able to isolate the method that interested me:  

`navigateToRoute` calls `generate` to get a path that it can use in calling `navigate`:

```javascript
  navigateToRoute(route: string, params?: any, options?: any): boolean {
    let path = this.generate(route, params);
    return this.navigate(path, options);
  }
```

After doing some other (mostly irrelevant) stuff (well, I mean we can tell that it basically looks up the route, and if it can't find it, calls up to a parent router to check if the parent router has a route that matches our attempted navigation, and if nothing comes out of that, we say "Oh no, I can't find a route!"), the generate method uses the `_recognizer`'s `generate` method, before generating a `rootedPath` which I presume to be something that you can actually set `window.location.href` to. But that's not relevant to my question. Also, note that the use of the options parameter appears to relate exclusively to the absolute option, which is irrelevant to what we are doing. The only thing that is relevant is this `_recognizer` stuff.

```javascript
  generate(name: string, params?: any, options?: any = {}): string {
    let hasRoute = this._recognizer.hasRoute(name);
    if ((!this.isConfigured || !hasRoute) && this.parent) {
      return this.parent.generate(name, params);
    }

    if (!hasRoute) {
      throw new Error(`A route with name '${name}' could not be found. Check that \`name: '${name}'\` was specified in the route's config.`);
    }

    let path = this._recognizer.generate(name, params);
    let rootedPath = _createRootedPath(path, this.baseUrl, this.history._hasPushState, options.absolute);
    return options.absolute ? `${this.history.getAbsoluteRoot()}${rootedPath}` : rootedPath;
  }
```

A quick find in the code reveals that the `_recognizer` gets set in the `reset` method which is also called by the constructor:

```javascript
    this._recognizer = new RouteRecognizer();
```

So now we ask, what is a `RouteRecognizer`?

```javascript
import {RouteRecognizer} from 'aurelia-route-recognizer';
```

Oh, another library. Google finds me [the aurelia/route-recognizer repository](https://github.com/aurelia/route-recognizer/blob/master/src/route-recognizer.js) (my google-fu isn't that bad).

We want specifically to look at the `generate` method of the recognizer, and guess what I find in the DocBlock? The answer to my question! If you pass in extra parameters, they'll be dropped on the querystring! :)

```javascript
/**
  * Generate a path and query string from a route name and params object.
  *
  * @param name The name of the route.
  * @param params The route params to use when populating the pattern.
  *  Properties not required by the pattern will be appended to the query string.
  * @returns The generated absolute path and query string.
  */
  generate(name: string, params: Object): string {
```

One more thing -- is this comment out of date? Remember, the code is what runs on a system, not the comments, so don't trust them too far. (I won't belabor the point by exhaustively proving that this is actually done). Here's the relevant fragment to substantiate the comment's claim:

```javascript
    // remove params used in the path and add the rest to the querystring
    for (let param in consumed) {
      delete routeParams[param];
    }

    let queryString = buildQueryString(routeParams);
    output += queryString ? `?${queryString}` : '';

    return output;
```  

So now I know that if I want to call a route that has parameters, but I want to add extra ones, I can trust they will hit the query string. Or in other words, `router.navigate('#/books/24?page=2')` should be equivalent to `router.navigateToRoute('books', { id: 24, page: 2})`. Much more flexible. :)

As a last aside:
 > This whole exercise demonstrates the value of code that is clear. Because of the clarity of the aurelia code, I was able to answer a fairly involved technical question simply by looking at the code, without having to call one of the project's developers to ask my question. But you'll notice, apart from some very terse docblocks, the aurelia code is largely lacking in comments. It's clear enough that you don't need comments. I generally believe this to be the best way to go, because human nature all to easily changes code without changing even the comment one line above, thus creating a situation of conflicting information. Better to let the code explain itself than try to explain code today in a way that will confuse another programmer 6 months from now because your comment no longer reflects reality after you made "a quick change to test something" and forgot to change the comment once your test worked. Also remember that you yourself will essentially be "Another programmer" 6 months from now...