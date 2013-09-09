# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/backbone/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-backbone"
  spec.version       = Rack::Backbone::VERSION
  spec.authors       = ["Iain Barnett"]
  spec.email         = ["iainspeed@gmail.com"]
  spec.description   = %Q{Backbone.js CDN script tags and fallback in one neat package. Current version is for Backbone v#{Rack::Backbone::BACKBONE_VERSION}}
  spec.summary       = %q{The description says it all.}
  spec.homepage      = "https://github.com/yb66/rack-backbone"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/).reject{|x| x.start_with?("vendor") && !x.include?(Rack::Backbone::BACKBONE_VERSION) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.2"
  spec.add_development_dependency "rake"
  spec.add_dependency("rack")
  spec.add_dependency("rack-jquery-helpers")
end
