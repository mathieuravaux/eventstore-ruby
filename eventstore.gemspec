# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'eventstore'
  spec.version       = '0.0.5'
  spec.authors       = ['Mathieu Ravaux']
  spec.email         = ['mathieu.ravaux@gmail.com']
  spec.summary       = 'Ruby client API for the Event Store.'
  spec.description   = 'Eventstore is an open-source, functional database with Complex Event Processing in JavaScript.'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^spec\//)
  spec.require_paths = ['lib']

  spec.add_dependency 'beefcake', '~> 1.1.0.pre1'
  spec.add_dependency 'promise.rb', '~> 0.6.1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'pry'
end
