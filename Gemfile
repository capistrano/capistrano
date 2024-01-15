source "https://rubygems.org"

# Specify your gem's dependencies in capistrano.gemspec
gemspec

gem "mocha"
gem "rspec"
gem "rspec-core", "~> 3.4.4"

group :cucumber do
  # Latest versions of cucumber don't support Ruby < 2.1
  # rubocop:disable Bundler/DuplicatedGem
  if Gem::Requirement.new("< 2.1").satisfied_by?(Gem::Version.new(RUBY_VERSION))
    gem "cucumber", "< 3.0.1"
  else
    gem "cucumber"
  end
  # rubocop:enable Bundler/DuplicatedGem
end

# Latest versions of net-ssh don't support Ruby < 2.2.6
if Gem::Requirement.new("< 2.2.6").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  gem "net-ssh", "< 5.0.0"
end

# Latest versions of public_suffix don't support Ruby < 2.1
if Gem::Requirement.new("< 2.1").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  gem "public_suffix", "< 3.0.0"
end

# Latest versions of i18n don't support Ruby < 2.4
if Gem::Requirement.new("< 2.4").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  gem "i18n", "< 1.3.0"
end

# Latest versions of rake don't support Ruby < 2.2
if Gem::Requirement.new("< 2.2").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  gem "rake", "< 13.0.0"
end

# We only run danger and rubocop on a new-ish ruby; no need to install them otherwise
if Gem::Requirement.new("> 2.4").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  gem "base64"
  gem "danger"
  gem "psych", "< 4" # Ensures rubocop works on Ruby 3.1
  gem "racc"
  gem "rubocop", "0.48.1"
end
