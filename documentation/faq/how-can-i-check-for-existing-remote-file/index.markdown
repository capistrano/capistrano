---
title: How can I check for existing remote file?
layout: default
---

The `test` tehod is best used for file checking with bash conditionals

{% highlight ruby %}
        if test("[ -f /tmp/foo ]")
            # do stuff
        end
{% endhighlight %}

