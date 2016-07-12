module Rooftop
  module Rails
    module Events
      module Media

        # Images. Requires ACF setup.

        def has_hero_image?
          has_field?(:hero_image) && fields.hero_image.present?
        end

        def has_poster_image?
          has_field(:poster_image) && fields.poster_image.present?
        end

        def has_list_image?
          has_field?(:event_list_image) && fields.event_list_image.present?
        end

        def hero_image
          has_hero_image? ? fields.hero_image[:sizes][:large] : nil
        end

        def header_image
          if has_hero_image?
            hero_image
          else
            'https://placeholdit.imgix.net/~text?txtsize=33&txt=350×150&w=1200&h=670'
          end
        end

        def list_image
          if has_list_image?
            fields.event_list_image[:sizes][:medium]
          elsif has_hero_image?
            hero_image
          end
        end

        def poster_image
          if has_poster_image?
            fields.poster_image[:sizes][:medium]
          end
        end

        # Media. Requires ACF.

        def media
          if object.has_field?(:media, Array) && object.fields.media.any?
            object.fields.media.collect do |media_item|
              collection = Rooftop::Content::Collection.new(media_item.collect(&:to_h))

              next unless collection.video_or_image.present?

              if collection.video_or_image == "video" && collection.youtube_url.present?
                collection << Rooftop::Content::Field.new({name: "youtube_id", value: collection.youtube_url.match(/(youtu.be\/(\S+)$|v=(\S+))/).to_a.compact.last})
              end
              collection
            end
          else
            []
          end
        end

        def media_collection
          media.collect do |item|
            if item.video_or_image == 'image'
              next unless item.image.is_a?(Hash)
              {
                title: item.caption.html_safe,
                thumbnail: item.image[:sizes][:medium],
                href: item.image[:sizes][:large],
                media_type: item.video_or_image,
              }
            elsif item.video_or_image == "video"
              {
                title: item.caption.html_safe,
                href: item.youtube_url,
                type: 'text/html',
                youtube: item.youtube_id,
                thumbnail: '//img.youtube.com/vi/' + item.youtube_id + '/0.jpg',
                poster: '//img.youtube.com/vi/' + item.youtube_id + '/0.jpg',
                media_type: item.video_or_image,
              }
            end
          end
        end

        def media_json
          media_collection.compact.to_json.html_safe
        end

        def has_trailer?
          has_field?(:trailer) && fields.trailer.present?
        end

        def trailer
          if has_trailer?
            "https://www.youtube.com/embed/" + fields.trailer.partition('=').last + "?rel=0&amp;showinfo=0"
          end
        end

        def media_images
          media.select {|m| m.video_or_image == 'image'}
        end

        def media_videos
          media.select {|m| m.video_or_image == 'video'}
        end
      end

    end
  end
end