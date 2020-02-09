require 'test_helper'

class OpenIDConnectTest < FeatureTest
  LOGIN='alice'
  PASSWORD='secret'
  EMAIL='alice@wonderland.net'

  setup do
    assert User.where(email: EMAIL).blank?
  end

  def connect_with_openid_connect
    visit '/'
   
    click_on 'Log-in'
   
    click_on 'Sign in with free testing server at demo.c2id.com'
    follow_redirect! 

    fill_in 'username', with: LOGIN
    fill_in 'password', with: PASSWORD
    click_on 'Login'
    follow_redirect!
    
    assert_content page, 'Successfully authenticated'
    assert User.where(email: EMAIL).any?
    
    click_on 'Logout'
  end

# Currently testing only once - second test would not result
# in a new login prompt 
  test 'can sign up and sign in with openid connect', js:true do
    connect_with_openid_connect
  end

  teardown do
    User.where(email: EMAIL).destroy_all
  end
end

