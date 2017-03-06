Feature: cap can be run from a subdirectory, and will still find the Capfile

  Background:
    Given a test app with the default configuration
    And servers with the roles app and web

  Scenario: Running cap from a subdirectory
    When I run cap "git:check" within the "config" directory
    Then the task is successful
