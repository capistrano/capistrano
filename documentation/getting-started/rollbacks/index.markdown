---
title: Rollbacks
layout: default
---

When a deployment is run, Capistrano executes one task at a time on all servers and waits for that task to be done before moving on to the next one. If a task fails on one or more servers, the errors are printed, Capistrano waits for all servers to either return an error or succeed, and then stops execution of any further tasks.

If the error occurs during a deployment task which is prior to the final cutover, for example during creation of symlinks, the process will simply stop and the server will continue to run. However if the failing deployment task is after `deploy:symlink:release`, during which the `current` symlink is moved to the newly deployed code, this may result in an inconsistent state which should be solved by executing `cap [stage] deploy:rollback`. Rollback can also be a solution for issues with failed deployments due to buggy code or other reasons.

Per http://capistranorb.com/documentation/getting-started/flow/, the standard deployment and rollback processes are nearly identical. The difference is that in a deploy, the `deploy:updating` and `deploy:updated` tasks are executed, while in a rollback, the `deploy:reverting` and `deploy:reverted` (a hook task) tasks are run. Also, instead of `deploy:finishing`, `deploy:finishing_rollback` is run, as cleanup can sometimes be different.

## `deploy:reverting`

This starts by setting the release_path to the last known good release path. It does this by obtaining a list of folders in the releases folder and if there are at least two, sets the second to last release as the release_path. It also sets the `rollback_timestamp` to this same release which it uses for the log entry.

Once this has been set, the remaining standard deployment tasks flip the symlink accordingly.

## `deploy:finishing_rollback`

To finish the rollback, Capistrano creates a tarball of the failed release in the deploy path, and then deletes the release folder.
