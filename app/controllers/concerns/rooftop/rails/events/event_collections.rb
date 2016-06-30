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
          attr_reader :event_index_template
          def event_index_template(template)
            @event_index_template = template.to_s
          end
        end

        private
        def template_matches
          self.class.event_index_template.present? && defined?(@page) && @page.template.present? && @page.template.underscore == self.class.event_index_template
        end

        def get_index_events
          @events = filter_events(Rooftop::Events::Event.in_future).sort_by {|e| e.event_instance_dates[:first]}
        end

        def has_filter_keys?
          filter_keys = ["from", "to", "venue", "genre", "q"]
          (params.keys & filter_keys).any? && filter_keys.collect {|k| params[k].present?}.any?
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

          if params[:venue].present?
            all_match << events.matching_summary_venue(params[:venue])
          end

          if params[:genre].present?
            all_match << events.with_genre(params[:genre])
          end

          # free-text search
          if params[:q].present?
            all_match << events.matching_query(params[:q])
          end

          # intersect all the alls
          all_match.inject(:&)

        end
      end
    end
  end

end