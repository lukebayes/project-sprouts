#!/usr/bin/ruby
require 'rubygems'
require 'appscript'

player = ARGV[0]
swf = ARGV[1]

if(player.nil?)
  raise "CLIXWrapper requires 'player' argument like:\nruby clix_wrapper [player] [swf]"
end

if(swf.nil?)
  raise "CLIXWrapper requires 'swf' argument like:\nruby clix_wrapper [player] [swf]"
end

begin
  # Give the player focus:
  Appscript.app(player).activate
  # Open the SWF:
  Appscript.app(player).open(MacTypes::Alias.path(swf))
rescue LoadError => e
  raise 'You must install the rb-appscript gem to use the desktop debug Flash Player'
end

