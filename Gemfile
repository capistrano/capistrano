source "https://rubygems.org"

# Specify your gem's dependencies in capistrano.gemspec
gemspec

group :cucumber do
  # Latest versions of cucumber don't support Ruby < 2.1
  # rubocop:disable Bundler/DuplicatedGem
  if Gem::Requirement.new("< 2.1").satisfied_by?(Gem::Version.new(RUBY_VERSION))
    gem "cucumber", "< 3.0.1"
  else
    gem "cucumber"
  end
  # rubocop:enable Bundler/DuplicatedGem
  gem "rspec"
  gem "rspec-core", "~> 3.4.4"
end

# Latest versions of net-ssh don't support Ruby < 2.2.6
if Gem::Requirement.new("< 2.2.6").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  gem "net-ssh", "< 5.0.0"
end

# Latest versions of public_suffix don't support Ruby < 2.1
if Gem::Requirement.new("< 2.1").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  gem "public_suffix", "< 3.0.0"
end

# Latest versions of i18n don't support Ruby < 2.1
if Gem::Requirement.new("< 2.1").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  gem "i18n", "< 1.3.0"
end

# We only run danger once on a new-ish ruby; no need to install it otherwise
if Gem::Requirement.new("> 2.4").satisfied_by?(Gem::Version.new(RUBY_VERSION))
  gem "danger"
end
