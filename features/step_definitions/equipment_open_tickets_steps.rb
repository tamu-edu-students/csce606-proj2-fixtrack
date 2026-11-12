Given("equipment ticket examples exist") do
  reporter = User.find_or_create_by!(email: "ticket-fixture@example.test") do |user|
    user.name = "Ticket reporter"
    user.password = "Equipment-test-123!"
    user.role = "reporter"
  end
  other = Equipment.create!(name: "Other instrument", asset_identifier: "OTHER-019", location: "Lab B", status: "Available")
  [
    [ @equipment, "Display flickers", "open" ],
    [ @equipment, "Probe damaged", "assigned" ],
    [ @equipment, "Calibration underway", "in_progress" ],
    [ @equipment, "Completed repair", "resolved" ],
    [ other, "Unrelated equipment problem", "open" ]
  ].each do |equipment, title, status|
    MaintenanceTicket.create!(equipment: equipment, reporter: reporter, title: title,
      description: "Equipment needs attention", priority: "high", status: status)
  end
end

Then("I should see the selected equipment's outstanding ticket summaries") do
  within("section[aria-labelledby='open-tickets-heading']") do
    [ "Display flickers", "Probe damaged", "Calibration underway", "High", "Open", "Assigned", "In progress" ].each do |text|
      expect(page).to have_content(text)
    end
  end
end

Then("I should not see resolved or unrelated equipment tickets") do
  expect(page).not_to have_content("Completed repair")
  expect(page).not_to have_content("Unrelated equipment problem")
end

Then("I can start a report for the selected equipment") do
  click_link "Report a problem for this equipment", exact: true
  expect(page).to have_select("Equipment", selected: @equipment.name)
  expect(page).to have_select("Priority", with_options: [ "High" ])
end

When("I report an urgent problem for the selected equipment") do
  click_link "Report a problem for this equipment", exact: true
  expect(page).to have_select("Equipment", selected: @equipment.name)
  fill_in "Problem Title", with: "Urgent smoke issue"
  fill_in "Problem Description", with: "Smoke visible"
  select "High", from: "Priority"
  click_button "Submit Problem Report"
end

Then("the urgent ticket is saved for that equipment and the signed-in reporter") do
  expect(page).to have_content("Urgent smoke issue")
  ticket = MaintenanceTicket.find_by!(title: "Urgent smoke issue")
  expect(ticket.equipment_id).to eq(@equipment.id)
  expect(ticket.priority).to eq("high")
  expect(ticket.reporter.email).to eq("equipment-reporter@example.test")
end
