Feature: SSH Connection

  Background:
    Given a test app with the default configuration
    And servers with the roles app and web
    And a task which executes as root

  Scenario: Switching from default user to root and back again
    When I run cap "am_i_root"
    Then the task is successful
    And the output matches "I am uid=0\(root\)" followed by "I am uid=\d+\(vagrant\)"
