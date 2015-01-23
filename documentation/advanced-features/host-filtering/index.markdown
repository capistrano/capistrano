---
title: Host filtering
layout: default
---

You may encounter situations where you only want to deploy to a subset of
the servers defined in your configuration. For example, a single server or
set of servers may be misbehaving, and you want to re-deploy to just these
servers without deploying to every server.

You can use the *host filter* to restrict Capistrano tasks to only servers
that match a given set of hostnames.

If the filter matches no servers, no actions will be taken.

If you specify a filter, it will match servers that have the listed hostnames,
and it will run *all* the roles for each server. In other words, it only affects
the servers the task runs on, not what tasks are run on a server.

You can limit by role and by host; if you do this, the role filtering will
apply first. For example, lets say you filtered by the role `app`, then by
the hostnames `server1` and `server2`. Capistrano would first filter the
available servers to only those with the role `app`, then filter them
to look for servers with the hostname `server1` or `server2`. If only `server2`
had the role `app` (`server1` has some other role), then in this situation your
task would only run on `server2`.

### Specifying a host filter

There are three ways to specify the host filter.

#### Environment variable

Capistrano will read the host filter from the environment variable `HOSTS`
if it is set. You can set it inline:

{% highlight bash %}
HOSTS=server1,server2 cap production deploy
{% endhighlight %}

Specify multiple hosts by separating them with a comma.

#### In configuration

You can set the host filter inside your deploy configuration. For example,
you can set the following inside `config/deploy.rb`:

{% highlight ruby %}
set :filter, :host => %w{server1 server2}
{% endhighlight %}

Note that you specify the filter as an array rather than as a comma-separated
list of servers when using this method.

#### On the command line

In a similar way to using the environment variable, you can set the role
filter by specifying it as a command line argument to `cap`:

{% highlight bash %}
cap --hosts=server1,server2 production deploy
{% endhighlight %}

Like the environment variable method, specify multiple servers by separating
them with a comma.
