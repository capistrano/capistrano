---
title: How can I check for existing remote file?
layout: default
---

The `test` method is best used for file checking with bash conditionals

```ruby
        if test("[ -f /tmp/foo ]")
            # do stuff
        end
```

