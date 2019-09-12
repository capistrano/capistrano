# Releasing

## Prerequisites

* You must have commit rights to the Capistrano repository.
* You must have push rights for the capistrano gem on rubygems.org.

## How to release

1. Run `bundle install` to make sure that you have all the gems necessary for testing and releasing.
2.  **Ensure all tests are passing by running `rake spec` and `rake features`.**
3. Determine which would be the correct next version number according to [semver](http://semver.org/).
4. Update the version in `./lib/capistrano/version.rb`.
5. Update the version in the `./README.md` Gemfile example (`gem "capistrano", "~> X.Y"`).
6. Commit the `version.rb` and `README.md` changes in a single commit, the message should be "Preparing vX.Y.Z"
7. Run `rake release`; this will tag, push to GitHub, and publish to rubygems.org.
8. Update the draft release on the [GitHub releases page](https://github.com/capistrano/capistrano/releases) to point to the new tag and publish the release
