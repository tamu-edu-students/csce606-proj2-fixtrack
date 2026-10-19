# Testing Strategy

> **Status:** Initial placeholder. Link each test area to the implemented
> feature and record measured coverage here.

## Test Levels

### Unit Tests

RSpec examples should cover model validations, associations, authorization
rules, and other isolated behavior. Tests should be FIRST:

- Fast
- Independent and isolated
- Repeatable
- Self-validating
- Timely

### Acceptance Tests

Cucumber scenarios should describe user-visible behavior in three to eight
clear steps. Each feature should include happy and sad paths.

Example:

```gherkin
Scenario: Manager assigns an open ticket
  Given a manager is signed in
  And an open ticket exists
  When the manager assigns the ticket to a technician
  Then the ticket shows the assigned technician
```

## Coverage Goals

- Acceptance-test coverage: at least 90%
- Unit-test coverage: at least 90%
- Combined coverage: at least 90%
- All tests pass before merge
- Zero RuboCop offenses in models, controllers, helpers, and tests

## Verification Commands

```bash
bundle exec rspec
./bin/cucumber
./bin/rubocop
```

> **TODO:** Add the project's coverage command and CI workflow once
> configured.
