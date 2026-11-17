Feature: User creation

  As a manager
  I want to create a user login for a technician or reportr
  So that other users can login to the same company

  Background:
    Given a manager exists
    And I am logged in as a manager

  Scenario: Successfully create a user
    Given I am on the user creation page
    When I fill in "Name" with "Dick Grayson"
    And I fill in "Email" with "robin@example.com"
    And I fill in "Password" with "password123"
    And I fill in "Password confirmation" with "password123"
    And I select "role" with "Technician"
    And I click "create user"
    Then I should see "Technician created successfully"
    And a user with email "robin@example.com" should exist
    And the user "robin@example.com" should belong to the company "ABC Company" 