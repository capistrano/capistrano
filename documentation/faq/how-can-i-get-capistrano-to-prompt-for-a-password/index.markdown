---
title: How can I get Capistrano to prompt for a password?
layout: default
---

Password authentication can be done via `set` and `ask` in your deploy environment file (e.g.: config/environments/production.rb)

{% highlight ruby %}
    # Capistrano 3.0.x
		set :password, ask('Server password:', nil)
		server 'server.domain.com', user: 'ssh_user_name', port: 22, password: fetch(:password), roles: %w{web app db}
{% endhighlight %}
