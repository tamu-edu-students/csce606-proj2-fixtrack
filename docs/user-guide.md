# User Guide

> **Status:** Placeholder. Add screenshots and verified workflows after the
> corresponding features are implemented.

## What Is FixTrack?

FixTrack centralizes equipment records and the maintenance process from
problem report through repair completion.

## Roles

### Manager

- Register and manage equipment
- Review maintenance tickets
- Assign tickets to technicians
- Monitor equipment and ticket status
- Review repair history

### Technician

- View assigned tickets
- Update ticket status
- Document repair work
- Record resolution information

## Example Workflow

1. A user signs in.
2. The user reports a problem against an equipment record.
3. A manager reviews the ticket and assigns a technician.
4. The technician moves the ticket through `Assigned`, `In Progress`, and
   `Resolved`.
5. The technician records the completed repair.
6. The team reviews the equipment's maintenance history.

## Validation and Permissions

Required fields should display a clear validation message when omitted.
Unauthorized actions should be rejected and should not modify data.

> **TODO:** Add the actual sign-in, equipment, ticket, assignment, and repair
> screens with screenshots and field-level instructions.

## Troubleshooting

| Problem | Example next step |
| --- | --- |
| Cannot sign in | Verify credentials and confirm the account exists. |
| Cannot edit equipment | Confirm the account has the manager role. |
| Ticket is missing | Check the equipment and ticket filters. |

