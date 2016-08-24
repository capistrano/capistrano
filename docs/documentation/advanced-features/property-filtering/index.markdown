---
title: Property Filtering
layout: default
---

Options may be passed to the `roles()` method (and implicitly in methods like
`release_roles()` and `primary()`) that affect the set of servers returned. These options
take the form of a Hash passed as the last parameter.  Each of the key/value pairs in the
hash are evaluated in the sequence they are declared and if all are true for a specific
server then the server will be returned. The keys must always be symbols which have the
following meaning:

* `:filter`, or `:select`: The value is either a property keyname or a lambda which is
  called with the server as parameter.  The value must return true for the server to be
  included.

* `:exclude`: As above but the value must return false for the server to be included.

* Any other symbol is taken as a server property name whose value must equal the given value.
  A lambda will not be called if one is supplied!

### Examples

```ruby
server 'example1.com', roles: %w{web}, active: true
server 'example2.com', roles: %w{web}
server 'example3.com', roles: %w{app web}, active: true
server 'example4.com', roles: %w{app}, primary: true
server 'example5.com', roles: %w{db}, no_release: true, active:true

task :demo do
  puts "All active release roles: 1,3"
  release_roles(:all, filter: :active).each do |r|
    puts "#{r.hostname}"
  end
  puts "All active roles: 1,3,5"
  roles(:all, active: true).each do |r|
    puts "#{r.hostname}"
  end
  puts "All web and db roles with selected names: 2,3"
  roles(:web, :db, select: ->(s){ s.hostname =~ /[234]/}).each do |r|
    puts "#{r.hostname}"
  end
  puts "All with no active property: 2,4"
  roles(:all, active: nil).each do |r|
    puts "#{r.hostname}"
  end
  puts "All except active: 2,4"
  roles(:all, exclude: :active).each do |r|
    puts "#{r.hostname}"
  end
  puts "All primary: 4"
  roles(:all, select: :primary).each do |r|
    puts "#{r.hostname}"
  end
end
```
