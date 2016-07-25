module Rooftop
  module Rails
    module Events
      module Cache
        def self.included(base)
          base.extend ClassMethods
          if ::Rails.configuration.action_controller.perform_caching
            base.send(:alias_method_chain, :related_events, :caching)
          end

          base.class_eval do
            class << self
              alias_method_chain :expire_cache_for, :related
            end
          end

        end

        def related_cache_key
          "#{self.class.related_cache_key_base}/#{id}"
        end


        def related_events_with_caching(opts = {})
          Rails.cache.fetch(related_cache_key) do
            related_events_without_caching(opts)
          end
        end

        module ClassMethods
          def related_cache_key_base
            "#{cache_key_base}/related"
          end

          def expire_cache_for_with_related(*args)
            ::Rails.cache.delete_matched("#{related_cache_key_base}*")
            expire_cache_for_without_related(args)
          end
        end

      end
    end
  end
end