# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scoring_engine/version'

Gem::Specification.new do |spec|
  spec.name          = "scoring_engine"
  spec.version       = ScoringEngine::VERSION
  spec.authors       = ["SPARSA"]
  spec.email         = ["engine@sparsa.org"]
  spec.summary       = %q{Cyber competition scoring engine}
  spec.description   = %q{A customizable scoring engine for cyber competitions.}
  spec.homepage      = "http://www.sparsa.org"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "net-ping"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end
