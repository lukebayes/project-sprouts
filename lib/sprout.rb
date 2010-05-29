require "rubygems"
require "bundler"

Bundler.setup(:default)

# This shouldn't need done here - bundler/rubygems
# should handle getting lib into the load path...
#
#$:.unshift File.dirname(__FILE__)
require 'sprout/base'

module Sprout
  include Base
end

