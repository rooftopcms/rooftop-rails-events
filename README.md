# Rooftop::Rails::Events

A library to make it super-easy to integrate events from [Rooftop CMS](https://www.rooftopcms.com) into your Rails site.

## What's included
A bit of a mix of stuff, and all work in progress. Here's a flavour:

## Controller Mixins
You need to `include` these yourself.

### Rooftop::Rails::Events::EventHandler
A mixin for a controller which handles events. It has methods for show() and instances() which get the event from Rooftop for you.

## Model Mixins
These are `include`d automatically when you use this gem.


### Rooftop::Rails::Events::Cache
A mixin added to the Rooftop::Events::Event to cache / expire it.

### Rooftop::Rails::Events::InstanceCache
The same as `Rooftop::Rails::Events::Cache` but for instances. Allows you to receive a webhook for just an instance and be able to clear the cache for its associated `Event`.

### Rooftop::Rails::Events::Scopes
Handy scopes for dealing with events - finding after a date, between dates, in the future etc.

## Object Decorators
We use a lot of [Draper](https://github.com/drapergem/draper) as our decorator pattern at [Error Agency](https://error.agency). So there are some mixins you add to your EventDecorator to provide utility methods for use in views.

```
#in your project
class EventDecorator < Draper::Decorator
    include Rooftop::Rails::Events::Decorators
end
```

## Controller mixin for Event collections
The standard pattern we've found works well for Rooftop is to have a PagesController with mixins which check the template of the page you're rendering, and makes requests to get collections of objects you'll need.

```
class PagesController < ApplicationController
    include Rooftop::Rails::Events::EventCollections 
end
```
You get a bunch of stuff for free with this:

* Rooftop events in the future will be returned as a collection called @events by default
* if you pass in query params, you can filter these:
  *  `q` will do a free-text search
  *  `from` will take an dd-mm-yyyy date string and return things happening on or after that date
  *  `to` will work likewise, in reverse
 
### Customising querystring filters
You might want to filter by something else. That's relatively easy.

```
class PagesController < ApplicationController
    include Rooftop::Rails::Events::EventCollections
    self.add_event_filter :genre, ->(events,params) {
        # add something here which returns a collection when genre is passed in, for example
        # very important - you must return something here
        if params[:genre].present?
            events.with_genre(params[:genre])
        else
            events
        end
    }
end
```



## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rooftop-rails-events'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rooftop-rails-events

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rooftop-rails-events. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

