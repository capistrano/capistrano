---
title: Ignoring
layout: default
---

Files commited to version control (i.e. not in .gitignore) can still be ignored when  
deploying.  To ignore these files or directories, simply add them to .gitattributes:  
```
config/deploy/deploy.rb   export-ignore  
config/deploy/            export-ignore
```  
  
These files will be kept in version control but not deployed to the server.  
