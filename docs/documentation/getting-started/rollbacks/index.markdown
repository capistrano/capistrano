---
title: Rollbacks
layout: default
---

In the majority of failed deployment situations, it probably makes more sense to revert the bad code and redeploy, rather than running deploy:rollback. Capistrano provides basic rollback support, but as each application and system handles rollbacks differently, it is up to the individual to test and validate that rollback behaves correctly for their use case. For example, capistrano-rails will run special tasks on rollback to fix the assets, but does nothing special with database migrations.

Correctly rolling back a release is a complex process that depends on the specifics of your application and the Capistrano plugins you've assembled. *Be proactive and test your rollback procedure before trying it for the first time in a time of crisis.*

When a deployment is run, Capistrano executes one task at a time on all servers and waits for that task to be done before moving on to the next one. If a task fails on a server, Capistrano exits without waiting for further tasks. In a multiple server situation, when a task fails on one server by exiting with a non-0 exit code, Capistrano closes the SSH connections to any still in-progress servers and their tasks exit.

If the error occurs during a deployment task which is prior to the final cutover, for example during creation of symlinks, the process will simply stop and the previously deployed application will continue to run. However if the failing deployment task is after `deploy:symlink:release`, during which the `current` symlink is moved to the newly deployed code, this may result in an inconsistent state which may be solved by executing `cap [stage] deploy:rollback`. Rollback can also be a solution for issues with failed deployments due to buggy code or other reasons.

Per http://capistranorb.com/documentation/getting-started/flow/, the standard deployment and rollback processes are nearly identical. The difference is that in a deploy, the `deploy:updating` and `deploy:updated` tasks are executed, while in a rollback, the `deploy:reverting` and `deploy:reverted` (a hook task) tasks are run. Also, instead of `deploy:finishing`, `deploy:finishing_rollback` is run, as cleanup can sometimes be different.

### `deploy:reverting`

This starts by setting the release_path to the last known good release path. It does this by obtaining a list of folders in the releases folder and if there are at least two, sets the second to last release as the release_path. It also sets the `rollback_timestamp` to this same release which it uses for the log entry.

Once this has been set, the remaining standard deployment tasks flip the symlink accordingly.

### `deploy:finishing_rollback`

To finish the rollback, Capistrano creates a tarball of the failed release in the deploy path, and then deletes the release folder.

### `deploy:failed`

In a situation where `cap [stage] deploy` fails, the `deploy:failed` hook is invoked. You can add custom rollback tasks to this hook:

```ruby
after 'deploy:failed', :send_for_help do
  #
end
```

This is different from a specifically invoked rollback, and is application specific. *For reasons stated above, it can be dangerous to use this hook without careful testing.*

### `deploy:rollback ROLLBACK_RELEASE=release`

Rollback to a specific release using the `ROLLBACK_RELEASE` environment variable.

e.g. `cap staging deploy:rollback ROLLBACK_RELEASE=20160614133327`
