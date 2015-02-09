---
title: Console
layout: default
---

**Note:** Here be dragons. The console is very immature, but it's much more
cleanly architected than previous incarnations and it'll only get better from
here on in.

Execute arbitrary remote commands, to use this simply add
`require 'capistrano/console'` which will add the necessary tasks to your
environment:

```bash
$ bundle exec cap staging console
```

Then, after setting up the server connections, this is how that might look:

```bash
$ bundle exec cap production console
capistrano console - enter command to execute on production
production> uptime
 INFO [94db8027] Running /usr/bin/env uptime on leehambley@example.com:22
DEBUG [94db8027] Command: /usr/bin/env uptime
DEBUG [94db8027]   17:11:17 up 50 days, 22:31,  1 user,  load average: 0.02, 0.02, 0.05
 INFO [94db8027] Finished in 0.435 seconds command successful.
production> who
 INFO [9ce34809] Running /usr/bin/env who on leehambley@example.com:22
DEBUG [9ce34809] Command: /usr/bin/env who
DEBUG [9ce34809]  leehambley pts/0        2013-06-13 17:11 (port-11262.pppoe.wtnet.de)
 INFO [9ce34809] Finished in 0.420 seconds command successful.
```
