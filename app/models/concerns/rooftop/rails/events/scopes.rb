module Rooftop
  module Rails
    module Events
      module Scopes
        extend ActiveSupport::Concern

        included do

          scope :after_date, ->(date) {
            where(
              meta_key: :last_event_instance,
              meta_query: {
                key: :last_event_instance,
                value: date,
                compare: '>='
              },
              orderby: :meta_value_num,
              order: :asc
            )
          }

          scope :in_future, -> {
            after_date(Date.today)
          }

          scope :with_genre, ->(genre) {
            to_a.select {|e| e.meta_attributes[:genre] == genre}
          }

          scope :at_venue, ->(venue) {
            to_a.select {|e| e.meta_attributes[:venue] == venue}
          }

          scope :showing_between, ->(from,to) {
            to_a.select { |e|
              from.beginning_of_day <= DateTime.parse(e.event_instance_dates[:last]) && to.end_of_day >=  DateTime.parse(e.event_instance_dates[:first])
            }
          }

          scope :showing_on, ->(date) {
            showing_between(date,date)
          }

          scope :showing_from, ->(date) {
            to_a.select {|e| date.beginning_of_day >=  DateTime.parse(e.event_instance_dates[:first])}
          }

          scope :matching_query, ->(q) {
            search(q)
          }

          scope :group_bookable, -> {
            in_future.to_a.select {|e| e.show_on_group_bookings?}
          }

        end

      end
    end
  end
end