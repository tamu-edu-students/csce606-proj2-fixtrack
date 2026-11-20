# Equipment search — #15

After signing in, open Equipment and enter part of a name or asset identifier
in Search equipment. Search ignores capitalization and surrounding spaces.
Each matching record appears once with its name, asset identifier, location,
and status. Select its name to open the equipment record.

The query remains in the form so it can be refined. Clear search returns to
the equipment list. Blank and whitespace-only searches show the normal list;
a nonblank search without matches shows "No equipment matches your search."
Search uses a GET form and ordinary links, so it works without JavaScript.

The existing equipment policy authorizes the request before searching.
Managers, Technicians, and Reporters currently have read access to equipment;
this feature does not expand that policy or add an Admin role. Search only
reads records. SQL parameters and escaped LIKE metacharacters ensure `%`,
`_`, backslashes, and SQL-like text are treated as literal search input.
The search method preserves an existing relation when chained to one.

No migration is required. The unique asset-identifier index already exists.
Leading-wildcard searches on LOWER(name) or LOWER(asset_identifier) require a
scan at the current project scale; a normal extra B-tree index would not make
these substring searches efficient. Reassess indexing if the dataset grows.

Ticket creation (#6), open tickets (#19), and maintenance history (#12) retain
their existing ownership and scope. Search links to equipment details.

## Verification

```sh
bundle exec rspec spec/models/equipment_search_spec.rb spec/requests/equipment_search_spec.rb
bundle exec cucumber features/equipment_search.feature --strict
```

The shared equipment acceptance fixture supplies a company because the merged
User model now requires company membership. This only updates test setup.
