# View open tickets for equipment — #19

After signing in, open an equipment record. Its open-ticket section lists
problem summaries, priorities, and statuses for that equipment only. With the
currently merged ticket workflow, `open`, `assigned`, and `in_progress` are
outstanding; `resolved` is excluded. These definitions must be reconciled when
the team merges a different status workflow.

Managers, Technicians, and Reporters can read this section under the existing
equipment policy. Anonymous visitors are redirected to sign in. No new roles
or ticket-editing permissions are introduced.

When no outstanding tickets exist, an empty-state message is shown. The
"Report a problem for this equipment" link remains available even when tickets already exist.
It opens the existing report form with the selected equipment prefilled;
users can choose High priority for an urgent problem. Normal ticket validation
and signed-in reporter assignment still apply. These workflows use ordinary
HTML links and forms and do not require JavaScript.

No database migration is needed. `Equipment#maintenance_tickets` scopes the
query to the selected record. This association does not introduce a deletion
policy or change equipment-history behavior.

## Verification

```sh
bundle exec rspec spec/requests/equipment_open_tickets_spec.rb
bundle exec cucumber features/equipment_open_tickets.feature --strict
```

Request coverage includes all three current roles, active statuses, unrelated
equipment, resolved tickets, empty states, anonymous access, missing equipment,
and an urgent report despite existing tickets. Cucumber covers the browser
workflow with the rack-test driver (no JavaScript).
