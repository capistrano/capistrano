Feature: Remote file task

  Background:
    Given a test app with the default configuration
    And a custom task to generate a file
    And servers with the roles app and web

  Scenario: Where the file does not exist
    When I run cap "deploy:check:linked_files"
    Then it creates the file with the remote_task prerequisite

  Scenario: Where the file already exists
    When I run cap "deploy:check:linked_files"
    Then it will not recreate the file
