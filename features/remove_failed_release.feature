Feature: Remove failed release

  Background:
    Given a test app with the default configuration
    And servers with the roles app and web
    And an empty deploy directory
    And all linked files exists in shared path

  Scenario: Failed releases are kept by default
    Given a custom task that will fail after a release is created
    When I run cap "deploy"
    Then the task fails
    And 1 valid releases are kept

  Scenario: Failed releases are removed when configured
    Given config stage file has line "set :remove_failed_release, true"
    And a custom task that will fail after a release is created
    When I run cap "deploy"
    Then the task fails
    And 0 valid releases are kept

  Scenario: Current release is not removed after publishing
    Given config stage file has line "set :remove_failed_release, true"
    And a custom task that will fail after a release is published
    When I run cap "deploy"
    Then the task fails
    And 1 valid releases are kept
    And the current directory will be a symlink to the release
