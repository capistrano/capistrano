---
title: Ignoring
layout: default
---

Files commited to version control (i.e. not in .gitignore) can still be ignored when deploying.  To ignore these files or directories, simply add them to .gitattributes:

```bash
config/deploy/deploy.rb   export-ignore
config/deploy/            export-ignore
```

These files will be kept in version control but not deployed to the server.

*Note:* This feature is probably unnecessary unless the root of your repository is also your web server's docroot. For example, in a Rails application, the docroot is the `public/` folder. Since all of the Capistrano configuration lives above or beside this folder, it cannot be served and is not a security risk. If the docroot is indeed at the base of the repository, consider changing that by moving the code at the repository base to a subdirectory such as public_html instead of using this feature. Note that this feature is very specific to Git and will not work on other SCMs.
