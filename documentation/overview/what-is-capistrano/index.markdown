---
title: What is Capistrano?
layout: default
---

### Capistrano is a remote server automation tool.

It supports the scripting and execution of arbitrary tasks, and includes a set of sane-default deployment workflows.

Capistrano can be used to:

* Reliably deploy web application to any number of machines simultaneously,
   in sequence or as a rolling set
* To automate audits of any number of machines (checking login logs,
  enumerating uptimes, and/or applying security patches)
* To script arbitrary workflows over SSH
* To automate common tasks in software teams.
* To drive infrastructure provisioning tools such as *chef-solo*, *Ansible* or similar.

Capistrano is also *very* scriptable, and can be integrated with any other
Ruby software to form part of a larger tool.

#### What does it look like?

{% highlight bash %}
me@localhost $ cap staging deploy
{% endhighlight %}

<div>
<pre data-line class="language-capistrano"><code data-language="capistrano"><span style="color:white;">DEBUG</span> Uploading /tmp/git-ssh.sh 0%
<span style="color:#BFD4EF;"> INFO</span> Uploading /tmp/git-ssh.sh 100%
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">649ae05d</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env chmod +x /tmp/git-ssh.sh</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">649ae05d</span>] Command: <span style="color:#BFD4EF;">/usr/bin/env chmod +x /tmp/git-ssh.sh</span>
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">649ae05d</span>] Finished in 0.048 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">6a86a816</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env git ls-remote git@github.com:capistrano/rails3-bootstrap-devise-cancan.git</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">6a86a816</span>] Command: <span style="color:#BFD4EF;">( GIT_ASKPASS=/bin/echo GIT_SSH=/tmp/git-ssh.sh /usr/bin/env git ls-remote git@github.com:capistrano/rails3-bootstrap-devise-cancan.git )</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">6a86a816</span>] <span style="color:#D2EB95;">    3419812c9f146d9a84b44bcc2c3caef94da54758	HEAD
</span><span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">6a86a816</span>] <span style="color:#D2EB95;">    3419812c9f146d9a84b44bcc2c3caef94da54758	refs/heads/master
</span><span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">6a86a816</span>] Finished in 2.526 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">26c22cce</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env mkdir -pv /var/www/my-application/shared /var/www/my-application/releases</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">26c22cce</span>] Command: <span style="color:#BFD4EF;">/usr/bin/env mkdir -pv /var/www/my-application/shared /var/www/my-application/releases</span>
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">26c22cce</span>] Finished in 0.439 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">682cbb14</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env [ -f /var/www/my-application/repo/HEAD ]</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">682cbb14</span>] Command: <span style="color:#BFD4EF;">[ -f /var/www/my-application/repo/HEAD ]</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">682cbb14</span>] Finished in 0.448 seconds command <span style="font-weight:bold;"></span><span style="color:red;font-weight:bold;">failed</span>.
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">902d6fe6</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env if test ! -d /var/www/my-application; then echo &quot;Directory does not exist '/var/www/my-application'&quot; 1&gt;&amp;2; false; fi</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">902d6fe6</span>] Command: <span style="color:#BFD4EF;">if test ! -d /var/www/my-application; then echo &quot;Directory does not exist '/var/www/my-application'&quot; 1&gt;&amp;2; false; fi</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">902d6fe6</span>] Finished in 0.047 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">70365162</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env git clone --mirror git@github.com:capistrano/rails3-bootstrap-devise-cancan.git /var/www/my-application/repo</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">70365162</span>] Command: <span style="color:#BFD4EF;">cd /var/www/my-application &amp;&amp; ( GIT_ASKPASS=/bin/echo GIT_SSH=/tmp/git-ssh.sh /usr/bin/env git clone --mirror git@github.com:capistrano/rails3-bootstrap-devise-cancan.git /var/www/my-application/repo )</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">70365162</span>] <span style="color:#D2EB95;">    Cloning into bare repository '/var/www/my-application/repo'...
</span><span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">70365162</span>] <span style="color:#D2EB95;">    remote: Counting objects: 598, done.
</span><span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">70365162</span>] Finished in 3.053 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">4d3ef555</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env if test ! -d /var/www/my-application/repo; then echo &quot;Directory does not exist '/var/www/my-application/repo'&quot; 1&gt;&amp;2; false; fi</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">4d3ef555</span>] Command: <span style="color:#BFD4EF;">if test ! -d /var/www/my-application/repo; then echo &quot;Directory does not exist '/var/www/my-application/repo'&quot; 1&gt;&amp;2; false; fi</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">4d3ef555</span>] Finished in 0.445 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">90a42e63</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env git remote update</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">90a42e63</span>] Command: <span style="color:#BFD4EF;">cd /var/www/my-application/repo &amp;&amp; /usr/bin/env git remote update</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">90a42e63</span>] <span style="color:#D2EB95;">	Fetching origin
</span><span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">90a42e63</span>] Finished in 2.078 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">39a7244f</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env if test ! -d /var/www/my-application/repo; then echo &quot;Directory does not exist '/var/www/my-application/repo'&quot; 1&gt;&amp;2; false; fi</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">39a7244f</span>] Command: <span style="color:#BFD4EF;">if test ! -d /var/www/my-application/repo; then echo &quot;Directory does not exist '/var/www/my-application/repo'&quot; 1&gt;&amp;2; false; fi</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">39a7244f</span>] Finished in 0.455 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">8665f0f1</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env git clone --branch master --depth 1 --recursive --no-hardlinks /var/www/my-application/repo /var/www/my-application/releases/20130625064744</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">8665f0f1</span>] Command: <span style="color:#BFD4EF;">cd /var/www/my-application/repo &amp;&amp; ( GIT_ASKPASS=/bin/echo GIT_SSH=/tmp/git-ssh.sh /usr/bin/env git clone --branch master --depth 1 --recursive --no-hardlinks /var/www/my-application/repo /var/www/my-application/releases/20130625064744 )</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">8665f0f1</span>] <span style="color:#D2EB95;">    warning: --depth is ignored in local clones; use file:// instead.
</span><span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">8665f0f1</span>] <span style="color:#D2EB95;">    Cloning into '/var/www/my-application/releases/20130625064744'...
</span><span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">8665f0f1</span>] <span style="color:#D2EB95;">    done.
</span><span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">8665f0f1</span>] Finished in 0.141 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">bfd2d6bd</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env rm -rf /var/www/my-application/current</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">bfd2d6bd</span>] Command: <span style="color:#BFD4EF;">/usr/bin/env rm -rf /var/www/my-application/current</span>
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">bfd2d6bd</span>] Finished in 0.474 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">54ea9e57</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env ln -s /var/www/my-application/releases/20130625064744 /var/www/my-application/current</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">54ea9e57</span>] Command: <span style="color:#BFD4EF;">/usr/bin/env ln -s /var/www/my-application/releases/20130625064744 /var/www/my-application/current</span>
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">54ea9e57</span>] Finished in 0.054 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">b5af33fb</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env ls -xt /var/www/my-application/releases</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">b5af33fb</span>] Command: <span style="color:#BFD4EF;">/usr/bin/env ls -xt /var/www/my-application/releases</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">b5af33fb</span>] <span style="color:#D2EB95;">    20130625064744
</span><span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">b5af33fb</span>] Finished in 0.445 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">10b6e05d</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env if test ! -d /var/www/my-application/releases; then echo &quot;Directory does not exist '/var/www/my-application/releases'&quot; 1&gt;&amp;2; false; fi</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">10b6e05d</span>] Command: <span style="color:#BFD4EF;">if test ! -d /var/www/my-application/releases; then echo &quot;Directory does not exist '/var/www/my-application/releases'&quot; 1&gt;&amp;2; false; fi</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">10b6e05d</span>] Finished in 0.452 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">dd6ef5b4</span>] Running <span style="color:olive;"></span><span style="color:olive;font-weight:bold;">/usr/bin/env echo &quot;Branch master deployed as release 20130625064744 by leehambley; &quot; &gt;&gt; /var/www/my-application/revisions.log</span> on <span style="color:#BFD4EF;">example.com</span>
<span style="color:white;">DEBUG</span> [<span style="color:#D2EB95;">dd6ef5b4</span>] Command: <span style="color:#BFD4EF;">echo &quot;Branch master deployed as release 20130625064744 by leehambley; &quot; &gt;&gt; /var/www/my-application/revisions.log</span>
<span style="color:#BFD4EF;"> INFO</span> [<span style="color:#D2EB95;">dd6ef5b4</span>] Finished in 0.046 seconds command <span style="font-weight:bold;"></span><span style="color:#D2EB95;font-weight:bold;">successful</span>.
</code></pre>
</div>

#### What else is in the box?

There's lots of cool stuff in the Capistrano toy box:

* Interchangable output formatters (progress, pretty, html, etc)
* Easy to add support for other source control management software.
* A rudimentary multi-console for running Capistrano interactively.
* Host and Role filters for partial deploys, or partial-cluster maintenance.
* Recipes for the Rails asset pipelines, and database migrations.
* Support for complex environments.
* A sane, expressive API:

{% highlight ruby %}
desc "Show off the API"
task :ditty do

  on roles(:all) do |host|
    # Capture output from the remote host, and re-use it
    # we can reflect on the `host` object passed to the block
    # and use the `info` logger method to benefit from the
    # output formatter that is selected.
    uptime = capture('uptime')
    if host.roles.include?(:web)
      info "Your webserver #{host} has uptime: #{uptime}"
    end
  end

  on roles(:app) do
    # We can set environmental variables for the duration of a block
    # and move the process into a directoy, executing arbitrary tasks
    # such as letting Rails do some heavy lifting.
    with({:rails_env => :production}) do
      within('/var/www/my/rails/app') do
        execute :rails, :runner, 'MyModel.something'
      end
    end
  end

  on roles(:db) do
    # We can even switch users, provided we have support on the remote
    # server for switching to that user without being prompted for a
    # passphrase.
    as 'postgres' do
      widgets = capture "echo 'SELECT * FROM widgets;' | psql my_database"
      if widgets.to_i < 50
        warn "There are fewer than 50 widgets in the database on #{host}!"
      end
    end
  end

  on roles(:all) do
    # We can even use `test` the way the Unix gods intended
    if test("[ -d /some/directory ]")
      info "Phew, it's ok, the directory exists!"
    end
  end
end
{% endhighlight %}
