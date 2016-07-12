module Rooftop
  module Rails
    module Events
      module Reviews

        # Reviews. Requires ACF setup.

        def has_featured_review?
          has_field?(:featured_review) && fields.featured_review.present?
        end

        def has_reviews?
          has_field?(:reviews) && fields.reviews.present?
        end

        def featured_review
          has_featured_review? ? Rooftop::Content::Collection.new(fields.featured_review.first[:advanced].first[:fields]) : nil
        end

        def reviews
          if has_reviews?
            fields.reviews.collect do |review|
              Rooftop::Content::Collection.new(review[:advanced].first[:fields])
            end
          else
            return []
          end
        end

      end
    end
  end
end
