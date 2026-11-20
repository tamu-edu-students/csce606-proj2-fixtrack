@equipment
Feature: Search for equipment
  As an authenticated user
  I want to search equipment by name or asset identifier
  So that I can select the correct equipment before reporting a problem

  Scenario Outline: Find and select equipment using a partial match
    Given I am authenticated for equipment management as a "reporter"
    And searchable equipment records exist
    When I search equipment for "<query>"
    Then the equipment search results identify only "Oscilloscope"
    And I can open the matching equipment record

    Examples:
      | query       |
      |   OSCIL     |
      | lab-015     |

  Scenario: No equipment matches the search
    Given I am authenticated for equipment management as a "technician"
    And searchable equipment records exist
    When I search equipment for "missing instrument"
    Then I should see the equipment text "No equipment matches your search."
    And the equipment search field contains "missing instrument"

  Scenario: A whitespace-only search shows available equipment
    Given I am authenticated for equipment management as a "manager"
    And searchable equipment records exist
    When I search equipment for whitespace only
    Then both searchable equipment records are listed

  Scenario: Search never changes equipment records
    Given I am authenticated for equipment management as a "reporter"
    And searchable equipment records exist
    When I search equipment for "lab"
    Then the searchable equipment records are unchanged

  Scenario: Anonymous visitors cannot search equipment
    Given I am not authenticated for equipment management
    When I request an equipment search for "lab"
    Then I should be directed to the equipment sign in page
