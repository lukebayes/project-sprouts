# -*- encoding: utf-8 -*-

require File.dirname(__FILE__) + '/<%= input.snake_case %>'
require 'rake'

Gem::Specification.new do |s|
  s.name                      = <%= input.camel_case %>::NAME
  s.version                   = <%= input.camel_case %>::VERSION
  s.author                    = "Your Name"
  s.email                     = ["projectsprouts@googlegroups.com"]
  s.homepage                  = "http://projectsprouts.org"
  s.summary                   = "A Library build with Project Sprouts"
  s.description               = "Longer description here"
  s.rubyforge_project         = "sprout"
  s.required_rubygems_version = ">= 1.3.6"
  s.require_path              = "."
  s.files                     = FileList["**/*"].exclude /docs|.DS_Store|generated|.svn|.git/
end

