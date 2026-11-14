require "tmpdir"
ENV["RAILS_ENV"] = "test"
require_relative "../config/environment"

ActiveRecord::Migration.verbose = false

def check(condition, message)
  raise message unless condition
end

[ :fresh, :legacy ].each do |kind|
  Dir.mktmpdir("fixtrack-migration-check-") do |directory|
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: File.join(directory, "test.sqlite3"))
    context = ActiveRecord::MigrationContext.new(Rails.root.join("db/migrate"))
    if kind == :legacy
      context.migrate(20261027041716)
      connection = ActiveRecord::Base.connection
      connection.add_column :users, :role, :string, default: "technician", null: false
      connection.add_reference :users, :company, null: false, foreign_key: true
      context.migrate(20261027202928)
      connection.execute("INSERT INTO companies (id, name, created_at, updated_at) VALUES (1, 'Migration fixture', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)")
      connection.execute("INSERT INTO users (id, email, encrypted_password, role, company_id, created_at, updated_at) VALUES (1, 'migration@example.test', 'preserved-password-hash', 'manager', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)")
    end
    context.migrate
    connection = ActiveRecord::Base.connection
    columns = connection.columns(:users).index_by(&:name)
    check(columns.fetch("company_id").null, "Company must remain optional")
    check(columns.fetch("role").null && columns.fetch("role").default.nil?, "Role schema must match committed schema")
    check(connection.index_exists?(:users, :company_id), "Missing company index")
    check(connection.foreign_key_exists?(:users, :companies), "Missing company foreign key")
    check(!context.needs_migration?, "Pending migrations remain")
    if kind == :legacy
      row = connection.select_one("SELECT * FROM users WHERE id = 1")
      check(row.fetch("email") == "migration@example.test", "Existing user lost")
      check(row.fetch("role") == "manager" && row.fetch("company_id") == 1, "Existing assignments changed")
      check(row.fetch("encrypted_password") == "preserved-password-hash", "Existing password hash changed")
    end
    puts "PASS: #{kind} migration path; schema constraints and preserved data verified"
    ActiveRecord::Base.connection_pool.disconnect!
  end
end
