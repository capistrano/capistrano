source "http://rubygems.org"

# Specify your gem's dependencies in capistrano.gemspec
gemspec

#
# Development Dependencies from the Gemfile
# are merged here.
#
group :development do
  gem "rake"

  unless RUBY_VERSION >= "1.9"
    gem "pry", "0.9"
  else
    gem "pry"
  end
end
