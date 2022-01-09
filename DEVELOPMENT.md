Thanks for helping build Capistrano! Here are the development practices followed by our community.

* [Who can help](#who-can-help)
* [Contributing documentation](#contributing-documentation)
* [Setting up your development environment](#setting-up-your-development-environment)
* [Coding guidelines](#coding-guidelines)
* [Submitting a pull request](#submitting-a-pull-request)
* [Managing GitHub issues](#managing-github-issues)
* [Reviewing and merging pull requests](#reviewing-and-merging-pull-requests)

## Who can help

Everyone can help improve Capistrano. There are ways to contribute even if you aren’t a Ruby programmer. Here’s what you can do to help the project:

* adding to or fixing typos/quality in documentation
* adding failing tests for reported bugs
* writing code (no contribution is too small!)
* reviewing pull requests and suggesting improvements
* reporting bugs or suggesting new features (see [CONTRIBUTING.md][])

## Contributing documentation

Improvements and additions to Capistrano's documentation are very much appreciated. The official documention is stored in the `docs/` directory as Markdown files. These files are used to automatically generate the [capistranorb.com](http://capistranorb.com/) website, which is hosted by GitHub Pages. Feel free to make changes to this documentation as you see fit. Before opening a pull request, make sure your documentation renders correctly by previewing the website in your local environment. Refer to [docs/README.md][] for instructions.

## Setting up your development environment

Capistrano is a Ruby project, so we expect you to have a functioning Ruby environment. To hack on Capistrano you will further need some specialized tools to run its test suite.

Make sure to install:

* [Bundler](https://bundler.io/)
* [Vagrant](https://www.vagrantup.com/)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (or another [Vagrant-supported](https://docs.vagrantup.com/v2/getting-started/providers.html) VM host)


### Running tests

Capistrano has two test suites: an RSpec suite and a Cucumber suite. The RSpec suite handles quick feedback unit specs. The Cucumber suite is an integration suite that uses Vagrant to deploy to a real virtual server.

```
# Ensure all dependencies are installed
$ bundle install

# Run the RSpec suite
$ bundle exec rake spec

# Run the Cucumber suite
$ bundle exec rake features

# Run the Cucumber suite and leave the VM running (faster for subsequent runs)
$ bundle exec rake features KEEP_RUNNING=1
```

### Report failing Cucumber features!

Currently, the Capistrano CI build does *not* run the Cucumber suite. This means it is possible for a failing Cucumber feature to sneak in without being noticed by our continuous integration checks.

**If you come across a failing Cucumber feature, this is a bug.** Please report it by opening a GitHub issue. Or even better: do your best to fix the feature and submit a pull request!

## Coding guidelines

This project uses [RuboCop](https://github.com/bbatsov/rubocop) to enforce standard Ruby coding guidelines.

* Test that your contributions pass with `rake rubocop`
* Rubocop is also run as part of the full test suite with `rake`
* Note the CI build will fail and your PR cannot be merged if Rubocop finds errors

## Submitting a pull request

Pull requests are awesome, and if they arrive with decent tests, and conform to the guidelines below, we'll merge them in as soon as possible, we'll let you know which release we're planning them for (we adhere to [semver](http://semver.org/) so please don't be upset if we plan your changes for a later release).

Your code should conform to these guidelines:

 * The code is MIT licensed, your code will fall under the same license if we merge it.
 * We can't merge it without a [good commit message](http://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message). If you do this right, Github will use the commit message as the body of your pull request, double win.
 * If you are making an improvement/fix for an existing issue, make sure to mention the issue number (if we have not yet merged it )
 * Add an entry to the `CHANGELOG` under the `### master` section, but please don't mess with the version.
 * If you add a new feature, please make sure to document it by modifying the appropriate Markdown files in `docs/` (see [contributing documentation](#contributing-documentation), above). If it's a simple feature, or a new variable, or something changed, it may be appropriate simply to document it in the generated `Capfile` or `deploy.rb`, or in the `README`.
 * Take care to squash your commit into one single commit with a good message, it saves us a lot of work in maintaining the CHANGELOG if we can generate it from the commit messages between the release tags!
 * Tests! It's tricky to test some parts of Capistrano, but do your best, it might just serve as a starting point for us to build a reliable test on top of, and help us understand where you are coming from.

## Managing GitHub issues

The Capistrano maintainers will do our best to review all GitHub issues. Here’s how we manage issues:

1. Issues will be acknowledged with an appropriate label (see below).
2. Issues that are duplicates, spam, or irrelevant (e.g. wrong project), or are questions better suited for Stack Overflow (see [CONTRIBUTING.md][]) will be closed.
3. Once an issue is fixed or resolved in an upcoming Capistrano release, it will be closed and assigned to a GitHub milestone for that upcoming version number.

The maintainers do not have time to fix every issue ourselves, but we will gladly accept pull requests, especially for issues labeled as "you can help" (see below).

### Issue labels

Capistrano uses these GitHub labels to categorize issues:

* **bug?** – Could be a bug (not reproducible or might be user error)
* **confirmed bug** – Definitely a bug
* **new feature** – A request for Capistrano to add a feature or work differently
* **chore** – A TODO that is neither a bug nor a feature (e.g. improve docs, CI infrastructure, etc.)

Also, the Capistrano team will sometimes add these labels to facilitate communication and encourage community feedback:

* **discuss!** – The Capistrano team wants more feedback from the community on this issue; e.g. how a new feature should work, or whether a bug is serious or not.
* **you can help!** – We want the community to help by submitting a pull request to solve a bug or add a feature. If you are looking for ways to contribute to Capistrano, start here!
* **needs more info** – We need more info from the person who opened the issue; e.g. steps to reproduce a bug, clarification on a desired feature, etc.

*These labels were inspired by Daniel Doubrovkine’s [2014 Golden Gate Ruby Conference talk](http://confreaks.tv/videos/gogaruco2014-taking-over-someone-else-s-open-source-projects).*

## Reviewing and merging pull requests

Pull requests and issues follow similar workflows. Before merging a pull request, the Capistrano maintainers will check that these requirements are met:

* All CI checks pass
* Significant changes in behavior or fixes mentioned in the CHANGELOG
* Clean commit history
* New features are documented
* Code changes/additions are tested

If any of these are missing, the **needs more info** label is assigned to the pull request to indicate the PR is incomplete.

Merging a pull request is a decision entrusted to the maintainers of the Capistrano project. Any maintainer is free to merge a pull request if they feel the PR meets the above requirements and is in the best interest of the Capistrano community.

After a pull request is merged, it is assigned to a GitHub milestone for the upcoming version number.


[CONTRIBUTING.md]: https://github.com/capistrano/capistrano/blob/master/CONTRIBUTING.md
[docs/README.md]: https://github.com/capistrano/capistrano/blob/master/docs/README.md
