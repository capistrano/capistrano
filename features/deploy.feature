Feature: Deploy

  Background:
    Given a test app with the default configuration
    And servers with the roles app and web

  Scenario: Creating the repo
    When I run cap "git:check"
    Then the task is successful
    And git wrapper permissions are 0700

  Scenario: Creating the directory structure
    When I run cap "deploy:check:directories"
    Then the shared path is created
    And the releases path is created

  Scenario: Creating linked directories
    When I run cap "deploy:check:linked_dirs"
    Then directories in :linked_dirs are created in shared

  Scenario: Creating linked directories for linked files
    When I run cap "deploy:check:make_linked_dirs"
    Then directories referenced in :linked_files are created in shared

  Scenario: Checking linked files - missing file
    Given a linked file "missing_file.txt"
    But file "missing_file.txt" does not exist in shared path
    When I run cap "deploy:check:linked_files"
    Then the task fails

  Scenario: Checking linked files - file exists
    Given a linked file "existing_file.txt"
    And file "existing_file.txt" exists in shared path
    When I run cap "deploy:check:linked_files"
    Then the task is successful

  Scenario: Creating a release
    Given I run cap "deploy:check:directories"
    When I run cap "git:create_release" as part of a release
    Then the repo is cloned
    And the release is created

  Scenario: Symlink linked files
    When I run cap "deploy:symlink:linked_files deploy:symlink:release" as part of a release
    Then file symlinks are created in the new release

  Scenario: Symlink linked dirs
    When I run cap "deploy:symlink:linked_dirs" as part of a release
    Then directory symlinks are created in the new release

  Scenario: Publishing
    When I run cap "deploy:symlink:release"
    Then the current directory will be a symlink to the release

  Scenario: Cleanup
    Given config stage file has line "set :keep_releases, 3"
    And 5 valid existing releases
    And an invalid release named "new"
    When I run cap "deploy:cleanup"
    Then 3 valid releases are kept
    And the invalid "new" release is ignored

  Scenario: Cleanup after many failed releases doesn't remove last good release
    Given config stage file has line "set :keep_releases, 2"
    And I make 2 deployments
    And an invalid release named "77777777777777"
    And an invalid release named "88888888888888"
    And an invalid release named "99999999999999"
    When I run cap "deploy:cleanup"
    Then 3 valid releases are kept
    And the current directory will be a symlink to the release

  Scenario: Cleanup when there are more releases than arguments can handle
    Given config stage file has line "set :keep_releases, 3"
    And 5000 valid existing releases
    When I run cap "deploy:cleanup"
    Then 3 valid releases are kept

  Scenario: Rolling Back
    Given I make 2 deployments
    When I run cap "deploy:rollback"
    Then the current symlink points to the previous release

  Scenario: Rolling Back to a specific release
    Given I make 3 deployments
    When I rollback to a specific release
    Then the current symlink points to that specific release

