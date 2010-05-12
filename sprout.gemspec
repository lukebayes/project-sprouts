# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'bundler'
require 'sprout/version'

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

  s.add_dependency "bundler", ">= 0.9.19"

  bundle = Bundler::Definition.from_gemfile('Gemfile')

  bundle.dependencies.each do |dep|
    if dep.groups.include?(:default)
      puts ">> Bundler.add_dependency: #{dep.name}"
      s.add_dependency(dep.name, dep.requirement.to_s)
    elsif dep.groups.include?(:development)
      puts ">> Bundler.add_development_dependency: #{dep.name}"
      s.add_development_dependency(dep.name, dep.requirement.to_s)
    end
  end

  s.files = Dir.glob("{app_generators,bin,lib,test}/**/*") + %w(MIT-LICENSE README.textile CHANGELOG.md)

  # TODO: Bring this back:
  #s.executables  = ['sprout']
  s.executables  = ['sprout-tool']
  s.require_path = ['lib', 'test']
end

