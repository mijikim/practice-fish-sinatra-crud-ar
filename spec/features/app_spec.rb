require "spec_helper"

feature "Homepage" do
  scenario "check homepage" do
    visit "/"
    expect(page).to have_link("Registration")
    expect(page).to have_content("username")
    expect(page).to have_content("password")
    expect(page).to have_button("Login")
  end
end
feature "Register page" do
  scenario "visit registration page" do
    visit "/"
    click_link "Registration"
    expect(page).to have_content("username")
    expect(page).to have_content("password")
  end
  scenario "empty username" do
    visit "/registration"
    fill_in 'username', with: ''
    fill_in 'password', with: 'Ilovekittens'
    click_button "Submit"
    expect(page).to have_content("Please fill in username")
  end
  scenario "empty password" do
    visit "/registration"
    fill_in 'username', with: 'Lindsay'
    fill_in 'password', with: ''
    click_button "Submit"
    expect(page).to have_content("Please fill in password")
  end
  scenario "empty all" do
    visit "/registration"
    fill_in 'username', with: ''
    fill_in 'password', with: ''
    click_button "Submit"
    expect(page).to have_content("Please fill in username and password")
  end
  scenario "empty all" do
    visit "/registration"
    rand = rand(1000)
    fill_in 'username', with:  "asd#{rand}"
    fill_in 'password', with: 'qwe'
    click_button "Submit"
    click_link "Registration"
    fill_in 'username', with: "asd#{rand}"
    fill_in 'password', with: 'qwe'
    click_button "Submit"
    expect(page).to have_content("Username is already in use, please choose another.")
  end

end
feature "Fill in form and see greeting" do
  scenario "visit registration page" do
    visit "/registration"
    fill_in 'username', with: 'Lindsay' + rand(1000).to_s
    fill_in 'password', with: 'Ilovekittens'
    click_button "Submit"
    expect(page).to have_content("Thank you for registering")
  end
end
feature "Login and out" do
  scenario "have logged out" do
    visit "/"
    click_link "Registration"
    fill_in 'username', with:  'Alex'
    fill_in 'password', with: 'Ilovepuppies'
    click_button "Submit"
    fill_in 'username', with: 'Alex'
    fill_in 'password', with: 'Ilovepuppies'
    click_button "Login"
    expect(page).to have_content("Welcome, Alex")
    expect(page).to have_button("Logout")
    expect(page).to have_no_button("Login")
    expect(page).to have_no_link("Registration")

    click_button "Logout"
    expect(page).to have_no_button("Logout")
    expect(page).to have_button("Login")
    expect(page).to have_link("Registration")
  end
end
feature "Display users" do
  scenario "on user page display other current users" do
    visit "/"
    click_link "Registration"
    fill_in 'username', with:  'Phil'
    fill_in 'password', with: 'Iloveponies'
    click_button "Submit"
    visit "/"
    click_link "Registration"
    fill_in 'username', with:  'Steve'
    fill_in 'password', with: 'Ilovefish'
    click_button "Submit"
    visit "/"
    click_link "Registration"
    fill_in 'username', with:  'John'
    fill_in 'password', with: 'Ilovebirds'
    click_button "Submit"
    fill_in 'username', with: 'Phil'
    fill_in 'password', with: 'Iloveponies'
    click_button "Login"
    expect(page).to have_content("John")
    expect(page).to have_content("Steve")
    visit "/"
    expect(page).to have_no_content("Phil")
    click_button "Sort"
    expect(page).to have_content("John Steve")
  end
end