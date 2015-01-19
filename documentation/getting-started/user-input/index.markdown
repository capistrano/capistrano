---
title: User Input
layout: default
---

{% highlight ruby %}
desc "Ask about breakfast"
task :breakfast do
  ask(:breakfast, "pancakes")
  on roles(:all) do |h|
    execute "echo \"$(whoami) wants #{fetch(:breakfast)} for breakfast!\""
  end
end
{% endhighlight %}

Perfect, who needs telephones.

When using `ask` to get user input, you can pass `echo: false` to prevent the input from being displayed:

{% highlight ruby %}
ask(:database_password, "default", echo: false)
{% endhighlight %}
