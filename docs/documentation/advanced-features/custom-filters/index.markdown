---
title: Custom Filters
layout: default
---

Custom filters (specifically, Custom On-Filters) limit the hosts that are being
deployed to, in the same way as
[Host](/documentation/advanced-features/host-filtering/) and
[Role](/documentation/advanced-features/role-filtering/) filters, but the exact
method used to filter servers is up to the user of Capistrano.

Filters may be added to Capistrano's list of filters by using the
`Configuration#add_filter` method.  Filters must respond to a `filter` method,
which will be given an array of Servers, and should return a subset of that
array (the servers which passed the filter).

`Configuration#add_filter` may also take a block, in which case the block is
expected to be unary. The block will be passed an array of servers, and is
expected to return a subset of that array.

Either a block or object may be passed to `add_filter`, but not both.

### Example

You may have a large group of servers that are partitioned into separate regions
that correspond to actual geographic regions. Usually, you deploy to all of
them, but there are cases where you want to deploy to a specific region.

Capistrano recognizes the concept of a server's *role* and *hostname*, but has
no concept of a *region*. In this case, you can construct your own filter that
selects servers based on their region. When defining servers, you may provide
them with a `region` property, and use that property in your filter.


The filter could look like this:

`config/deploy.rb`

    class RegionFilter

      def initialize(regions)
        @regions = Array(regions)
      end

      def filter(servers)
        servers.select {|server|
          region = server.fetch(:region)
          region && @regions.include?(region)
        }
      end

    end

You would add servers like this:

`config/deploy/production.rb`

    server('123.123.123.123', region: 'north-east')
    server('12.12.12.12',     region: 'south-west')
    server('4.5.6.7',         region: 'mid-west')

To tell Capistrano to use this filter, you would use the
`Configuration#add_filter` method. In this example, we look at the `REGIONS`
environment variable, and take it to be a comma-separated list of regions that
we're interested in:

`config/deploy.rb`

    if ENV['REGIONS']
      regions = ENV['REGIONS'].split(',')
      filter = RegionFilter.new(regions)
      Capistrano::Configuration.env.add_filter(filter)
    end

We obtain a list of regions to deploy to from the environment variable,
construct a new filter with those regions, and add it to Capistrano's list of
filters.

Of course, we're not limited to regions. Any time you can classify or partition
a list of servers in a way that you only want to deploy to some of them, you can
use a custom filter. For another example, you might arbitrarily assign your
servers to either an *A* group or a *B* group, and deploy a new version only to
the *B* group as a simple variant of A/B Testing.
