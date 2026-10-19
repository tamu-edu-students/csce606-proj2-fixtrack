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

## Deployment

> **TODO:** Document the production host, required environment variables,
> database provisioning, asset preparation, deployment command, health check,
> and rollback procedure.

## Architecture References

- [Architecture](architecture.md)
- [Testing Strategy](testing-strategy.md)
- [User Guide](user-guide.md)
