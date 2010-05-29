# -*- encoding: utf-8 -*-
lib = File.expand_path(File.join(File.dirname(__FILE__), 'lib'))
$:.unshift lib unless $:.include?(lib)

require 'sprout'

Gem::Specification.new do |s|
  s.name                      = "sprout"
  s.version                   = Sprout::VERSION::STRING
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = ["Luke Bayes"]
  s.email                     = ["lbayes@patternpark.com"]
  s.homepage                  = "http://projectsprouts.org"
  s.summary                   = "Software development - evolved"
  s.description               = "Project Sprouts gives you access to simple generators with custom templates, beautiful build scripts, distributed libraries and automated system configuration"
  s.post_install_message      = File.read 'POSTINSTALL.rdoc'
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "sprout" 

  ##
  # Add the dependencies defined in the Gemfile
  # to the packaged RubyGem.
  Sprout.add_gemfile_dependencies s

  s.files = Dir.glob("{app_generators,bin,lib,test}/**/*") + %w(MIT-LICENSE README.textile CHANGELOG.md)

  # TODO: Bring this back:
  #s.executables  = ['sprout']
  s.require_path = ['lib']
end

