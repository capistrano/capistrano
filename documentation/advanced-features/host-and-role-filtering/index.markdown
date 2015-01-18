---
title: Host and Role Filtering
layout: default
---

Capistrano enables the declaration of servers and roles, each of which may have properties
associated with them.  Tasks are then able to use these definitions in two distinct ways:

* To determine _configurations_: typically by using the `roles()`, `release_roles()` and
  `primary()` methods. Typically these are used outside the scope of the `on()` method.

* To _interact_ with remote hosts using the `on()` method

An example of the two would be to create a `/etc/krb5.conf` file containing the list of
available KDC's by using the list of servers returned by `roles(:kdc)` and then uploading
it to all client machines using `on(roles(:all)) do upload!(file) end`

A problem with this arises when _filters_ are used. Filters are designed to limit the
actual set of hosts that are used to a subset of those in the overall stage, but how
should that apply in the above case?

If the filter applies to both the _interaction_ and _configuration_ aspects, any configuration
files deployed will not be the same as those on the hosts excluded by the filters. This is
almost certainly not what is wanted, the filters should apply only to the _interactions_
ensuring that any configuration files deployed will be identical across the stage.

Another type of filtering is done by defining properties on servers and selecting on that
basis. An example of that is the 'no_release' property and it's use in the
`release_roles()` method. To distinguish these two types of filtering we name them:

* On-Filtering
    Specified in the following ways:
    * Via environment variables HOSTS and ROLES
    * Via command line options `--hosts` and `--roles`
    * Via the `:filter` variable set in a stage file
* Property-Filtering
    These are specified by options passed to the `roles()` method (and implicitly in methods
    like `release_roles()` and `primary()`)

To increase the utility of On-Filters they can use regular expressions:
* If the host name in a filter doesn't match `/^[-A-Za-z0-9.]+$/` (the set of valid characters
    for a DNS name) then it's assumed to be a regular expression.
* Since role names are Ruby symbols they can legitimately contain any characters. To allow multiple
    of them to be specified on one line we use the comma. To use a regexp for a role filter begin
    and end the string with '/'. These may not contain a comma.

When filters are specified using comma separated lists, the final filter is the _union_ of
all of the components. However when multiple filters are declared the result is the
_intersection_.
