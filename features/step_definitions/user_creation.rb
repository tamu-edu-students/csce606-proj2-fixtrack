Given("a manager exists") do
  @company = Company.create!(name: "ABC Company")

  @manager = User.create!(
    name: "Bruce Wayne",
    email: "manager@example.com",
    password: "password123",
    password_confirmation: "password123",
    role: "manager",
    company: @company
  )
end

Given("I am logged in as a manager") do
  login_as(@manager, scope: :user)
end

Given("I am on the user creation page") do
  visit new_user_path

  puts "CURRENT URL: #{page.current_url}"
  puts "FORM ACTION: #{page.find('form')[:action]}"
  puts "FORM METHOD: #{page.find('form')[:method]}"
end

When("I select {string} with {string}") do |field, value|
  select value, from: field
end
