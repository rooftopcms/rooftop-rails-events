module Rooftop
  module Rails
    module Events
      module EventHandler
        # A module for showing an event and listing event instances. Note that we don't have an index endpoint in here - for that we use a template in the pages controller, and a mixin to get a collection of events if you're hitting that template. See Rooftop::Rails::Events::EventCollections for that.
        extend ActiveSupport::Concern

        def show
          @event = Rooftop::Events::Event.where(
            slug: params[:id],
            per_page: 1,
            include_embedded_resources: true,
            instances_per_page: -1,
            no_filter: [
              :include_embedded_resources,
              :instances_per_page
            ]).first
          if @event.nil?
            raise Rooftop::RecordNotFoundError, "No event with slug #{params[:id]} found"
          end

          @instances = @event.embedded_instances

          yield if block_given?
        end

        def instances
          @event = Rooftop::Events::Event.where(slug: params[:event_id]).first

          @instances = Rooftop::Events::Instance.all(_event_id: @event.id, include_embedded_resources: true).sort_by {|i| DateTime.parse(i.meta_attributes[:availability][:starts_at])}.to_a.reject! {|e| DateTime.parse(e.meta_attributes[:availability][:starts_at]) < DateTime.now}

          @event_details = EventDetailDecorator.new(@event, @instances)

          yield if block_given?
        end

        def book_instance
          @event = Rooftop::Events::Event.where(slug: params[:event_id]).first
          @instance_id = params[:instance_id]

          yield if block_given?
        end


      end
    end

  end
end