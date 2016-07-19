module Rooftop
  module Rails
    module Events
      # A mixin for your PagesController, to get events based on your page template. If the appropriate template is present in the response for a page from Rooftop, we generate an @events instance var with the events. @events is filtered according to some basic things like to and from date, if the params are present.
      module EventCollections
        extend ActiveSupport::Concern

        included do
          before_action :get_index_events, only: :show, if: -> {:template_matches}
        end

        class_methods do
          attr_reader :event_index_template, :event_filters, :filter_keys
          def event_index_template(template)
            @event_index_template = template.to_s
          end

          # A method to allow us to filter on extra things from the command line (e.g. genre)
          # To use in your controller:
          # self.add_event_filter :genre, ->(events) {
          #   return the matching set here
          # }

          def add_event_filter(key,filter)
            if filter.is_a?(Proc)
              @filter_keys ||= []
              @event_filters ||= []
              @filter_keys << key
              @event_filters << filter
            else
              raise ArgumentError, "add_event_filter takes a proc which is evaluated in the filter_events method, and a params key to check for"
            end
          end
        end

        private
        def template_matches
          self.class.event_index_template.present? && defined?(@page) && @page.template.present? && @page.template.underscore == self.class.event_index_template
        end

        def get_index_events
          @events = filter_events(Rooftop::Events::Event.in_future).sort_by {|e| e.event_instance_dates[:first]} rescue []
        end

        def has_filter_keys?
          fixed_filter_keys = ["from", "to", "q"]
          self.class.filter_keys ||= []
          all_filter_keys = fixed_filter_keys + self.class.filter_keys.collect(&:to_s)
          (params.keys & all_filter_keys).any? && all_filter_keys.collect {|k| params[k].present?}.any?
        end

        def filter_events(events)
          return events unless has_filter_keys?

          # Build a collection of collections, which we will intersect to get only ones which match all
          all_match = []


          if params[:from].present? && params[:to].present?
            from = DateTime.parse(params[:from]) rescue DateTime.now
            to = DateTime.parse(params[:to]) rescue DateTime.now
            all_match << events.showing_between(from,to)
          elsif params[:from].present?
            from = DateTime.parse(params[:from]) rescue DateTime.now
            all_match << events.showing_on(from)
          end

          # free-text search
          if params[:q].present?
            all_match << events.matching_query(params[:q])
          end

          # Iterate over any other filters supplied in procs
          if self.class.event_filters.present?
            self.class.event_filters.each do |filter|
              all_match << filter.call(events, params)
            end
          end

          # intersect all the alls
          all_match.inject(:&)

        end
      end
    end
  end

end