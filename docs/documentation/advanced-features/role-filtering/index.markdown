---
title: Role filtering
layout: default
---

You may have situations where you only want to deploy to servers matching
a single role. For example, you may have changed some aspect of how the web
role works, but don't want to trigger a deployment to your database servers.

You can use the *role filter* to restrict Capistrano tasks to only servers
match a given role or roles.

If the filter matches no servers, no actions will be taken.

If you specify a filter, it will match any servers that have that role, but
it will _only_ run the tasks for that role, not for any other roles that
server may have. For example, if you filtered for servers with the `web` role,
and a server had both the `web` and `db` role, only the `web` role would
be executed on it.

### Specifying a role filter

There are three ways to specify the role filter.

#### Environment variable

Capistrano will read the role filter from the environment variable `ROLES`
if it is set. You can set it inline:

```bash
ROLES=app,web cap production deploy
```

Specify multiple roles by separating them with a comma.

#### In configuration

You can set the role filter inside your deploy configuration. For example,
you can set the following inside `config/deploy.rb`:

```ruby
set :filter, :roles => %w{app web}
```

Note that you specify the filter as an array rather than as a comma-separated
list of roles when using this method.

Note that the keyname `:role` is also supported.

#### On the command line

In a similar way to using the environment variable, you can set the role
filter by specifying it as a command line argument to `cap`:

```bash
cap --roles=app,web production deploy
```

Like the environment variable method, specify multiple roles by separating them
with a comma.

### Using Regular Expressions

Since role names are Ruby symbols they can legitimately contain any characters. However to
allow multiple of them to be specified on one line we use the comma as a separator.

To use a regular expression for a role filter begin and end the string with '/'. Because
of the above these regular expressions may not contain a comma.
