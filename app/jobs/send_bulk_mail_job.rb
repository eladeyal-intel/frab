class SendBulkMailJob
  include SuckerPunch::Job

  def perform(template, send_filter)
    event_people = EventPerson
      .joins(event: :conference)
      .where('conferences.id': template.conference.id)

    case send_filter
    when 'all_speakers_in_confirmed_events'
      event_people = event_people
        .where('events.state': 'confirmed')
        .where('event_people.event_role': EventPerson::STAKEHOLDERS)

    when 'all_speakers_in_unconfirmed_events'
      event_people = event_people
        .where('events.state': 'unconfirmed')
        .where('event_people.event_role': EventPerson::STAKEHOLDERS)

    when 'all_speakers_in_scheduled_events'
      event_people = event_people
        .where('events.state': 'scheduled')
        .where('event_people.event_role': EventPerson::STAKEHOLDERS)
    end

    event_people.pluck(:person_id).uniq.each do |p_id|
      UserMailer.bulk_mail_multiple_roles(event_people.where(person_id: p_id), template).deliver_now
      p=Person.find(p_id)
      Rails.logger.info "Mail template #{template.name} delivered to #{p.first_name} #{p.last_name} (#{p.email})"

    end
  end
end
