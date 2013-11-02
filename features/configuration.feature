Feature: The path to the configuration can be changed, removing the need to
  follow Ruby/Rails conventions

  Background:
    Given a test app with the default configuration
    And servers with the roles app and web

  Scenario: Deploying with configuration in default location
    When I run "cap test"
    Then the task is successful

  Scenario: Deploying with configuration in a custom location
    But the configuration is in a custom location
    When I run "cap test"
    Then the task is successful
