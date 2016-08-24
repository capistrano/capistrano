---
layout: default
title: Validation of variables
---

To validate a variable, each time before it is set, define a validation:

```ruby
validate :some_key do |key, value|
  if value.length < 5
    raise Capistrano::ValidationError, "Length of #{key} is too short!"
  end
end
```

Multiple validations can be assigned to a single key. Validations will be executed in the order of registration.
