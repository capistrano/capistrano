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
* `:primary` - a boolean that indicates whether the server should be considered primary or
  not.

The values of `:user`, `:password` and `:port` if not specified will default to the same
values contained in the `:ssh_options` global variable of the stage. If this is not
specified then SSH will fallback to any settings in your local `~/.ssh/config`

<div class="alert-box alert">The :user and :port properties are treated somewhat
differently to the other properties: They are <b>not</b> merged as described below. If you
define multiple servers with different users or ports then <b>multiple</b> instances of
the server will be created. This is usually not what is expected.  It is recommended to
specify the user and port for all servers in the stage variable :ssh_config.  This
behaviour is currently under review and may be changed in future.  </div>


### Custom Properties

When using Capistrano as a general purpose deployment framework (above and beyond it's
traditional use for Rails deployments) it becomes important to be able to store additional
parameters. You can think of Capistrano as an _MVC_ framework for deployments, where the
stage file (representing all the relationships between application components) is the
_Model_, the tasks (enabling model changes to be actioned) are the _Controllers_, and the
actual physical embodiments (typically configuration files on running servers) are the
_Views_.

### Property setting in Complex Configurations

As configurations involve more servers it helps to be able to define a set of
properties at the role level, and have those be overridden by a later definition at the
server level. This keeps your configuration as DRY as possible. A typical requirement is
defining a set of Redis servers which all have the same port parameter and are all slaves
except for one which is the master.

To allow this properties can be set at both the _Server_ and _Role_ level. The guiding
principle is that the properties are _merged_ and that __the last definition wins__.
In practice we finesse this slightly depending on the type of the properties value:

* _scalar_ values, such as the `:user` string will be overridden
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

The following example shows a configuration with multiple redis and sentinel roles on the
same server:

```ruby
server 'dev.local', roles: %w{db web redis sentinel worker}, primary: true,
    redis: [ { name: 'resque', port: 6379, db: 0, downtime: 10, master: true },
             { name: 'resque', port: 6380, db: 0, downtime: 10 } ],
    sentinel: [ { port: 26379 }, { port: 26380 }, { port: 26381 } ]
```

These properties can be accessed in the ordinary way, but to assist in obtaining them you
can use the `role_properties()` function.

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
The `roles()` method takes one or more role names (or an array of roles) and returns an array of `Capistrano::Configuration::Server` objects that belong to those roles. It yields a `host` variable which has the following:

* `hostname` - a String
* `properties` - the configuration hash-like object
* `properties.keys` - the names of properties above
* `roles` - a Set of role names as symbols
* `primary` - the name of the host if it has the :primary property set to true

Note that the `host.keys` property which seems to be an empty array!

The servers produced by a roles() method are NOT filtered.

#### The `role_properties()` Method

This takes a list of roles (followed by an optional [Property
Filter](/documentation/advanced-features/property-filtering)) and returns an array of
hosts and their properties:

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
