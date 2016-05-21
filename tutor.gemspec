# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tutor/version'

Gem::Specification.new do |spec|
  spec.name          = "tutor"
  spec.version       = Tutor::VERSION
  spec.authors       = ["David Elner"]
  spec.email         = ["david@davidelner.com"]

  spec.summary       = %q{Supplemental teachings for your Ruby classes.}
  spec.description   = %q{Supplemental teachings for your Ruby classes. Adds common patterns and idioms to decorate your classes with.}
  spec.homepage      = "http://github.com/delner/tutor"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-collection_matchers", "~> 1.0"
  spec.add_development_dependency "pry"
end
