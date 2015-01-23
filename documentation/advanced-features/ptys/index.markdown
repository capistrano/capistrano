---
title: PTYs
layout: default
---

There is a configuration option which asks the backend driver to ask the
remote host to assign the connection a *pty*. A *pty* is a pseudo-terminal,
which in effect means *tell the backend that this is an __interactive__
session*. This is normally a bad idea.

Most of the differences are best explained by [this
page](https://github.com/sstephenson/rbenv/wiki/Unix-shell-initialization)
from the author of *rbenv*.

**When Capistrano makes a connection it is a *non-login*, *non-interactive*
shell. This was not an accident!**

It's often used as a band aid to cure issues related to RVM and rbenv not
loading login and shell initialisation scripts. In these scenarios RVM and
rbenv are the tools at fault, or at least they are being used incorrectly.

Whilst, especially in the case of language runtimes (Ruby, Node, Python and
friends in particular) there is a temptation to run multiple versions in
parallel on a single server and to switch between them using environmental
variables, this is an anti-pattern, and symptomatic of bad design (e.g. you're
testing a second version of Ruby in production because your company lacks the
infrastructure to test this in a staging environment).
