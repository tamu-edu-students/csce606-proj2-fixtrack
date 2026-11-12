@equipment
Feature: View open tickets for equipment
  As an authenticated user
  I want to see open tickets for selected equipment
  So that I can avoid reporting a duplicate problem

  Scenario: Only outstanding problems for the selected equipment are displayed
    Given I am authenticated for equipment management as a "reporter"
    And an equipment record exists
    And equipment ticket examples exist
    When I visit the equipment details page
    Then I should see the selected equipment's outstanding ticket summaries
    And I should not see resolved or unrelated equipment tickets

  Scenario: Equipment without open tickets still allows reporting
    Given I am authenticated for equipment management as a "technician"
    And an equipment record exists
    When I visit the equipment details page
    Then I should see the equipment text "No open tickets for this equipment."
    And I can start a report for the selected equipment

  Scenario: An existing ticket does not prevent an urgent report
    Given I am authenticated for equipment management as a "reporter"
    And an equipment record exists
    And equipment ticket examples exist
    When I visit the equipment details page
    And I report an urgent problem for the selected equipment
    Then the urgent ticket is saved for that equipment and the signed-in reporter

  Scenario: Anonymous visitors cannot read equipment tickets
    Given an equipment record exists
    And equipment ticket examples exist
    And I am not authenticated for equipment management
    When I visit the equipment details page
    Then I should be directed to the equipment sign in page
    And I should not see the equipment text "Display flickers"
