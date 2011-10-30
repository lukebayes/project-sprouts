# -*- encoding: utf-8 -*-
lib = File.expand_path File.dirname(__FILE__), 'lib'
$:.unshift lib unless $:.include?(lib)

require 'bundler'
require 'rake'
require '<%= input.snake_case %>'

Gem::Specification.new do |s|
  s.name              = <%= input.camel_case %>::NAME
  s.version           = <%= input.camel_case %>::VERSION::STRING
  s.author            = "<%= author %>"
  s.email             = "<%= email %>"
  s.homepage          = "<%= homepage %>"
  s.summary           = "<%= summary %>"
  s.description       = "<%= description %>"
  s.rubyforge_project = "sprout"
  s.files             = FileList['**/**/*'].exclude /.git|.svn|.DS_Store/
  s.add_bundler_dependencies
  s.require_paths << '.'
end

