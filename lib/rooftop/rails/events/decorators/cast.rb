module Rooftop
  module Rails
    module Events
      module Cast

        def cast_members
          if object.has_field?(:cast, Array)
            object.fields.cast.collect{|cm| PersonDecorator.new(cm)}
          else
            []
          end
        end

        def creatives
          if object.has_field?(:creatives, Array)
            object.fields.creatives.collect{|cm| PersonDecorator.new(cm)}
          else
            []
          end
        end

      end
    end
  end
end
