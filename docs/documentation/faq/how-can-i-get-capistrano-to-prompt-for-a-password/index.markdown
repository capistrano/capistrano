---
title: How can I get Capistrano to prompt for a password?
layout: default
---

Password authentication can be done via `ask` in your deploy environment file (e.g.: config/environments/production.rb)

```ruby
    # Capistrano > 3.2.0 supports echo: false
		ask(:password, nil, echo: false)
		server 'server.domain.com', user: 'ssh_user_name', port: 22, password: fetch(:password), roles: %w{web app db}
```
