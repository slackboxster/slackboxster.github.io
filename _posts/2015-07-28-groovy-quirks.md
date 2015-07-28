---
layout: post
title: Groovy Quirks
---

I guess this is probably a good idea -- to briefly journal issues I come across here. Maybe they will benefit someone else. Maybe they will benefit me in the future. 
TODO: turn this into a blog category with it's own page that links people in here... ;)

So I have a function with a default parameter. This default parameter is a list with one item. A list because the user can specify a list with more than one item. This one item is a bit of a magic number. It's 200 -- you can probably guess why. :) But this doesn't work:

    static final MAGIC_NUMBERS = [200]

    Thing getThing(magicNumbers = MAGIC_NUMBERS) {
        doStuffWithMagicNumbers(magicNumbers)
    }

It appears, based on [this stackoverflow post](http://stackoverflow.com/questions/2065937/how-to-supply-value-to-an-annotation-from-a-constant-java), that the java constant thing doesn't like arrays -- probably because the thing that is constant is the array pointer, so it's a constant, but it doesn't really work. And perhaps it doesn't work in a default parameter cause ain't nobody got time for dereffing pointers...

You can hit me at my contact page if you want to tell me I'm daft. But if you have the same problem, sorry. I don't know what's wrong. :/
