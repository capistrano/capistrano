Feature: Installation

  Background:
    Given a test app with the default configuration

  Scenario: With default stages
    When I run cap "install"
    Then the deploy.rb file is created
    And the default stage files are created
    And the tasks folder is created

  Scenario: With specified stages
    When I run cap "install STAGES=qa,production"
    Then the deploy.rb file is created
    And the specified stage files are created
    And the tasks folder is created
