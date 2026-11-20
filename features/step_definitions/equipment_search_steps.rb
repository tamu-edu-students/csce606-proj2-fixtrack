Given("searchable equipment records exist") do
  @matching_equipment = Equipment.create!(name: "Oscilloscope", asset_identifier: "LAB-015", location: "Lab A", status: "Available")
  Equipment.create!(name: "Printer", asset_identifier: "OFFICE-002", location: "Office", status: "Available")
  @search_equipment_snapshot = Equipment.order(:id).map(&:attributes)
end

When("I search equipment for {string}") do |query|
  visit equipment_index_path
  fill_in "Search equipment", with: query
  click_button "Search"
end

When("I search equipment for whitespace only") do
  visit equipment_index_path
  fill_in "Search equipment", with: "   "
  click_button "Search"
end

When("I request an equipment search for {string}") do |query|
  visit equipment_index_path(q: query)
end

Then("the equipment search results identify only {string}") do |name|
  expect(page).to have_css("tbody tr", count: 1)
  within("tbody") do
    expect(page).to have_link(name, href: equipment_path(@matching_equipment))
    expect(page).to have_content("LAB-015")
    expect(page).to have_content("Lab A")
    expect(page).to have_content("Available")
    expect(page).not_to have_content("OFFICE-002")
  end
end

Then("I can open the matching equipment record") do
  click_link @matching_equipment.name, exact: true
  expect(page).to have_current_path(equipment_path(@matching_equipment))
  expect(page).to have_content("LAB-015")
end

Then("the equipment search field contains {string}") do |query|
  expect(page).to have_field("Search equipment", with: query)
end

Then("both searchable equipment records are listed") do
  expect(page).to have_css("tbody tr", count: 2)
  expect(page).to have_content("LAB-015")
  expect(page).to have_content("OFFICE-002")
end

Then("the searchable equipment records are unchanged") do
  expect(Equipment.order(:id).map(&:attributes)).to eq(@search_equipment_snapshot)
end
