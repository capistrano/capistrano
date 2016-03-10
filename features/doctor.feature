Feature: Doctor

  Background:
    Given a test app with the default configuration

  Scenario: Running the doctor task
    When I run cap "doctor"
    Then the task is successful
    And contains "Environment" in the output
    And contains "Gems" in the output
    And contains "Variables" in the output
