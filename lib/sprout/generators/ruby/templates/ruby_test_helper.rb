require "rubygems"
require "bundler"
Bundler.require :default, :development

# These require statments *must* be in this order:
# http://bit.ly/bCC0Ew
# Somewhat surprised they're not being required by Bundler...
require 'shoulda'
require 'mocha'

lib = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$:.unshift lib unless $:.include? lib

test = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$:.unshift test unless $:.include? test

require 'sprout'
require 'sprout/test_helper'

require '<%= input.snake_case %>'

