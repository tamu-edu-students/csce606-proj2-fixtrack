require "warden/test/helpers"
require "rspec/expectations"

World(Warden::Test::Helpers)
World(RSpec::Matchers)

Before("@preventive_maintenance") { Warden.test_mode! }
After("@preventive_maintenance") { Warden.test_reset! }

Given("I am signed in for preventive maintenance as a {string}") do |role|
  company = Company.create!(name: "Scheduling example company")
  user = User.create!(name: "Schedule #{role}", email: "schedule-#{role}@example.test",
    password: "Schedule-test-123!", role: role, company: company)
  login_as(user, scope: :user)
end

Given("I am signed out for preventive maintenance") { logout(:user) }

Given("equipment is available for preventive maintenance") do
  @scheduled_equipment = Equipment.create!(name: "Pump", asset_identifier: "PM-013", location: "Lab", status: "Available")
end

When("I save a future preventive maintenance task") do
  visit equipment_path(@scheduled_equipment)
  click_link "Preventive maintenance", exact: true
  click_link "Schedule preventive maintenance", exact: true
  fill_in "Task", with: "Inspect bearings"
  fill_in "Due date", with: Date.tomorrow.iso8601
  click_button "Save schedule"
end

Then("I can see the saved preventive maintenance task") do
  expect(page).to have_content("Preventive maintenance scheduled successfully.")
  expect(page).to have_content("Inspect bearings")
  expect(page).to have_content(Date.tomorrow.iso8601)
  expect(PreventiveMaintenanceSchedule.find_by!(task: "Inspect bearings").equipment_id).to eq(@scheduled_equipment.id)
end

Then("the preventive maintenance task remains visible after reload") do
  visit equipment_preventive_maintenance_schedules_path(@scheduled_equipment)
  expect(page).to have_content("Inspect bearings")
end

When("I submit preventive maintenance due {string}") do |relative_date|
  date = { "today" => Date.current, "yesterday" => Date.yesterday }.fetch(relative_date)
  visit new_equipment_preventive_maintenance_schedule_path(@scheduled_equipment)
  fill_in "Task", with: "Inspect bearings"
  fill_in "Due date", with: date.iso8601
  click_button "Save schedule"
end

When("I submit preventive maintenance without a task") do
  visit new_equipment_preventive_maintenance_schedule_path(@scheduled_equipment)
  fill_in "Due date", with: Date.tomorrow.iso8601
  click_button "Save schedule"
end

Then("I should see the preventive maintenance error {string}") do |message|
  expect(page.status_code).to eq(422)
  expect(page).to have_content(message)
end

Then("no preventive maintenance schedule is saved") do
  expect(PreventiveMaintenanceSchedule.count).to eq(0)
end

When("I directly submit a preventive maintenance schedule") do
  page.driver.submit(:post, equipment_preventive_maintenance_schedules_path(@scheduled_equipment), {
    preventive_maintenance_schedule: { task: "Unauthorized task", due_date: Date.tomorrow.iso8601 }
  })
end

Then("preventive maintenance access is forbidden without saving a schedule") do
  expect(page.status_code).to eq(403)
  expect(PreventiveMaintenanceSchedule.count).to eq(0)
end

Then("I must sign in before scheduling and no schedule is saved") do
  expect(page).to have_current_path(new_user_session_path, ignore_query: true)
  expect(PreventiveMaintenanceSchedule.count).to eq(0)
end
