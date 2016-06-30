# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rooftop/rails/events/version'

Gem::Specification.new do |spec|
  spec.name          = "rooftop-rails-events"
  spec.version       = Rooftop::Rails::Events::VERSION
  spec.authors       = ["Ed Jones"]
  spec.email         = ["ed@errorstudio.co.uk"]

  spec.summary       = %q{Quickly add events to your Rails website with Rooftop CMS.}
  spec.description   = %q{This library integrates with Rooftop CMS's events plugin to make it easy to add events to your site.}
  spec.homepage      = "https://github.com/rooftopcms/rooftop-rails-events"
  spec.license       = "GPLv3"

    spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "require_all"
  spec.add_dependency "rooftop-rails"

end
