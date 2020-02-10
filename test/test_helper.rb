ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/pride'
require 'database_cleaner'
require 'sucker_punch/testing/inline'

require 'minitest/rails/capybara'
require 'selenium-webdriver'

Dir[Rails.root.join('test/support/**/*.rb')].each { |f| require f }

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
  include FactoryBot::Syntax::Methods

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  Capybara.register_driver :chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new(
      args: %w[headless disable-gpu no-sandbox]
    )
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.javascript_driver = :chrome
  DatabaseCleaner.strategy = :truncation

  def setup
    DatabaseCleaner.start
    I18n.locale = I18n.default_locale
  end

  def teardown
    DatabaseCleaner.clean
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers

  def login_as(role)
    user = FactoryBot.create(:user, role: role.to_s)
    sign_in(user)
    user
  end

  def log_out
    sign_out(:user)
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

end

class PunditControllerTest < ActionDispatch::IntegrationTest
  include CrewRolesHelper
end

class FeatureTest < Capybara::Rails::TestCase
  include CapybaraHelper
end
