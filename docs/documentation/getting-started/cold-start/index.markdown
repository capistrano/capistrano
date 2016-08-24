---
title: Cold Start
layout: default
---

At this point we should have a deploy user on all the servers we intend to
deploy to, that user should have permission to write to wherever we plan on
deploying to, by default that'll be something like `/var/www/my-application`.

We've set up the directory with decent permissions so that we can deploy
without breaking things, and that everyone on our team can deploy, too.

Let's run through what we've done so far, and how to check it's all working,
in the last step of this part of the guide we'll create the production-only
shared files.

Again, this guide assumes Ruby on Rails, but most of everything we're doing so
far is applicable in slightly modified forms to other frameworks and
technologies.

### 1. Checking the directory structure on the remote machine:

```bash
me@localhost $ ssh deploy@remote 'ls -lR /var/www/my-application'
my-application:
total 8
drwxrwsr-x 2 deploy deploy 4096 Jun 24 20:55 releases
drwxrwsr-x 2 deploy deploy 4096 Jun 24 20:55 shared

my-application/releases:
total 0

my-application/shared:
total 0
```

This checks in one simple command that the ssh keys you setup are working (you
might yet be prompted for the password), and the permissions on the directory
can be seen.

### 2. Writing our first *cap task* to formalize this into a check!

Now that we know how to check for permissions, and repository access, we'll
quickly introduce ourselves to a quick Cap task to check these things on all
the machines for us:

```ruby
desc "Check that we can access everything"
task :check_write_permissions do
  on roles(:all) do |host|
    if test("[ -w #{fetch(:deploy_to)} ]")
      info "#{fetch(:deploy_to)} is writable on #{host}"
    else
      error "#{fetch(:deploy_to)} is not writable on #{host}"
    end
  end
end
```

Running this should give you a pretty decent overview, one line of output for
each server. It's also your first introduction to the API of Capistrano for
writing your own tasks, namely `desc()`, `task()`, `on()`, `roles()`,
`test()`, `info()`, and `error()`.

The first two methods, `desc()` and `task()` are actually from Rake, the
library that forms the foundation of the Capistrano task system, the other
methods are part of our sub-project
[**SSHKit**](https://github.com/capistrano/sshkit). We'll dive into those more
later, but add those lines to a file in `./lib/capistrano/tasks`, call it
something like `access_check.rake`, and run `cap -T` from the top directory and
we'll be able to see the task listed:

```bash
me@localhost $ bundle exec cap -T
# ... lots of other tasks ...
cap check_write_permissions  # Check that we can access everything
# ... lots of other tasks ...
```

Then we simply call it:

```bash
me@localhost $ bundle exec cap staging check_write_permissions
DEBUG [82c92144] Running /usr/bin/env [ -w /var/www/my-application ] on myserver.com
DEBUG [82c92144] Command: [ -w /var/www/my-application ]
DEBUG [82c92144] Finished in 0.456 seconds command successful.
INFO /var/www/my-application is writable on myserver.com
```

If we've done something wrong, that won't happen and we'll know that we need
to jump on the mailing list to get help, into IRC or ask a friend.

Depending how you have set your Git authentication credentials up, checking
Git can be a bit complicated, so we've shipped a task in the core library that
can check your git access, Git isn't particularly scriptable, so one has to
wrap Git in a shell script that makes it behave.

Capistrano does just this, so to check if the Git access is working, we can
simply call:

```bash
me@localhost $ cap staging git:check
```

This task is defined in the default Git SCM-strategy and looks a lot like what
we wrote above to check the file permissions, however the Git check recipe is
a bit more complicated, having to potentially deal with three different
authentication schemes, which need to be worked around differently. This task
expresses a *dependency* on the `git:git-wrapper` task which is resolved first
for us by Capistrano. (This is one of the pieces we inherit from Rake)

If this fails we'll see:

```bash
me@localhost $ cap staging git:check
cap staging git:check
DEBUG Uploading /tmp/git-ssh.sh 0%
 INFO Uploading /tmp/git-ssh.sh 100%
 INFO [118bd3e4] Running /usr/bin/env chmod +x /tmp/git-ssh.sh on example.com
DEBUG [118bd3e4] Command: /usr/bin/env chmod +x /tmp/git-ssh.sh
 INFO [118bd3e4] Finished in 0.049 seconds command successful.
 INFO [a996463f] Running /usr/bin/env git ls-remote git@github.com:capistrano/rails3-bootstrap-devise-cancan.git on harrow
DEBUG [a996463f] Command: ( GIT_ASKPASS=/bin/echo GIT_SSH=/tmp/git-ssh.sh /usr/bin/env git ls-remote git@github.com:capistrano/rails3-bootstrap-devise-cancan.git )
DEBUG [a996463f]  Warning: Permanently added 'github.com,204.232.175.90' (RSA) to the list of known hosts.
DEBUG [a996463f]  Permission denied (publickey).
DEBUG [a996463f]  fatal: The remote end hung up unexpectedly
cap aborted!
git stdout: Nothing written
git stderr: Nothing written

Tasks: TOP => git:check
(See full trace by running task with --trace)
```

This'll typically come out looking more beautiful depending on your terminal
colour support, you may well see something like this:

![Capistrano Git Check Colour Example](/images/git-check-example-screenshot.png)

To run through that shortly, what did we do:

1. We asked Capistrano to run the command `git:check`.
2. Capistrano recognised that in order to fulfil this request, it had to first
execute the task `git:wrapper`, a *prerequisite*.
3. Capistrano executed the `git:wrapper` task, and uploaded the
   `/tmp/git-ssh.sh` file, and made it executable.
   This script is actually processed as a template.
4. With the git wrapper in place, we can safely script against Git without it
   prompting us for input, so we ask git to `ls-remote` on the repository we
   defined. As this exited with an [unclean
   status](https://en.wikipedia.org/wiki/Exit_status), Capistrano aborted, and
   printed out the error messages for us to try and figure out what broke.

In this case, we'll be using SSH agent forwarding, we can check if that's
working by writing a tiny Cap task, or simply using SSH to do it for us, the
choice is yours:

```ruby
# lib/capistrano/tasks/agent_forwarding.rake
desc "Check if agent forwarding is working"
task :forwarding do
  on roles(:all) do |h|
    if test("env | grep SSH_AUTH_SOCK")
      info "Agent forwarding is up to #{h}"
    else
      error "Agent forwarding is NOT up to #{h}"
    end
  end
end
```

That gave the output:

```bash
cap staging forwarding
DEBUG [f1269276] Running /usr/bin/env env | grep SSH_AUTH_SOCK on example.com
DEBUG [f1269276] Command: env | grep SSH_AUTH_SOCK
DEBUG [f1269276]  SSH_AUTH_SOCK=/tmp/ssh-nQUEmyQ2nS/agent.2546
DEBUG [f1269276] Finished in 0.453 seconds command successful.
 INFO Agent forwarding is up to example.com
```

If you don't feel like writing a Capistrano task, one could simply do:

```bash
me@localhost $ ssh -A example.com 'env | grep SSH_AUTH_SOCK'
SSH_AUTH_SOCK=/tmp/ssh-Tb6X8V53tm/agent.2934
```

If we see the `SSH_AUTH_SOCK` output, that's a pretty good indication that SSH
agent forwarding is enabled, and if on your local machine `ssh-add -l` shows
you an SSH key, then we're good to go. **Make sure that you're using the
`git@...` repository URL**

```bash
cap staging git:check
DEBUG Uploading /tmp/git-ssh.sh 0%
 INFO Uploading /tmp/git-ssh.sh 100%
 INFO [21382716] Running /usr/bin/env chmod +x /tmp/git-ssh.sh on example.com
DEBUG [21382716] Command: /usr/bin/env chmod +x /tmp/git-ssh.sh
 INFO [21382716] Finished in 0.047 seconds command successful.
 INFO [f40edfbb] Running /usr/bin/env git ls-remote git@github.com:capistrano/rails3-bootstrap-devise-cancan.git on example.com
DEBUG [f40edfbb] Command: ( GIT_ASKPASS=/bin/echo GIT_SSH=/tmp/git-ssh.sh /usr/bin/env git ls-remote git@github.com:capistrano/rails3-bootstrap-devise-cancan.git )
DEBUG [f40edfbb]  3419812c9f146d9a84b44bcc2c3caef94da54758  HEAD
DEBUG [f40edfbb]  3419812c9f146d9a84b44bcc2c3caef94da54758  refs/heads/master
 INFO [f40edfbb] Finished in 3.319 seconds command successful.
```

![Capistrano Git Check Colour Example](/images/successful-git-check-example-screenshot.png)

*Note:* If you get an error like `scp: /tmp/git-ssh.sh: Permission denied`, you may need to set the `:tmp_dir` param.
