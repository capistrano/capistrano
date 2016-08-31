---
title: Why does something work in my SSH session, but not in Capistrano?
layout: default
---

This is possibly one of the most complicated support questions that can be
asked, the only real answer is ***it depends***.

It's really a question of which *kind* of shell Capistrano is using, it's a
matrix of possibilities concerning `login`, `non-login`, `interactive`, or
`non-interactive`.

**By default Capistrano always assigns a `non-login`, `non-interactive` shell.**

## Shell Modes

Unix shells can be started in one of three modes, an unnamed *basic* mode,
which almost never happens, as a `login` shell, or as an `interactive` shell.

Depending which mode a shell starts in (and which shell you are using) this
will affect which startup (more commonly known as *dot*-files) files, if any
are loaded, [here's](#which_startup_files_loaded) more or less the matrix of what is loaded when.

## What about the Capistrano option to assign a `pty`?

This option has been hugely misleadingly used, if you ask SSH to provide a
`pty` you are effectively telling SSH that *"I'll connect this session to a
user terminal"*, thus programs on the receiving end expect that they can prompt
for input, and provide coloured output, etc. In short they think they're
talking to you over an interactive session, because by assigning a `pty`, Bash
has been started in `non-login`, `interactive` mode.

Read more about this:

 * [In the "Bash Startup Files" section of the Bash
   manual](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html)
 * [At Sam Stephenson's excellent *Unix shell initialization* wiki
   page](https://github.com/sstephenson/rbenv/wiki/Unix-shell-initialization)
 * [Interactive and non-interactive shells and scripts
   documentation](http://www.tldp.org/LDP/abs/html/intandnonint.html)

## How does what Capistrano does differ from an SSH session

By default Capistrano prefers to start a *non-login, non-interactive
shell*, to try and isolate the environment and make sure that things work as
expected, regardless of any changes that might happen on the server side.

In contrast when you log into a machine with your terminal, into a regular
Bash session, the `--login` option to Bash is implied granting you a `login`
shell, and because you are in a terminal, ssh asks the ssh server to provide a
pty so that you may start an interactive session. Thus you get an `interactive
login` shell, the exact opposite of what we need for Capistrano!

## How can I check?

I actually had to look this up, most of the time it's common sense, but
[stackoverflow to the rescue](http://unix.stackexchange.com/a/26782), let's
figure this out!

First, we'll try a *real* SSH session, logging in via our terminal, and seeing
what happens:

```bash
me@localhost $ ssh me@remote
me@remote $ [[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive'
Interactive
me@remote $ shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'
Login shell
```

Contrast that with what happens when we hand the command to run to the SSH
command line without logging in first...

```bash
me@localhost $ ssh me@remote "[[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive'"
Interactive
me@localhost $ ssh me@remote "shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'"
Not login shell
```

Here we can see that Bash is still starting in **interactive** mode when we're
just running a single command, that's because the terminal we are using is
interactive, and SSH inherits that and passes that on to the remote server.

When we try the same with Capistrano we'll see yet another set of results; we
can have a very simple, Capfile, we don't even need to load the default
recipes to test this:

```ruby
# Capistrano 3
task :query_interactive do
  on 'me@remote' do
    info capture("[[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive'")
  end
end
task :query_login do
  on 'me@remote' do
    info capture("shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'")
  end
end
```

Gives us the following:

```bash
me@localhost $ cap query_login
INFO Not login shell
me@localhost $ cap query_interactive
INFO Not interactive
```

## <a id="which_startup_files_loaded"></a>Which shell startup files do get loaded?

Best explained with this diagram, yes it's that complicated:

<figure class="panel">
  <img src="/images/BashStartupFiles1.png" title="Bash Startup Files" alt="Bash Startup Files" />
  <figcaption>
    <p>Source: <a href="http://www.solipsys.co.uk/new/BashInitialisationFiles.html">http://www.solipsys.co.uk/new/BashInitialisationFiles.html</a></p>
  </figcaption>
</figure>

