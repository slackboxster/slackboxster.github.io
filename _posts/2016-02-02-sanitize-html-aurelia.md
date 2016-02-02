---
layout: post
title: Sanitizing HTML in Aurelia
---

I am developing a javascript application using [Aurelia](http://aurelia.io/). I had some trouble binding an HTML containing property to a div. The original code looks like:

```html
    <div class="terms">
        ${object.htmlProperty}
    </div>
```

Because the documentation for Aurelia is still developing, so I wasn't able to find a reference item for this. I ended up piecing together the things I needed to know.

[This StackOverflow question](http://stackoverflow.com/questions/28265949/bind-raw-html-in-aurelia) indicated that you need to use `innerHTML.bind`:

```html
    <div class="terms" innerHTML.bind="object.htmlProperty"></div>
```

It looked like everything was dandy just doing that -- I even injected `<script>alert('some alert stuff');</script>` into object.htmlProperty, and got no alerting. But the script tags were making it into the content unobstructed, so it looks like Chrome was keeping things safe, rather than Aurelia.

I had noticed [issue 7](https://github.com/aurelia/templating-binding/issues/7) and [pull request 19](https://github.com/aurelia/templating-resources/pull/19) from the aurelia repos, but was having a hard time figuring out what exactly they were saying with that. 

Eventually, I found [this commit from the pull request](https://github.com/AshleyGrant/templating-resources/commit/9353b477769cae4cd2a342f5bdb9c455a7d4bbca) which added a `sanitizeHTML` [value converter](http://jdanyow.github.io/aurelia-converters-sample/) to the repo. This was noted in the [0.10.0 release notes](http://blog.durandal.io/2015/03/25/aurelia-0-10-0-release-status/):
> Binding to innerHTML and innerText is now supported. You can use the new sanitizeHtml value converter along with this.

Once I got that detail I was able to get my html property bound and sanitized simply by doing:

```html
    <div class="terms" innerHTML.bind="object.htmlProperty | sanitizeHTML"></div>
```

From the pull requests there is also a way to specify a custom sanitizer, which, according to PR19, looks something like this:

```html
    <div innerHTML="value.bind: some.prop; sanitizer.call: mySanitizationFunction”
```

I have not tried this, but something like that should work.
