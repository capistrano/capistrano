---
title: Preparing Your Application
layout: default
---

<div class="alert-box radius">
  This will focus on preparing a Rails application, but most ideas expressed
  here have parallels in Python, or PHP applications
</div>

## 1. Commit your application to some externally available source control hosting provider.

If you are not doing already, you should host your code somewhere with a
provuder such as Github, BitBucket, Codeplane, or repositoryhosting.com.

<div class="alert-box radius">
At present Capistrano v3.0.x only supports Git. It's just a matter of time
until we support Subversion, Mecurial, Darcs and friends again. Please
contribute if you know these tools well, we don't and don't want to force our
miscomprehended notions upon anyone.
</div>

## 2. Move secrets out of the repository.

<div class="alert-box alert">
If you've accidentally committed state secrets to the repository, you might
want to take <a
href="https://help.github.com/articles/remove-sensitive-data">special
steps</a> to erase them from the repository history for all time.
</div>

Ideally one should remove `config/database.yml` to something like
`config/database.yml.example`, you and your team should copy the example file
into place on their development machines, under Capistrano this leaves the
`database.yml` filename unused so that we can symlink the production database
configuration into place at deploy time.

The original `database.yml` should be added to the `.gitignore` (or your SCM's
parallel concept of ignored files)

{% prism bash %}
    $ cp config/database.yml{,.example}
    $ echo config/database.yml >> .gitignore
{% endprism %}

This should be done for any other secret files, we'll create the production
version of the file when we deploy, and symlink it into place.

## 3. Initialize Capistrano in your application.

{% prism bash %}
    $ cd my-project
    $ cap install
{% endprism %}

This will create a bunch of files, the important ones are:

{% prism bash %}
  ├── Capfile
  ├── config
  │   ├── deploy
  │   │   ├── production.rb
  │   │   └── staging.rb
  │   └── deploy.rb
  └── lib
      └── capistrano
              └── tasks
{% endprism %}
