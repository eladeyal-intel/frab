require 'test_helper'

class FilterAndSendMailTest < FeatureTest
  setup do
    @conference = create(:three_day_conference, :with_rooms, :with_events, :with_speakers)
    @event = @conference.events.first
    @admin = create(:admin_user)
  end

  it 'can create a template and use it for filter and send', js: true do
    sign_in_user(@admin)
    
    # Create a template
    visit "/#{@conference.acronym}/mail_templates"
    click_on "Add mail template"
    fill_in 'Name', with: 'template1'
    fill_in 'Subject', with: 'mail regarding %{event}'
    fill_in 'Content', with: 'come to %{room} please'
    click_on 'Create Mail template'
    assert_content page, 'Mail template was successfully added'
    assert_content page, 'template1'

    # Filter
    visit "/#{@conference.acronym}/events"
    fill_in 'term', with: @event.title
    find("input#term").send_keys(:enter)

    assert_content page, @event.title
    @conference.events.each do |e|
      unless e == @event
        refute_content page, e.title
      end
    end
    
    # and Send
    click_on 'Send mail to all these people' # here for readiblity; not really reliable
    select 'template1', from: "template_name", visible: :all
    find('input', visible: :all, id: 'bulk_email').trigger('click')
    
    assert_content page, 'Mails delivered'

    emails = ActionMailer::Base.deliveries                                      
    assert emails.count == 1 # without filtering, we would've seen 3            
    
    m = emails.first
    assert m.to == [ @event.event_people.where(event_role: :speaker).first.person.email ]
    assert m.subject == "mail regarding #{@event.title}"
    assert m.body.include? "come to #{@event.room.name} please"
  end
end

