Feature: Installation

  Background:
    Given a test app without any configuration

  Scenario: The "install" task documentation can be viewed
    When I run "cap -T"
    Then the task is successful
    And contains "cap install" in the output

  Scenario: With default stages
    When I run "cap install"
    Then the deploy.rb file is created
    And the default stage files are created
    And the tasks folder is created

  Scenario: With specified stages
    When I run "cap install STAGES=qa,production"
    Then the deploy.rb file is created
    And the specified stage files are created
    And the tasks folder is created
