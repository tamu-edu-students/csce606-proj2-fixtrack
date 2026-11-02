
Feature: Manager registration

  As a manager
  I want to register my account and create a company
  So that I can manage users and tickets for my company

  Scenario: Successfully register a manager and create a company
    Given I am on the manager registration page
    When I fill in "Name" with "John Smith"
    And I fill in "Email" with "john@example.com"
    And I fill in "Company name" with "ABC Company"
    And I fill in "Password" with "password123"
    And I fill in "Password confirmation" with "password123"
    And I click "Sign up"
    Then I should see "Welcome"
    And a user with email "john@example.com" should exist
    And a company named "ABC Company" should exist
    And the user should belong to the company "ABC Company"
