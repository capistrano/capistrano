---
title: Configuration
layout: default
---

## Configuration

The following variables are settable:

| Variable Name         | Description                                                          | Notes                                                           |
|:---------------------:|----------------------------------------------------------------------|-----------------------------------------------------------------|
| `:repo_url`           | The URL of your scm repository (git, hg, svn)                        | file://, https://, ssh://, or svn+ssh:// are all supported      |
| `:repo_tree`          | The subtree of the scm repository to deploy (git, hg)                | Only implemented for git and hg repos. Extract just this tree   |
| `:branch`             | The branch you wish to deploy                                        | This only has meaning for git and hg repos, to specify the branch of an svn repo, set `:repo_url` to the branch location. |
| `:scm`                | The source control system used                                       | `:git`, `:hg`, `:svn` are currently supported                   |
| `:tmp_dir`            | The (optional) temp directory that will be used (default: /tmp)      | if you have a shared web host, this setting may need to be set (i.e. /home/user/tmp/capistrano). |

__Support removed__ for following variables:

| Variable Name         | Description                                                         | Notes                                                           |
|:---------------------:|---------------------------------------------------------------------|-----------------------------------------------------------------|
| `:copy_exclude`       | The (optional) array of files and/or folders excluded from deploy | Replaced by Git's native `.gitattributes`, see [#515](https://github.com/capistrano/capistrano/issues/515) for more info. |
