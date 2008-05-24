# Shamelessly copied from Ruby On Rails
# Which happens to share the same MIT license!

=begin
#require "#{RAILS_ROOT}/config/environment"
require 'rubygems'
gem 'activesupport', '>= 2.0.2'
require 'generator'
#require 'generator/scripts/generate'
require 'sprout'

ARGV.shift if ['--help', '-h'].include?(ARGV[0])
Rails::Generator::Scripts::Generate.new.run(ARGV)
=end
