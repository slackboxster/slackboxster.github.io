---
layout: post
title: Grails 3 logging
---

While working on a Grails 3 application, I needed to access the logger inside a src/groovy class. The solution wasn't immediately obvious. I found the answer in [this Mr. Haki post](http://mrhaki.blogspot.com/2011/04/groovy-goodness-inject-logging-using.html), although I had to guess a bit because he doesn't specifically mention logback (or grails, for that matter) in that post. The answer is to add the `@Slf4j` annotation to the class.

src/main/groovy/com/package/name/MyUtil.groovy

```groovy
package com.package.name

import groovy.util.logging.Slf4j

@Slf4j
class MyUtil {
    ...
    def methodThatLogs() {
        log.info "Hello World"
    }
    ...
}
```

Thanks, Mr. Haki!