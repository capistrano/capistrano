Feature: Deploy

  Background:
    Given a test app with the default configuration
    And servers with the roles app and web

  Scenario: Creating the repo
    When I run cap "git:check"
    Then references in the remote repo are listed

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
    Given a required file
    But the file does not exist
    When I run cap "deploy:check:linked_files"
    Then the task will exit

  Scenario: Checking linked files - file exists
    Given a required file
    And that file exists
    When I run cap "deploy:check:linked_files"
    Then the task will be successful

  Scenario: Creating a release
    Given I run cap "deploy:check:directories"
    When I run cap "git:create_release" as part of a release
    Then the repo is cloned
    And the release is created

  Scenario: Symlink linked files
    When I run cap "deploy:symlink:linked_files" as part of a release
    Then file symlinks are created in the new release

  Scenario: Symlink linked dirs
    When I run cap "deploy:symlink:linked_dirs" as part of a release
    Then directory symlinks are created in the new release

  Scenario: Publishing
    When I run cap "deploy:symlink:release"
    Then the current directory will be a symlink to the release

