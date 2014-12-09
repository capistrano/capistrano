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

  Scenario: Show install task with configuration in default location
    When I run "cap -T"
    Then the task is successful
    And contains "install" in the output

  Scenario: Hide install task with configuration in a custom location
    And config stage file has line "desc 'Special Task'"
    And config stage file has line "task :special_stage_task"
    But the configuration is in a custom location
    When I run "cap -T"
    Then the task is successful
    And doesn't contain "special_stage_task" in the output
