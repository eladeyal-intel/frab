require 'test_helper'

class FilterAndSendMailTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events_and_speakers)
    @event = @conference.events.last
    @admin = create(:admin_user)
  end

  it 'can create a template and use it for filter and send', js: true do
    sign_in_user(@admin)
    
    # Add mail template
    visit "/#{@conference.acronym}/mail_templates/new"
    fill_in 'Name', with: 'template1'
    fill_in 'Subject', with: 'mail regarding %{event}'
    fill_in 'Content', with: 'come to %{room} please'
    click_on 'Create Mail template'
    assert_content page, 'Mail template was successfully added'
    assert_content page, 'template1'
    
    ['bcc_address@example.com', nil].each do |bcc_email_address|
      @conference.update_attributes(bcc_email_address: bcc_email_address)

      # Filter
      visit "/#{@conference.acronym}/events"
      fill_in 'term', with: @event.title
      find("input#term").send_keys(:enter)
   
      @conference.events.each do |e|
        if e == @event
          assert_content page, e.title
        else
          refute_content page, e.title
        end
      end
      
      # and Send
      ActionMailer::Base.deliveries = []
      click_on 'Send mail to all these people'
      select 'template1', from: "template_name"
      find('input', id: 'bulk_email').trigger('click')
      
      assert_content page, 'Mails delivered'
      
      emails = ActionMailer::Base.deliveries                                      
      assert emails.count == 1 # without filtering, we would've seen 3            
      
      m = emails.first
      assert m.to == [ @event.event_people.where(event_role: :speaker).first.person.email ]
      if bcc_email_address
        assert m.bcc = [ @conference.bcc_email_address ]
      else
        assert m.bcc.empty?
      end
      assert m.subject == "mail regarding #{@event.title}"
      assert m.body.include? "come to #{@event.room.name} please"
    end
  end
end

