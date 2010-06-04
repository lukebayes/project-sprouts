lib = File.expand_path File.dirname(__FILE__)
$:.unshift lib unless $:.include?(lib)

require 'sprout/base'

module Sprout
  include Base
end

