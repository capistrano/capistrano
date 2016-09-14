---
title: Filtering
layout: default
---

Filtering is the term given to reducing the entire set of servers declared in a stage file
to a smaller set. There are three types of filters used in Capistrano (Host, Role and
Property) and they take effect in two quite different ways because of the two distinct
uses to which the declarations of servers, roles and properties are put in tasks:

* To determine _configurations_: typically by using the `roles()`, `release_roles()` and
  `primary()` methods. Typically these are used outside the scope of the `on()` method.

* To _interact_ with remote hosts using the `on()` method

An illustration of this would be to create a `/etc/krb5.conf` file containing the list of
available KDC's by using the list of servers returned by `roles(:kdc)` and then uploading
it to all client machines using `on(roles(:all)) do upload!(file) end`

A problem with this arises when _filters_ are used. Filters are designed to limit the
actual set of hosts that are used to a subset of those in the overall stage, but how
should that apply in the above case?

If the filter applies to both the _interaction_ and _configuration_ aspects, any configuration
files deployed will not be the same as those on the hosts excluded by the filters. This is
almost certainly not what is wanted, the filters should apply only to the _interactions_
ensuring that any configuration files deployed will be identical across the stage.

So we define two different categories of filter, the interaction ones which are called _On-Filters_
and the configuration ones which are _Property-Filters_

### On-Filtering

On-filters apply only to the `on()` method that invokes SSH. There are two default types:

* [Host Filters](/documentation/advanced-features/host-filtering/), and

* [Role Filters](/documentation/advanced-features/role-filtering/)


In both the above cases, when filters are specified using comma separated lists, the final
filter is the _union_ of all of the components. However when multiple filters are declared
the result is the _intersection_.

This means that you can filter by both role and host but you will get the _intersection_
of the servers. For example, lets say you filtered by the role `app`, then by
the hostnames `server1` and `server2`. Capistrano would first filter the
available servers to only those with the role `app`, then filter them
to look for servers with the hostname `server1` or `server2`. If only `server2`
had the role `app` (`server1` has some other role), then in this situation your
task would only run on `server2`.

Custom filters may also be added; see
[Custom Filters](/documentation/advanced-features/custom-filters/).

### Property-Filtering

Property-filters select servers based on the value of their properties alone and
are specified by options passed to the `roles()` method (and implicitly in methods
like `release_roles()` and `primary()`)

An example of that is the 'no_release' property and it's use in the `release_roles()` method.

See the [documentation](/documentation/advanced-features/property-filtering/) for
details
