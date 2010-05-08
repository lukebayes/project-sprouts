begin
  require 'bundler'
rescue LoadError => e
  puts File.read('rubygems/rubygems_message')
  raise e
end

Bundler.setup(:default)
$:.push File.dirname(__FILE__)

require 'sprout/base'

module Sprout
  include Base
end

