require_rel 'decorators'
module Rooftop
  module Rails
    module Events
      module Decorators

        def self.included(base)
          raise StandardError, "Rooftop::Rails::Events::Decorators expects to be mixed into a Draper decorator" unless defined?(Draper) && base.ancestors.include?(Draper::Decorator)
          base.send(:include, Rooftop::Rails::Events::Content)
          base.send(:include, Rooftop::Rails::Events::Cast)
          base.send(:include, Rooftop::Rails::Events::Media)
          base.send(:include, Rooftop::Rails::Events::Reviews)
        end
      end
    end
  end
end
