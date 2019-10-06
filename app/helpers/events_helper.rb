module EventsHelper
  def fix_http_proto(url)
    if url.start_with?('https') or url.start_with?('http') or url.start_with?('ftp')
      url
    else
      "http://#{url}"
    end
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

  FilterData = Struct.new(:attribute_name, :qname, :filter_name_i18n, :filter_name, :i18n_scope)

  def text_filters_data
    [ FilterData[:track_name,
                 'track_name',
                 'activerecord.attributes.event.track'],
      FilterData[:event_type,
                 'event_type',
                 'activerecord.attributes.event.event_type',
                 nil,
                 'options'],
      FilterData[:event_state,
                 'event_state',
                 'activerecord.attributes.event.state',
                 nil,
                 'conferences_module'] ].freeze
  end

  def numeric_filters_data
    [  FilterData[:average_rating,
                  'average_rating',
                  'activerecord.attributes.event.average_rating'],
       FilterData[:event_ratings_count,
                  'event_ratings_count',
                  'activerecord.attributes.event.event_ratings_count'] ] +
    @conference.review_metrics.map{ |rm| FilterData["#{rm.safe_name}.score",
                                                    rm.safe_name,
                                                    nil,
                                                    rm.name] }
  end

  def filters_data
    text_filters_data + numeric_filters_data
  end

  def show_filters_pane
    filters_data.each do |f|
      return true if params[f.qname].present?
    end
    false
  end

  def get_op_and_val(str)
    /^(?<op>[≤≥=]?)(?<val>.*)$/ =~ str
    return op, val
  end
end
