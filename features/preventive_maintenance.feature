@preventive_maintenance
Feature: Schedule preventive maintenance
  As a manager
  I want to schedule preventive maintenance for equipment
  So that avoidable failures can be reduced

  Scenario: A manager saves and revisits scheduled work
    Given I am signed in for preventive maintenance as a "manager"
    And equipment is available for preventive maintenance
    When I save a future preventive maintenance task
    Then I can see the saved preventive maintenance task
    And the preventive maintenance task remains visible after reload

  Scenario Outline: A due date must be in the future
    Given I am signed in for preventive maintenance as a "manager"
    And equipment is available for preventive maintenance
    When I submit preventive maintenance due "<when>"
    Then I should see the preventive maintenance error "Due date must be after today"
    And no preventive maintenance schedule is saved

    Examples:
      | when      |
      | today     |
      | yesterday |

  Scenario: A task is required
    Given I am signed in for preventive maintenance as a "manager"
    And equipment is available for preventive maintenance
    When I submit preventive maintenance without a task
    Then I should see the preventive maintenance error "Task can't be blank"
    And no preventive maintenance schedule is saved

  Scenario Outline: Non-managers cannot create schedules through direct requests
    Given I am signed in for preventive maintenance as a "<role>"
    And equipment is available for preventive maintenance
    When I directly submit a preventive maintenance schedule
    Then preventive maintenance access is forbidden without saving a schedule

    Examples:
      | role       |
      | technician |
      | reporter   |

  Scenario: Anonymous requests require sign-in
    Given I am signed out for preventive maintenance
    And equipment is available for preventive maintenance
    When I directly submit a preventive maintenance schedule
    Then I must sign in before scheduling and no schedule is saved
