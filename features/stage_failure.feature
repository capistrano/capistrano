Feature: Stage failure

  Background:
    Given a test app with the default configuration
    And a stage file named deploy.rb

  Scenario: Running a task
    When I run cap "doctor"
    Then the task fails
