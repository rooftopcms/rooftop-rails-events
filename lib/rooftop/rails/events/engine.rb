module Rooftop
  module Rails
    module Events
      class Engine < ::Rails::Engine

        isolate_namespace Rooftop::Rails::Events

        config.before_initialize do

        end

        initializer "add_helpers" do
          ActiveSupport.on_load(:action_view) do
            # include Rooftop::Rails::Events::YourHelper

          end
        end

        config.to_prepare do
          ::Rails.application.eager_load!
          Rooftop::Events::Event.send(:include, Rooftop::Rails::Events::Cache)
          Rooftop::Events::Event.send(:include, Rooftop::Rails::Events::Scopes)
          Rooftop::Events::Instance.send(:include, Rooftop::Rails::Events::InstanceCache)
          Rooftop::Events::Instance.send(:include, Rooftop::Rails::Events::BookingInformation)
        end

      end
    end

  end
end
