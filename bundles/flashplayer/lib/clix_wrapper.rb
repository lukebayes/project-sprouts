#!/usr/bin/ruby
require 'rubygems'

player = ARGV[0]
swf = ARGV[1]

raise "CLIXWrapper requires 'player' argument like:\nruby clix_wrapper [player] [swf]" if(player.nil?)
raise "CLIXWrapper could not find player at '#{player}'" if !File.exists?(player)

raise "CLIXWrapper requires 'swf' argument like:\nruby clix_wrapper [player] [swf]" if(swf.nil?)
raise "CLIXWrapper could not find swf at '#{swf}'" if !File.exists?(swf)

begin
  require 'appscript'
  # Give the player focus:
  Appscript.app(player).activate
  # Open the SWF:
  Appscript.app(player).open(MacTypes::Alias.path(swf))
rescue LoadError => e
  raise "\n\n[ERROR] You must install the rb-appscript gem to use the desktop debug Flash Player, you do this by running:\n\nsudo gem install rb-appscript"
end

