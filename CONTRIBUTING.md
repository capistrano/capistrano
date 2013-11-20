## CONTRIBUTING

**The issue tracker is intended exclusively for things that are genuine bugs,
or improvements to the code.**

If you have a user support query, or you suspect that you might just be holding
it wrong, drop us a line at [the mailing list]() or on [StackOverflow](). The
mailing list is moderated to cut down on spam, so please be patient, if you use
StackOverflow, make sure to tag your post with "Capistrano". (Not forgetting
any other tags which might relate, rvm, rbenv, Ubuntu, etc.)

Wherever you post please be sure to include the version of Capistrano you are
using, which versions of any plugins (*capistrano-rvm*, *capistrano-bundler*,
etc.). Proper logs are vital, if you need to redact them, go ahead, but be
careful not to remove anything important. Please take care to format logs and
code correctly, ideally wrapped to a sane line length, and in a mono spaced
font. This all helps us to gather a clear understanding of what is going wrong.

**If you really think that you found a bug, or want to enquire about a feature,
or send us a patch to add a feature, or fix a bug, please keep a few things in
mind:**

## When Submitting An Issue:

If you think there's a bug, please make sure it's really a bug in Capistrano.
As Capistrano sits on the (sometimes rough) edges between SSH, Git, the
network, Ruby, RVM, rbenv, chruby, Bundler, your Linux distribution, countless
shell configuration files on your end, and the server… there's a good chance
the problem lies somewhere else.

Please make sure you have reviewed the FAQs at http://www.capistranorb.com/.

It's really important to include as much information as possible, versions of
everything involved, anything weird you might be doing that might be having
side effects, include as much as you can in a [GitHub
Gist](https://gist.github.com/) and link that from the issue, with tools such
as Gist, we can link to individual lines and help work out what is going wrong.

If you are an experienced Ruby programmer, take a few minutes to get our test
suite running, and do what you can to get a test case written that fails, from
there we can understand exactly what it takes to reproduce the issue (as it's
documented with code)

## When Requesting a Feature:

We can't make everyone happy all of the time, and we've been around the block
well enough to know when something doesn't work well, or when your proposed fix
might impact other things.

We prefer to [start with
"no"](https://gettingreal.37signals.com/ch05_Start_With_No.php), and help you
find a better way to solve your problem, sometimes the solution is to [build
faster
horses](http://blog.cauvin.org/2010/07/henry-fords-faster-horse-quote.html),
sometimes the solution is to work around it in a neat way that you didn't know
existed.

Please don't be offended if we say no, and don't be afraid to fight your
corner, try and avoid being one of the [poisonous
people](https://www.youtube.com/watch?v=Q52kFL8zVoM)

## Submitting A Pull Request:

Pull requests are awesome, and if they arrive with decent tests, and conform to
the guidelines below, we'll merge them in as soon as possible, we'll let you
know which release we're planning them for (we adhere to
[semver](http://semver.org/) so please don't be upset if we plan your changes
for a later release)

 * The code is MIT licenced, your code will fall under the same license if we merge it.
 * We can't merge it without a [good commit
   message](http://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message).
   If you do this right, Github will use the commit message as the body of your
   pull request, double win.
 * If you are referencing an improvement to an existing issue (if we have not
   yet merged it )
 * Add an entry to the `CHANGELOG` under the `### master` section, but please
   don't mess with the version.
 * If you add a new feature, please make sure to document it, open a
   corresponding pull request in [the
   documentation](https://github.com/capistrano/documentation) and mention the
   code change pull request over there, and Github will link everything up. If
   it's a simple feature, or a new variable, or something changed, it may be
   appropriate simply to document it in the generated `Capfile` or `deploy.rb`, or
   in the `README`
 * Take care to squash your commit into one single commit with a good message, it
   saves us a lot of work in maintaining the CHANGELOG if we can generate it from
   the commit messages between the release tags!
 * Tests! It's tricky to test some parts of Capistrano, but do your best, it
   might just serve as a starting point for us to build a reliable test on top of,
   and help us understand where you are coming from.
