require "rubygems"
require "bundler"

Bundler.setup :default, :development

require 'sprout'

# These require statments *must* be in this order:
# http://bit.ly/bCC0Ew
# Somewhat surprised they're not being required by Bundler...
require 'shoulda'
require 'mocha'

lib = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$:.unshift lib unless $:.include? lib

require 'sprout'

test = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$:.unshift test unless $:.include? test

require 'sprout/test_helper'

