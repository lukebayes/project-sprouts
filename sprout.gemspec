# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'sprout/version'

Gem::Specification.new do |s|
  s.name        = "sprout"
  s.version     = Sprout::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Luke Bayes"]
  s.email       = ["lbayes@patternpark.com"]
  s.homepage    = "http://github.com/lukebayes/project-sprouts"
  s.summary     = "Flash development evolved"
  s.description = "Project Sprouts gives you access to simple generators with custom templates, beautiful build scripts, distributed libraries and automated system configuration"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "sprout" 

  s.add_development_dependency "shoulda"

  s.files        = Dir.glob("{bin,lib}/**/*") + %w(MIT-LICENSE README.md CHANGELOG.md)
  s.executables  = ['sprout']
  s.require_path = 'lib'
end

