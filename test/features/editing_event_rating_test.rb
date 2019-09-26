require 'test_helper'

class EditingEventRatingTest < FeatureTest
  setup do
    @conference = create(:three_day_conference_with_events)
    @event = @conference.events.last

    @coordinator = create(:conference_coordinator, conference: @conference)
    @user = @coordinator.user

  end

  it 'can create event rating and delete it', js: true do
    sign_in_user(@user)
    visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"
    assert_content page, 'My rating'

    find('div#my_rating').find(:xpath, '//img[@title="good"]').click()
    find('textarea').set('Quite good event')
    click_on 'Create Event rating'

    assert_content page, 'My rating'
    assert_content page, 'Quite good event'
    click_on 'Delete Event rating'

    assert_content page, 'My rating'
    refute_content page, 'Quite good event'
  end
  
  it 'can edit review metrics and calculate average', js:true do
     review_metric = ReviewMetric.create(name: "innovative")
     @conference.review_metrics << review_metric
     scores=['2','4','5']
     reviews=scores.map{ |score| [create(:conference_coordinator, conference: @conference).user, score] }.to_h
     reviews.each do |reviewer, score|
       sign_in_user(reviewer)
       visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"
       save_and_open_page
       find('input', text: score, exact: true).click()
     end
     
     sign_in_user(@user)
     visit "/#{@conference.acronym}/events/ratings"
     assert_content page, 'innovative' 
     assert_content page, '3.6' # average([2,4,5])
     
     sign_in_user(reviews.key('4'))
     visit "/#{@conference.acronym}/events/#{@event.id}/event_rating"
     click_on 'Delete Event rating'

     sign_in_user(@user)
     visit "/#{@conference.acronym}/events/ratings"
     assert_content page, 'innovative' 
     assert_content page, '3.5' # average([2,5])
     
     review_metric.destroy
  end
end
