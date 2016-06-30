module Rooftop
  module Rails
    module Events
      class PersonDecorator
        attr_reader :attributes, :object, :advanced_fields

        def initialize(relationship)
          @attributes = {}
          @object = relationship

          @object.each do |key, value|
            @attributes[key] = value
            self.class.send(:attr_accessor, "#{key}")
            instance_variable_set "@#{key}", value
          end

          if relationship.has_key?(:advanced) && relationship[:advanced].first && relationship[:advanced].first
            @advanced_fields = Rooftop::Content::Collection.new(relationship[:advanced].collect{|adv| adv[:fields].first})

            relationship[:advanced].collect{|adv| adv[:fields]}.flatten.each do |field|
              self.class.send(:attr_accessor, "#{field[:name]}_field")
              instance_variable_set("@#{field[:name]}_field", field[:value])
            end
          end
        end

        def role
          self.respond_to?(:role_field) ? self.role_field : ''
        end

        def character
          self.respond_to?(:character_played_field) ? self.character_played_field : ''
        end

        def image
          (self.respond_to?(:headshot_field) && self.headshot_field.is_a?(Hash)) ? self.headshot_field[:sizes][:medium] : ''
        end

        def content
          h.parse_content(self.fields.content).html_safe
        end
      end

    end
  end
end
