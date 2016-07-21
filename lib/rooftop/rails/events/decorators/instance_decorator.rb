module Rooftop
  module Rails
    module Events
      module InstanceDecorator

        def start_date_object
          DateTime.parse(object.meta_attributes[:availability][:starts_at])
        end

        def start_date
          start_date_object.strftime("%a %-d %-b")
        end

        def start_time
          start_date_object.strftime("%l:%M%P")
        end


        def price(event_details)
          price_list = event_details.price_lists.find{|pl| pl.id == object.price_list_id.to_i}

          if price_list
            price_list_range(price_list)
          else
            ""
          end
        end

        def limited_availability?
          available = event_instance_meta[:availability][:seats_available].to_i
          capacity  = event_instance_meta[:availability][:seats_capacity].to_i

          available <= capacity/10
        end

        def in_future?
          DateTime.parse(object.event_instance_meta[:availability][:starts_at]).future?
        end

        def in_past?
          !in_future?
        end

        def bookable?
          return false if in_past?

          available = event_instance_meta[:availability][:seats_available].to_i
          available > 0
        end

        def is_public_dress_rehearsal?
          event_instance_meta.has_key?(:public_dress_rehearsal) && event_instance_meta[:public_dress_rehearsal]=="true"
        end

        def price_list_range(price_list)
          prices = price_list.prices.collect{|p| p.event_price_meta[:ticket_price].to_f}.flatten.sort
          [prices[0], prices[-1]].uniq.sort
        end
      end

    end
  end
end