# Technical Documentation

> **Status:** Placeholder. Replace examples with verified project instructions as
> the application is implemented.

## Overview

FixTrack is a Rails web application for tracking equipment, maintenance
tickets, technician assignments, repairs, and equipment history.

## Prerequisites

- Ruby version: see [.ruby-version](../.ruby-version)
- Bundler
- SQLite for local development
- Git

## Setup from a Fresh Clone

```bash
git clone git@github.com:tamu-edu-students/csce606-proj2-fixtrack.git
cd csce606-proj2-fixtrack
./bin/setup
```

The setup script should install dependencies, prepare the development
database, and perform any required initialization.

## Running Locally

```bash
./bin/dev
```

Open the local URL printed by the development server. If `./bin/dev` is not
available in a given environment, use:

```bash
./bin/rails server
```

## Tests and Quality Checks

```bash
./bin/rails test
bundle exec rspec
./bin/cucumber
./bin/rubocop
./bin/brakeman
./bin/bundler-audit
```

> **Example:** The final commands and coverage command will be documented here
> once the test and coverage configuration is finalized.

## Database

```bash
./bin/rails db:prepare
./bin/rails db:seed
```

Document migrations, seed data, and reset procedures here as the data model
evolves.

### User-field migration compatibility

The company and role fields belong to `AddCompanyToUsers` and
`AddRoleToUsers`, respectively. The initial Devise migration must not also
create them. The later migrations accept those fields when already present
in a database created with the older Devise migration, preserving existing
accounts, password hashes, company assignments, and role values.

`AddRoleToUsers` removes the old database default and permits null values to
match the committed schema; the User model still validates roles and assigns
Reporter to new users without an explicit role. Company membership remains
optional after `AllowUsersWithoutCompany`.

If setup previously stopped at a duplicate `company_id` or `role` field,
update to the repaired migration files and rerun `bundle exec rails db:migrate`
for the affected environment. Do not delete the database or manually mark
migrations complete. Already-completed migrations are not rerun by this repair.

Run `bundle exec ruby script/check_user_migrations.rb` to check both migration
paths in temporary databases, including preservation of an existing account.

## Deployment

> **TODO:** Document the production host, required environment variables,
> database provisioning, asset preparation, deployment command, health check,
> and rollback procedure.

## Architecture References

- [Architecture](architecture.md)
- [Testing Strategy](testing-strategy.md)
- [User Guide](user-guide.md)
