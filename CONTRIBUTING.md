**Hello and welcome!** Please look over this document before opening an issue or submitting a pull request to Capistrano.

* [If you’re looking for help or have a question](#if-youre-looking-for-help-or-have-a-question)
* [Reporting bugs](#reporting-bugs)
* [Requesting new features or improvements](#requesting-new-features-or-improvements)
* [Contributing code or documentation](#contributing-code-or-documentation)

## If you’re looking for help or have a question

**Check [Stack Overflow](http://stackoverflow.com/questions/tagged/capistrano) first if you need help using Capistrano.** You are more likely to get a quick response at Stack Overflow for common Capistrano topics. Make sure to tag your post with `capistrano` and/or `capistrano3` (not forgetting any other tags which might relate: rvm, rbenv, Ubuntu, etc.)

If you have an urgent problem you can also try [CodersClan](http://codersclan.net/?repo_id=325&source=contributing), which has a community of Capistrano experts dedicated to solve code problems for bounties.

When posting to Stack Overflow or CodersClan, be sure to include relevant information:

* Capistrano version
* Plugins and versions (capistrano-rvm, capistrano-bundler, etc.)
* Logs and backtraces

If you think you’ve found a bug in Capistrano itself, then…

## Reporting bugs

As much the Capistrano community tries to write good, well-tested code, bugs still happen. Sorry about that!

**In case you’ve run across an already-known issue, check the FAQs first on the [official Capistrano site](http://capistranorb.com).**

When opening a bug report, please include the output of the `cap <stage> doctor` task, e.g.:

```
cap production doctor
```

Also include in your report:

* Versions of Ruby, Capistrano, and any plugins you’re using (if `doctor` didn't already do this for you)
* A description of the troubleshooting steps you’ve taken
* Logs and backtraces
* Sections of your `deploy.rb` that may be relevant
* Any other unique aspects of your environment

If you are an experienced Ruby programmer, take a few minutes to get the Capistrano test suite running (see [DEVELOPMENT.md][]), and do what you can to get a test case written that fails. *This will be a huge help!*

If you think you may have discovered a security vulnerability in Capistrano, do not open a GitHub issue. Instead, please send a report to <security@capistranorb.com>.

## Requesting new features or improvements

Capistrano continues to improve thanks to people like you! Feel free to open a GitHub issue for any or all of these ideas:

* New features that would make Capistrano even better
* Areas where documentation could be improved
* Ways to improve developer happiness

Generally speaking the maintainers are very conservative about adding new features, and we can’t guarantee that the community will agree with or implement your idea. Please don’t be offended if we say no! The Capistrano team will do our best to review all suggestions and at least weigh in with a comment or suggest a workaround, if applicable.

**Your idea will have a much better chance of becoming reality if you contribute code for it (even if the code is incomplete!).**

## Contributing code or documentation

So you want to contribute to Capistrano? Awesome! We have a whole separate document just you. It explains our pull request workflow and walks you through setting up the development environment: [DEVELOPMENT.md][].


[DEVELOPMENT.md]: https://github.com/capistrano/capistrano/blob/master/DEVELOPMENT.md
