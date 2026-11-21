# Preventive maintenance — #13

From an equipment record, select Preventive maintenance to view that asset's
scheduled work. Managers can select Schedule preventive maintenance, enter
a task and a future due date, and save it. Both fields are required. Task text
is trimmed; blank or whitespace-only tasks are rejected. Missing, malformed,
today's, and past due dates are rejected on creation with field-level errors.
The entered task is retained after a failed submission.

Future means strictly after `Date.current` in the application's configured
time zone. The form displays today's application date and an earliest date
of tomorrow. Server validation applies even if browser validation is bypassed.
Saved tasks stay visible after their dates pass; this is a scheduling list,
not a completion tracker.

The list is ordered by due date and shows only the selected equipment's work.
Managers, Technicians, and Reporters can read it under the same read-access
rules as the current equipment policy. Only Managers can open or submit the
creation form. Unauthorized direct requests return HTTP 403 without changing
data. Anonymous requests require login. Equipment is selected by the nested
URL; a submitted equipment ID cannot redirect a schedule to a different asset.

The feature uses normal HTML links and forms and works without JavaScript.
The success message and list confirm saving, and users can revisit the list.
Equipment with saved schedules cannot be deleted silently: the association
returns a restriction error and the database foreign key preserves the link.
This does not decide the separate ticket-history deletion policy.

## Setup and verification

```sh
bundle exec rails db:migrate
RAILS_ENV=test bundle exec rails db:migrate
bundle exec rspec spec/models/preventive_maintenance_schedule_spec.rb spec/policies/preventive_maintenance_schedule_policy_spec.rb spec/requests/preventive_maintenance_schedules_spec.rb
bundle exec cucumber features/preventive_maintenance.feature --strict
```

The migration adds equipment, task, due date, timestamps, a foreign key, and
an equipment/due-date index for the ordered list. It does not change existing
equipment or ticket records. Existing main test and migration limitations must
still be accounted for when preparing an environment.

Recurrence, notifications, automatic tickets, technician assignment, schedule
editing/deletion, and task completion are outside this story. This remains
stretch work and must not delay the MVP or release verification.
