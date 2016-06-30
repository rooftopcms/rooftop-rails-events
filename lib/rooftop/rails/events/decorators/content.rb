module Rooftop
  module Rails
    module Events
      module Content

        def title
          object.title.html_safe
        end

        def content
          h.parse_content object.fields.content
        end

        def excerpt
          h.parse_content object.fields.excerpt
        end

      end
    end
  end
end