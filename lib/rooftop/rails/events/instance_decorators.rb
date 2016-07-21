require_rel "./decorators"
module Rooftop
  module Rails
    module Events
      module InstanceDecorators
        def self.included(base)
          raise StandardError, "Rooftop::Rails::Events::InstanceDecorators expects to be mixed into a Draper decorator" unless defined?(Draper) && base.ancestors.include?(Draper::Decorator)
          base.send(:include, Rooftop::Rails::Events::InstanceDecorator)
        end
      end
    end
  end
end