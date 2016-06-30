module Rooftop
  module Rails
    module Events
      module BookingInformation
        extend ActiveSupport::Concern

        def date_from
          if event_instance_dates[:first].present?
            DateTime.parse(event_instance_dates[:first])
          end
        end

        def date_to
          if event_instance_dates[:last].present?
            DateTime.parse(event_instance_dates[:last])
          end
        end

      end
    end
  end
end