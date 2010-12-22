# -*- encoding: utf-8 -*-
lib = File.expand_path File.join(File.dirname(__FILE__), 'lib')
$:.unshift lib unless $:.include?(lib)

require 'bundler'
require 'rake'

Gem::Specification.new do |s|
  s.name                      = 'sprout'
  s.version                   = File.read('VERSION').strip
  s.platform                  = Gem::Platform::RUBY
  s.authors                   = ["Luke Bayes"]
  s.email                     = "projectsprouts@googlegroups.com"
  s.homepage                  = "http://projectsprouts.org"
  s.summary                   = "Software development - evolved"
  s.description               = "Project Sprouts gives you access to beautiful generators and easily customized templates, automated build scripts, distributed libraries and simple system configuration"
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "sprout" 
  s.require_path              = ['lib']
  s.files                     = FileList['**/**/*'].exclude /.git|.svn|.DS_Store/
  s.executables               = ['sprout', 'sprout-generator', 'sprout-class', 'sprout-test', 'sprout-suite', 'sprout-ruby']
  s.add_bundler_dependencies
end

