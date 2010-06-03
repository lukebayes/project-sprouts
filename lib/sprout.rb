require "rubygems"
require "bundler"

# Super-stinky bundler setup b/c bundler uses
# Dir.pwd to search for Gemfiles - BOO
ENV['BUNDLE_GEMFILE'] = File.expand_path(File.join(File.dirname(__FILE__), '..', 'Gemfile'))
Bundler.setup :default

lib = File.expand_path File.dirname(__FILE__)
$:.unshift lib unless $:.include?(lib)

require 'sprout/base'

module Sprout
  include Base
end

