module EventsHelper
  def fix_http_proto(url)
    if url.start_with?('https') or url.start_with?('http') or url.start_with?('ftp')
      url
    else
      "http://#{url}"
    end
  end

  def showing_my_events
     params[:events]=='my'
  end

  def event_start_time
    return t(:date_not_set) unless @event.start_time
    I18n.l(@event.start_time, format: :pretty_datetime)
  end

  def timeslots
    slots = []
    (@conference.max_timeslots + 1).times do |i|
      slots << [format_time_slots(i), i]
    end
    slots
  end

  def format_time_slots(number_of_time_slots)
    duration_in_minutes = number_of_time_slots * @conference.timeslot_duration
    duration_to_time(duration_in_minutes)
  end
  
  def supported_filters
    supported_exact_filters + supported_numeric_filters
  end
  
  def supported_exact_filters
    #      attribute/sql name       query parameter        huuman_name                                             scope_for_values
    [ [    :track_name,             'track_name',          t('activerecord.attributes.event.track'),               nil                  ],
      [    :event_type,             'event_type',          t('activerecord.attributes.event.event_type'),          'options' ] ,
      [    :event_state,            'event_state',         t('activerecord.attributes.event.state'),               'conferences_module' ] ]
  end                                                  
                                                       
  def supported_numeric_filters                        
    #      attribute/sql name       query parameter        human_name                                              scope_for_values
    [  [   :average_rating,         'average_rating',      t('activerecord.attributes.event.average_rating'),      nil                  ],
       [   :event_ratings_count,    'event_ratings_count', t('activerecord.attributes.event.event_ratings_count'), nil                  ] ] +
    @conference.review_metrics.map{ |rm| 
       [   "#{rm.safe_name}.score", rm.safe_name,          rm.name,                                                nil                  ] }
  end
  
  def show_filters_pane
    supported_filters.each do |attrname, qname, human_name, scope|
      return true if params[qname].present?
    end
    false
  end
  
  def get_op_and_val(str)
    /^(?<op>[≤≥=]?)(?<val>.*)$/ =~ str
    return op, val
  end
end
