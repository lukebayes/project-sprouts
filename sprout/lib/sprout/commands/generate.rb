=begin
require 'rubygems'
gem 'activesupport', '>= 2.0.2'
require 'generator'
require 'sprout'

ARGV.shift if ['--help', '-h'].include?(ARGV[0])
RubiGen::Scripts::Generate.new.run(ARGV)
=end
