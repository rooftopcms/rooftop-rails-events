module Rooftop
  module Rails
    module Events
      class EventDetailDecorator
        attr_reader :grouped, :price_lists, :date_ranges, :month_ranges, :accessibility, :instances, :month_ranges_with_sorted_instances

        def initialize(event, instances)
          @instances = instances ? instances : Rooftop::Events::Instance.all(event_id: event.id,include_embedded_resources: true)

          price_list_ids = @instances.collect{|i| i.price_list_id.to_i}.sort.uniq
          @price_lists = Rooftop::Events::PriceList.where(post__in: price_list_ids,include_embedded_resources: true).to_a

          @date_ranges = grouped_by_performance_type!

          @accessibility = grouped_by_access_feature!

          @month_ranges = grouped_by_month!

          @month_ranges_with_sorted_instances = grouped_by_month_with_sorted_instances
        end

        # group events by their performance types.
        # type being, perview, evening, matinee, or other (special)
        def grouped_by_performance_type!
          performance_types = {'preview' => [], 'special_performance' => []}

          @instances.each do |instance|
            performance_type = instance.meta_attributes["time_of_day"]
            performance_types[performance_type] ||= []

            if instance.meta_attributes["preview"]=="true"
              performance_types["preview"].push(instance)
            end

            if instance.meta_attributes.has_key?("time_of_day")
              time_of_day = instance.meta_attributes["time_of_day"]
              performance_types[time_of_day] ||= []

              performance_types[time_of_day].push(instance)
            else
              performance_types['special_performance'].push(instance)
            end
          end

          performance_types.each do |type, instances|
            performance_types[type] = slice_instances_by_date(instances.reverse)
          end

          Hash[performance_types.reject{|k,v| k.nil? || k.empty? || v.empty?}.sort]
        end

        # Group the event instances by any known available accessibility facilities
        #
        def grouped_by_access_feature!
          groups = {'audio_described_performance' => [], 'captioned_performance' => [], 'signed_performance' => [], 'touch_tour' => [], 'relaxed_performance' => [], 'talk_back' => []}

          @instances.each do |instance|
            instance_types = instance.meta_attributes.select{|attr_key, attr_value| groups.keys.include?(attr_key) && attr_value=="true"}.keys

            if instance_types.any?
              instance_types.each do |type|
                groups[type].push(instance)
              end
            end
          end

          groups.each do |type, instances|
            groups[type] = slice_instances_by_date(instances.reverse)
          end

          groups
        end

        def grouped_by_month!
          sorted_instances = @instances.sort_by{|instance| DateTime.parse(instance.meta_attributes[:availability][:starts_at]).at_midnight}

          sorted_instances.group_by do |instance|
            DateTime.parse(instance.meta_attributes[:availability][:starts_at]).strftime('%B %Y')
          end
        end

        def grouped_by_month_with_sorted_instances
          sorted_instances = @instances.sort_by{|instance| DateTime.parse(instance.meta_attributes[:availability][:starts_at])}
          sorted_instances.group_by do |instance| DateTime.parse(instance.meta_attributes[:availability][:starts_at]).strftime('%B %Y') end
        end

        def today
          for_date(Date.today)
        end

        def tomorrow
          for_date(Date.tomorrow)
        end

        def for_date(date)
          @instances.sort_by{|instance| DateTime.parse(instance.meta_attributes[:availability][:starts_at])}.select {|instance| DateTime.parse(instance.meta_attributes[:availability][:starts_at]).to_date == date}
        end



        private

        # sort the given instances and return a grouped result-set, splitting on sets of event instances that have > 1 day between them.
        # for example, given an array of instances with the dates:
        #
        # [1st, 2nd, 3rd, 8th, 9th, 15th]
        #
        # we should return a grouped array:
        #
        # [[1st, 2nd, 3rd], [8th], [9th], [15th]]
        #
        # We can then iterate over these arrays and present the data (1st - 3rd, 8th, 9th and 15th)
        #
        def slice_instances_by_date(instances)
          instance_dates = instances.collect{|i| instance_date(i)}.sort.uniq
          instance_dates = instance_dates.slice_when{|prev, curr| prev != curr-1.day}.to_a

          group = {}

          instance_dates.each_with_index do |date_range, i|
            date_range.each do |date|
              group[i] ||= []
              group[i].push(instances.select{|i| instance_date(i)==date})
            end
          end

          group.inject({}) do |h,(k,v)|
            h[k] = v.flatten unless v.empty?
            h
          end.values.reject(&:empty?)
        end

        # return the event instance (ignores the time)
        #
        def instance_date(instance)
          Time.parse(instance.meta_attributes[:availability][:starts_at]).at_midnight
        end
      end

    end
  end
end
