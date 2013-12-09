Feature: Deploy via clone

  Background:
    Given a test app with git clone configuration
    And servers with the roles app and web

  Scenario: Creating a release
    Given I run cap "deploy:check:directories"
    When I run cap "git:create_release" as part of a release
    Then the repo is cloned
    And the release is created
