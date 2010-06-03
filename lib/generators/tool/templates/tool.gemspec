# -*- encoding: utf-8 -*-
lib = File.expand_path File.dirname(__FILE__), 'lib'
$:.unshift lib unless $:.include?(lib)

require '<%= name.snake_case %>'

Gem::Specification.new do |s|
  s.name        = <%= name.camel_case %>::NAME
  s.version     = <%= name.camel_case %>::VERSION::STRING
  s.author      = "<%= author %>"
  s.email       = "<%= email %>"
  s.homepage    = "<%= homepage %>"
  s.summary     = "<%= summary %>"
  s.description = "<%= description %>"
  s.files       = "<%= name.snake_case %>.rb"
  s.add_bundler_dependencies
  s.require_paths << '.'
end

