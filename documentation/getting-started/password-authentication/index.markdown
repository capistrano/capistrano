---
title: Password Authentication
layout: default
---

Password authentication can be done via `set` and `ask` in your deploy environment file (e.g.: config/deploy/production.rb)

{% highlight ruby %}
set :password, ask('Server password', nil)
server 'server.domain.com', user: 'ssh_user_name', port: 22, password: fetch(:password), roles: %w{web app db}
{% endhighlight %}
