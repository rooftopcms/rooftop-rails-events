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
          has_featured_review? ? Rooftop::Content::Field.new(fields.featured_review.first) : nil
        end

        def reviews
          has_reviews? ? Rooftop::Content::Collection.new(fields.reviews) : []
        end

      end
    end
  end
end
