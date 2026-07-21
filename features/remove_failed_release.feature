Feature: Remove failed release

  Background:
    Given a test app with the default configuration
    And servers with the roles app and web
    And an empty deploy directory
    And a custom task to create a failed release directory

  Scenario: Failed releases are kept by default
    When I run cap "deploy:create_failed_release_directory deploy:failed"
    Then the task is successful
    And 1 valid releases are kept

  Scenario: Failed releases are removed when configured
    Given config stage file has line "set :remove_failed_release, true"
    When I run cap "deploy:create_failed_release_directory deploy:failed"
    Then the task is successful
    And 0 valid releases are kept

  Scenario: Current release is not removed after publishing
    Given config stage file has line "set :remove_failed_release, true"
    When I run cap "deploy:create_failed_release_directory deploy:symlink:release deploy:failed"
    Then the task is successful
    And 1 valid releases are kept
    And the current directory will be a symlink to the release
