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

### Specifying a host filter

There are three ways to specify the host filter.

#### Environment variable

Capistrano will read the host filter from the environment variable `HOSTS`
if it is set. You can set it inline:

```bash
HOSTS=server1,server2 cap production deploy
```

Specify multiple hosts by separating them with a comma.

#### In configuration

You can set the host filter inside your deploy configuration. For example,
you can set the following inside `config/deploy.rb`:

```ruby
set :filter, :hosts => %w{server1 server2}
```

Note that you specify the filter as an array rather than as a comma-separated
list of servers when using this method.

Note that the keyname `:host` is also supported.

#### On the command line

In a similar way to using the environment variable, you can set the role
filter by specifying it as a command line argument to `cap`:

```bash
cap --hosts=server1,server2 production deploy
```

Like the environment variable method, specify multiple servers by separating
them with a comma.

### Using Regular Expressions

If the host name in a filter doesn't match the set of valid characters for a DNS name
(Given by the regular expression `/^[-A-Za-z0-9.]+$/`) then it's assumed to be a regular
expression in standard Ruby syntax.

For example, if you had three servers named localrubyserver1, localrubyserver2, and amazonrubyserver1, but only wanted to deploy to localrubyserver*, you call Capistrano with a regex:

```bash
cap --hosts=^localrubyserver production deploy
```
