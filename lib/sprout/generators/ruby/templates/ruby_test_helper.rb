require "rubygems"
require "bundler"
Bundler.require :default, :development

lib = File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift lib unless $:.include? lib

require '<%= input.snake_case %>'
require 'sprout/test/sprout_test_case'

