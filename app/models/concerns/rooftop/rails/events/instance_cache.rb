module Rooftop
  module Rails
    module Events
      module InstanceCache
        def self.included(base)
          base.extend ClassMethods

          base.class_eval do
            class << self
              alias_method_chain :expire_cache_for, :parent
            end
          end

        end

        def parent_event_id_cache_key
          "#{self.class.parent_event_id_cache_key_base}/#{id}"
        end

        # Cache the parent ID into a key
        def cache_parent_id
          if self.respond_to?(:event_id)
            Rails.cache.write(parent_event_id_cache_key, self.event_id)
          end
        end

        module ClassMethods

          def parent_event_id_cache_key_base
            "#{cache_key_base}/parent_event"
          end

          def expire_cache_for_with_parent(*args)
            ids = args.collect {|a| a.respond_to?(:id) ? a.id : a}.flatten.collect(&:to_i)

            #Parent events IDs are stored in a series of keys, one for each instance id. We get all the event ID keys into an array
            parent_event_id_cache_keys = get_parent_id_cache_keys(ids)
            # then we get read_multi to get them all from the cache, and derive a unique set of event ids

            event_ids = get_event_ids_from_cache(parent_event_id_cache_keys)
            if event_ids.count != ids.count #we have some missing event IDs, so we need to do an expensive lookup
              Rooftop::Events::Event.all(
                include_embedded_resources: true,
                instances_per_page: -1,
                no_filter: [
                  :include_embedded_resources,
                  :instance_per_page
                ]
              )
            end

            # Now we've hopefully cached them all, do the cache lookup again

            get_event_ids_from_cache(parent_event_id_cache_keys).each do |event_id|
              Rooftop::Events::Event.expire_cache_for(event_id.to_i)
            end

            #then we do the normal cache expiry
            expire_cache_for_without_parent(*args)
          end

          private
          def get_parent_id_cache_keys(ids)
            ids.collect {|id| "#{parent_event_id_cache_key_base}/#{id}"}
          end

          def get_event_ids_from_cache(keys)
            Rails.cache.read_multi(*keys).collect {|key, event_id| event_id}.uniq
          end
        end

      end

    end
  end
end