---
title: Structure
layout: default
---

Capistrano uses a strictly defined directory hierarchy on each remote server to organise the source code and other deployment-related data. The root path of this structure can be defined with the configuration variable `:deploy_to`.

Assuming your `config/deploy.rb` contains this:

```ruby
set :deploy_to, '/var/www/my_app_name'
```


Then inspecting the directories inside `/var/www/my_app_name` looks like this:

```bash
├── current -> /var/www/my_app_name/releases/20150120114500/
├── releases
│   ├── 20150080072500
│   ├── 20150090083000
│   ├── 20150100093500
│   ├── 20150110104000
│   └── 20150120114500
├── repo
│   └── <VCS related data>
├── revisions.log
└── shared
    └── <linked_files and linked_dirs>
```


* `current` is a symlink pointing to the latest release. This symlink is
updated at the end of a  successful deployment. If the deployment fails in any
step the `current` symlink still points to the  old release.

* `releases` holds all deployments in a timestamped folder. These folders are
the target of the `current` symlink.

* `repo` holds the version control system configured. In case of a git
repository the content will be a  raw git repository (e.g. objects, refs,
etc.).

* `revisions.log` is used to log every deploy or rollback. Each entry is
timestamped and the executing  user (username from local machine) is listed.
Depending on your VCS data like branchnames or revision  numbers are listed as
well.

* `shared` contains the `linked_files` and `linked_dirs` which are symlinked
into each release. This  data persists across deployments and releases. It
should be used for things like database configuration  files and static and
persistent user storage handed over from one release to the next.

The application is completely contained within the path of `:deploy_to`. If
you plan on deploying multiple applications to the same server, simply choose
a different `:deploy_to` path.
