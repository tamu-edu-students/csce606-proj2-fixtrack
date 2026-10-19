# Architecture

> **Status:** Initial placeholder. Update this document when the models,
> routes, and deployment architecture are finalized.

## System Context

```text
Maintenance Manager ─┐
                     ├──> FixTrack Rails Application ───> Database
Technician ──────────┘                 │
                                       └──> Deployment Platform
```

## Core Domain

```text
User
 ├── has a role: Manager or Technician
 ├── reports MaintenanceTickets
 └── performs Repairs

Equipment
 ├── has MaintenanceTickets
 └── has a repair history through those tickets

MaintenanceTicket
 ├── belongs to Equipment
 ├── has a Reporter
 ├── may have an assigned Technician
 └── may have a Repair
```

## Ticket State Flow

```text
Open -> Assigned -> In Progress -> Resolved
```

Invalid or unauthorized transitions must be rejected with an appropriate
response.

## Application Layers

- **Views:** user-facing HTML and forms
- **Controllers:** authentication, authorization, and request orchestration
- **Models:** domain validation, associations, and persistence
- **Database:** users, equipment, tickets, and repair records
- **Jobs/services:** document here when introduced

## Diagrams To Add

- [ ] Final system/context diagram
- [ ] Final class diagram
- [ ] Final database entity-relationship diagram
- [ ] Deployment diagram
