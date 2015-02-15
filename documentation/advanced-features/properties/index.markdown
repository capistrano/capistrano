---
title: Properties
layout: default
---

Server objects in Capistrano essentially consist of a name and a hash: The name is the DNS
name (or IP address) and the hash contains the 'Properties' of the server. These
properties are of two sorts: ones required by Capistrano (_Capistrano Properties_) and
ones available for use by the Application (_Custom Properties_). These share the same
namespace (there is only one underlying hash!) so the names of custom properties are
restricted.

### Capistrano Properties

The Capistrano properties are those used to SSH into the server and those that support the
basic _role_ functionality. These are:

* `:user` - the name of the SSH user for the server
* `:password` - for the SSH user
* `:port`  - the port number of the SSH daemon on the server
* `:roles` - an array of rolenames
* `:ssh_options` - a hash of SSH parameters (see below)
* `:primary` - a boolean that indicates whether the server should be considered primary or
  not.

The `:user`, `:port` and `:password` may be specified as follows:

* As part of the hostname in the form 'user@host:port' without a password,
* In the properties `:user`, `:password` and `:port`, and
* In the property `:ssh_options` (with the same keys)

#### Precedence

The SSH related properties are set with the following precedence, beginning with the
highest:

* Property declarations on the server or role. The last property declaration overrides all
  the previous server or role declarations
* Values specified in the hostname string
* Values in the server or role `:ssh_options` property
* The stage global variable `:ssh_options`
* The SSHKit backend `ssh_options`
* The settings in your local `~/.ssh/config` file

Note however that defaults taken from these places will _not_ be reflected back into the
server properties, so `host.user` will be nil if a lower precedence default is being used.

### Custom Properties

When using Capistrano as a general purpose deployment framework (above and beyond it's
traditional use for Rails deployments) it becomes important to be able to store additional
parameters. You can think of Capistrano as an _MVC_ framework for deployments, where the
stage file (representing all the relationships between application components) is the
_Model_, the tasks (enabling model changes to be actioned) are the _Controllers_, and the
actual physical embodiments (typically configuration files on running servers) are the
_Views_.

### Property Access from within Tasks

The properties on Capistrano server are accessible programmatically from a Capistrano
task. _Capistrano_ properties are available through methods on the host object itself and
_Custom_ properties via methods on the `properties` attribute of the host.

These methods have the expected names: `user`, `port` and so on. An exception is the
`ssh_config` which is available via the `netssh_options` method.

The following feature is new in Capistrano 3.3.6 and above.

Within the scope of an `on()` block, the host that is yielded is a *copy* of the underlying
host, which allows you to temporarily override any of the properties by calling the setter
method. An example is:

```ruby
on roles(:all) do |host|
  host.user = 'root'
  host.password = 'supersecret'
  execute :yum, 'makecache'
end
```

This temporarily sets the SSH user to 'root' (with an appropriate password) without
affecting the SSH user defined for the server in the configuration.

### Property setting in Complex Configurations

As configurations involve more servers it helps to be able to define a set of
properties at the role level, and have those be overridden by a later definition at the
server level. This keeps your configuration as DRY as possible. A typical requirement is
defining a set of Redis servers which all have the same port parameter and are all slaves
except for one which is the master.

To allow this properties can be set at both the _Server_ and _Role_ level. The guiding
principle is that the properties are _merged_ and that __the last definition wins__.
In practice we finesse this slightly depending on the type of the properties value:

* _scalar_ values will be overridden
* _hash_ values will have their keys merged with duplicate keys taking on
  the value of the last one.
* _array_ values will have subsequent entries appended to the array

#### Example of Server and Role Properties

The above Redis requirement can be met using the following declarations in the stage file:

```ruby
role :redis, %w{ r1.example.com r2.example.com r3.example.com }, redis: { port: 6379, master: false },
server 'r1.example.com', redis: { port: 6380, master: true }
```

#### Conventions for Role Properties

This is complicated by the fact that a single machine may serve multiple roles, and in
fact a single machine may need to do the same role twice! An example of this might be in a
development situation where you want a single machine to be the database server, a primary
Redis server and a slave Redis server.

To solve this problem we adopt a convention for the use of server properties:

* Server properties for a given role should be stored with the keyname equal to the role.
  The contents of the property can be a scalar, array or hash.

* Multiple occurrences of a role on the same server should have the contents be an array,
  in which the successive elements denote each instance.

The following example shows a configuration with multiple Redis and Sentinel roles on the
same server:

```ruby
server 'dev.local', roles: %w{db web redis sentinel worker}, primary: true,
    redis: [ { name: 'resque', port: 6379, db: 0, downtime: 10, master: true },
             { name: 'resque', port: 6380, db: 0, downtime: 10 } ],
    sentinel: [ { port: 26379 }, { port: 26380 }, { port: 26381 } ]
```

These properties can be accessed in the ordinary way, but to assist in obtaining them you
can use the `role_properties()` function (see below).

## Setting Properties

Properties can be set at both the role and server levels.

### Role Properties

The declaration of a role takes an array of server names and a trailing hash of
properties. By convention the first server in a role declaration is taken to be the
primary, but the  `:primary` property will not actually be set in such a case.

### Server Properties

The declaration of a server takes the name of a server and a trailing hash of properties.
One of those properties must be `:role` and have a value which is an array of role names.

### Accessing Properties

#### The `roles()` Method

The `roles()` method takes one or more role names (or an array of roles) followed by an
optional [Property Filter](/documentation/advanced-features/property-filtering)) and
returns an array of `Capistrano::Configuration::Server` objects that belong to those
roles. These have the following useful attributes:

* `hostname` - a String
* `properties.keys` - the names of the available properties
* `properties` - a hash-like object that stores the properties.
   It uses Ruby's 'method_missing' to provide a method for each valid key.
* `roles` - a Set of role names as symbols

The servers retrieved by this method are NOT filtered by any host or role filters.

#### The `role_properties()` Method

This takes a list of roles (followed by an optional [Property
Filter](/documentation/advanced-features/property-filtering)) and returns an array of
hashes containing the properties with the keys `:hostname` and `:role` added:

```ruby
task :props do
  rps = role_properties(:redis, :sentinel)
  rps.each do |props|
    puts props.inspect
  end
end

# Produces...

{:name=>"resque", :port=>6379, :db=>0, :downtime=>10, :master=>true, :role=>:redis, :hostname=>"dev.local"}
{:name=>"resque", :port=>6380, :db=>0, :downtime=>10, :role=>:redis, :hostname=>"dev.local"}
{:port=>26379, :role=>:sentinel, :hostname=>"dev.local"}
{:port=>26380, :role=>:sentinel, :hostname=>"dev.local"}
{:port=>26381, :role=>:sentinel, :hostname=>"dev.local"}
```

Alternatively you can supply a block and it will yield the hostname, role and properties:

```ruby
task :props_block do
  role_properties(:sentinel) do |hostname, role, props|
    puts "Host: #{hostname}, Role: #{role}, #{props.inspect}"
  end
end

# Produces...

Host: dev.local, Role: sentinel, {:port=>26379}
Host: dev.local, Role: sentinel, {:port=>26380}
Host: dev.local, Role: sentinel, {:port=>26381}
```

Note that unlike `on()` this function doesn't cause any remote execution to occur, it is purely for
configuration purposes.
