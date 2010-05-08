require "rubygems"
require "bundler"

Bundler.setup(:default)
$:.push File.dirname(__FILE__)

require 'sprout/base'

module Sprout
  include Base
end

