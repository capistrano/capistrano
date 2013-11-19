Feature: Deploy failure

  Background:
    Given a test app with the default configuration
    And a custom task that will simulate a failure
    And a custom task to run in the event of a failure
    And servers with the roles app and web

  Scenario: Triggering the custom task
    When I run cap "deploy:starting"
    But an error is raised
    Then the failure task will not run

  Scenario: Triggering the custom task
    When I run cap "deploy"
    But an error is raised
    Then the failure task will run
