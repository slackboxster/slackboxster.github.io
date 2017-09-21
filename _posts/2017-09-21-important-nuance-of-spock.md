---
layout: post
title: Important Nuance of Spock Testing
---

I was having some trouble yesterday with a mock invocation that wasn't catching. After some experimentation with a wrong idea, I decided to look at [the Spock documentation on Interaction Based Testing](http://spockframework.org/spock/docs/1.0/interaction_based_testing.html). I very quickly came across the solution to my woes:

> all invocations on mock objects that occur while executing the when block will be matched against the interactions described in the then: block.

This innocent-seeming phrase is vitally important.

Consider the following code (I've simplified it for demonstration purposes):

```groovy
class A {
    isValid() { 
        //some validation code 
    }
}

class B {
    A a

    B(A a) {
        this.a = a        
    }

    isAValid() {
        a.isValid()
    }
}
```

This is a silly example, of course, but the kind of situation where you would have this structure is when A is an object whose validity depends on several conditions, of which one of those conditions has a significant amount of complexity, which you have abstracted into B. One advantage of this abstraction is that you can now mock B rather than have to test around all the complexity that would have remained in A if you had not abstracted it.


The first attempt I made at testing this structure was this: (I made this attempt because spock mocks require `when:` and `then:`, and I only wanted to use `expect:`).

```groovy
class BSpec extends Specification {
    
    void "test isAValid"() {
        setup:
        A mockA = Mock()

        when:
        B b = new B(a)

        then:
        b.isAValid()

        and:
        1 * mockA.isValid() >> true
        0 * _

    }
}
```

But this will not work. I could not understand why, until I read the abovementioned sentence. It is the `b.isAValid()` method that invokes the `a.isValid()` method, and that is being called in a `then:` block, after Spock is done tracking invocations. Deceptive, yet quite simple. I was trapped by my assumption that I wanted my `b.isAValid()` to assert on its own, and therefore would need to be in the `then:` block. Of course, the easy way around that is to just store the result of the call in a variable. A little more verbose, but at least it works. ;)

So all you have to do to make the test pass is:

```groovy
class BSpec extends Specification {
    
    void "test isAValid"() {
        setup:
        A mockA = Mock()

        when:
        boolean result = new B(a).isAValid()

        then:
        result

        and:
        1 * mockA.isValid() >> true
        0 * _
    }
}
```

So there you have it. If you have a Spock mock invocation that just won't catch, and you don't see any reason in your code why it shouldn't be happening, take another look and see if you have your mock-invoking calls coming from the `then:` block... If so, you haven't landed in a parallel universe where code doesn't compile properly, you just need to reorder your code. 

Happy coding, and keep it Groovy, everybody!
