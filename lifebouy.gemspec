# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lifebouy/version'

Gem::Specification.new do |spec|
  spec.name          = "lifebouy"
  spec.version       = Lifebouy::VERSION
  spec.authors       = ["Reed Swenson"]
  spec.email         = ["reed@swensonlogics.com"]
  spec.summary       = %q{A Rails generator that builds SOAP services based off a given WSDL.}
  spec.description   = %q{
Making SOAP services for a provided WSDL in Rails can be tedious.  Lifebouy
takes the tedium out of the implementation.
}
  spec.homepage      = "https://github.com/reedswenson/lifebouy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 4.0.0"
  spec.add_dependency "nokogiri", "~> 1.6.0"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "generator_spec"
  spec.add_development_dependency "rails", ">= 4.0.0"
end
