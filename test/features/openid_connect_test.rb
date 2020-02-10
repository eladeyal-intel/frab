require 'test_helper'
require 'capybara/mechanize'

class OpenIdConnectTest < FeatureTest
  LOGIN='test@example.com'
  PASSWORD='Frab2020'
  EMAIL='test@example.com'


  setup do
    assert User.where(email: EMAIL).blank?
  end

  it 'can sign up with OpenID Connect' do
    Capybara.current_driver = :mechanize
    visit "/"
    click_on 'Log-in'
    
    click_on 'Sign in with dev-853138.okta.com'
    

    puts "** fill_in"
    page.refresh
    debugger
    fill_in 'Username:', with: LOGIN
    fill_in 'Password:', with: PASSWORD
    puts "** click sign in"
    click_on 'Sign In'
   
    assert_content page, 'Successfully authenticated'
    assert User.where(email: EMAIL).any?
    
    click_on 'Logout'
  end
  
  teardown do
    User.where(email: EMAIL).destroy_all
  end
end