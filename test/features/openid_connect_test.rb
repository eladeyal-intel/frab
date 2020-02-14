require 'test_helper'

class OpenIDConnectTest < FeatureTest
  PASSWORD='Frab2020'
  EMAIL='test@example.com'


  setup do
    assert User.where(email: EMAIL).blank?
  end

  def connect_with_openid_connect
    visit '/'

    click_on 'Log-in'
    click_on 'Sign in with dev-853138.okta.com'

    assert_content page, 'Need help signing in?'
    
    find('body').send_keys(EMAIL)
    find('body').send_keys(:tab)
    find('body').send_keys(PASSWORD)
    find('body').send_keys(:return)

    debugger
    
    #fill_in 'okta-signin-username', with: EMAIL
    #fill_in 'okta-signin-password', with: PASSWORD
    
    #click_button 'okta-signin-submit'
    
    assert_content page, 'Successfully authenticated'
    assert User.where(email: EMAIL).any?
    
    click_on 'Logout'
  end

# Currently testing only once - second test would not result
# in a new login prompt 
  it 'can sign up and sign in with openid connect', js:true do
    connect_with_openid_connect
  end

  teardown do
    User.where(email: EMAIL).destroy_all
  end
end

