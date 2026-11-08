
Given("I am on the manager registration page") do
  visit new_user_registration_path
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I click {string}") do |button|
  click_button button
end

Then("I should see {string}") do |message|
  expect(page).to have_content(message)
end

Then("a user with email {string} should exist") do |email|
  expect(User.find_by(email: email)).to be_present
end

Then("a company named {string} should exist") do |company_name|
  expect(Company.find_by(name: company_name)).to be_present
end

Then("the user {string} should belong to the company {string}") do |email, company_name|
  user = User.find_by!(email: email)

  expect(user.company.name).to eq(company_name)
end
