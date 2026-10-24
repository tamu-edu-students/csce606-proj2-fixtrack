# FixTrack Story Refinement

This document is the concise reference for the approved FixTrack backlog.
GitHub issue bodies contain the detailed user story, acceptance criteria, and
implementation tasks. GitHub labels identify the sprint and epic.

## Roles

### Admin

The Admin is responsible for user provisioning. An Admin can create Managers,
Technicians, Reporters, and other Admins. The application must start with at
least one provisioned Admin account so the first Admin can log in and create
the remaining users.

### Manager

The Manager coordinates equipment and ticket work. A Manager can create,
update, and delete equipment, review reported tickets, update priority, assign
Technicians, and provision Technicians and Reporters. Managers cannot create
Admins.

### Technician

The Technician works on tickets assigned to them, updates repair status, and
records repair work. Technicians cannot provision users or manage equipment.

### Reporter

The Reporter submits equipment-problem tickets and views, verifies, resolves,
or reopens their submitted tickets. Reporters cannot provision users, manage
equipment, assign Technicians, or work on tickets assigned to others.

## Epics

### Epic A — Authentication and authorization

Provides login, logout, protected access, user roles, and role-based
permissions.

### Epic B — Equipment management

Provides manager equipment management and authenticated equipment discovery.

### Epic C — Reporter workflow

Provides the reporter journey from submitting a ticket through viewing,
verifying, resolving, or reopening it.

### Epic D — Manager dispatch workflow

Provides the manager queue, ticket prioritization, and technician assignment.

### Epic E — Technician repair workflow

Provides assigned-ticket work, status updates, and repair records. The
technician moves a ticket to `Ready for Verification`; the reporter decides
whether it is resolved or reopened.

### Epic F — Stretch work

Contains optional work that must not delay the MVP, presentation, deployment,
documentation, or final demo.

## Sprint 1 — Foundation

**Dates:** October 22-November 11, 2026

Sprint 1 establishes authentication, roles, user provisioning, equipment,
equipment discovery, and reporter ticket intake. Sprint 1 stories must not
depend on Sprint 2 stories.

### A1 — Log in and log out

- **GitHub issue:** [#4](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/4)
- **Epic:** Authentication and authorization
- **Scope:** Create and destroy user sessions, handle valid and invalid login, and provide logout.
- **Depends on:** None

### A2 — Restrict equipment changes by role

- **GitHub issue:** [#7](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/7)
- **Epic:** Authentication and authorization
- **Scope:** Enforce manager-only equipment create, update, and delete authorization. This does not implement equipment CRUD.
- **Depends on:** A1

### A3 — Define application roles and permissions

- **GitHub issue:** [#20](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/20)
- **Epic:** Authentication and authorization
- **Scope:** Define the Admin, Manager, Technician, and Reporter roles and enforce their allowed and denied actions. This does not implement role-specific feature behavior or user provisioning.
- **Depends on:** A1

### A4 — Experience as an unauthenticated user

- **GitHub issue:** [#21](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/21)
- **Epic:** Authentication and authorization
- **Scope:** Provide the public landing page, login entry point, and clear protection of unauthenticated access.
- **Depends on:** A1

### A5 — Provision users as an Admin

- **GitHub issue:** [#24](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/24)
- **Epic:** Authentication and authorization
- **Scope:** Seed at least one Admin account and allow Admins to provision Admins, Managers, Technicians, and Reporters. Protect the bootstrap and last-Admin rules.
- **Depends on:** A1, A3

### A6 — Provision users as a Manager

- **GitHub issue:** [#25](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/25)
- **Epic:** Authentication and authorization
- **Scope:** Allow Managers to provision Technicians and Reporters only. Prevent Managers from creating or promoting Admins or Managers.
- **Depends on:** A3, A5

### B1 — Manage equipment records

- **GitHub issue:** [#5](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/5)
- **Epic:** Equipment management
- **Scope:** Create, view, update, and delete equipment with required fields, unique asset identifiers, and the agreed deletion policy. This issue is protected because PR [#14](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/pull/14) is active.
- **Depends on:** A1, A2

### B2 — Search for equipment

- **GitHub issue:** [#15](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/15)
- **Epic:** Equipment management
- **Scope:** Search for equipment by name or asset identifier and select the correct equipment for reporting.
- **Depends on:** A1, A3, B1

### B3 — View open tickets for equipment

- **GitHub issue:** [#19](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/19)
- **Epic:** Equipment management
- **Scope:** Display open tickets for the selected equipment while excluding tickets belonging to other equipment.
- **Depends on:** A1, A3, B1

### C1 — Report an equipment problem

- **GitHub issue:** [#6](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/6)
- **Epic:** Reporter workflow
- **Scope:** Allow a Reporter to create a ticket for selected equipment with its reporter, description, priority, and initial status.
- **Depends on:** A1, A3, B1, B2

### C2 — Reject invalid ticket data

- **GitHub issue:** [#8](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/8)
- **Epic:** Reporter workflow
- **Scope:** Reject incomplete or invalid ticket values, show understandable errors, and prevent invalid records from being persisted.
- **Depends on:** C1

### C3 — View submitted tickets

- **GitHub issue:** [#16](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/16)
- **Epic:** Reporter workflow
- **Scope:** Show a Reporter only the tickets they submitted, including equipment, priority, status, and assignment details.
- **Depends on:** A1, A3, C1

## Sprint 2 — Dispatch and repair workflow

**Dates:** November 12-December 2, 2026

Sprint 2 depends on the completed Sprint 1 foundation. December 3-6 is
reserved for presentation, demo, deployment, documentation, and release
preparation.

### D1 — View the manager ticket queue

- **GitHub issue:** [#18](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/18)
- **Epic:** Manager dispatch workflow
- **Scope:** Show managers the outstanding tickets from all reporters with equipment, reporter, priority, status, and assignee information.
- **Depends on:** C3

### D2 — Review ticket priority

- **GitHub issue:** [#23](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/23)
- **Epic:** Manager dispatch workflow
- **Scope:** Allow managers to review and update supported ticket priority values.
- **Depends on:** D1

### D3 — Assign a technician

- **GitHub issue:** [#9](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/9)
- **Epic:** Manager dispatch workflow
- **Scope:** Allow managers to assign eligible technicians and reject invalid or unauthorized assignments.
- **Depends on:** D1

### E1 — View assigned tickets

- **GitHub issue:** [#17](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/17)
- **Epic:** Technician repair workflow
- **Scope:** Show a technician only the tickets assigned to them and provide access to their ticket details.
- **Depends on:** D3

### E2 — Update ticket status

- **GitHub issue:** [#10](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/10)
- **Epic:** Technician repair workflow
- **Scope:** Allow assigned technicians to move tickets through `Open`, `Assigned`, `In Progress`, and `Ready for Verification`.
- **Depends on:** E1

### E3 — Add a repair record

- **GitHub issue:** [#11](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/11)
- **Epic:** Technician repair workflow
- **Scope:** Allow assigned technicians to add one or more validated repair records without automatically resolving the ticket.
- **Depends on:** E1, E2

### C4 — Verify or reopen a repaired ticket

- **GitHub issue:** [#22](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/22)
- **Epic:** Reporter workflow
- **Scope:** Allow the Reporter to mark a `Ready for Verification` ticket `Resolved` or reopen it with a required reason. A manager may override with a reason.
- **Depends on:** C3, E2, E3

### C5 — View equipment maintenance history

- **GitHub issue:** [#12](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/12)
- **Epic:** Reporter workflow
- **Scope:** Display tickets and repair records for the selected equipment, including repair descriptions, technicians, and completion dates.
- **Depends on:** B3, E3

## Stretch work

### F1 — Schedule preventive maintenance

- **GitHub issue:** [#13](https://github.com/tamu-edu-students/csce606-proj2-fixtrack/issues/13)
- **Epic:** Stretch work
- **Scope:** Allow managers to create validated preventive-maintenance schedules for existing equipment.
- **Depends on:** B1
- **Constraint:** Begin only after MVP completion and release preparation.

## Dependency summary

```text
A1
├── A2 ── B1 ── B2 ── C1 ── C2
│    └── B3 ─────────────── C5
├── A3 ── C3 ── D1 ── D2
│    ├── A5 ── A6
│    └── D3 ── E1 ── E2 ── E3 ── C4
└── A4
```

The diagram shows the primary delivery path. A story may also depend on
multiple stories listed in its entry above.
