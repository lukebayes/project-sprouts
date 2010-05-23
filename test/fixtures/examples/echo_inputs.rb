#! /usr/bin/env ruby

require 'rubygems'
require 'sprout'

class CustomParameter < Sprout::Executable::Param; end

class EchoInputs
  include Sprout::Executable
  
  ##
  # A boolean parameter that will be set to true if present.
  #
  #   echo-inputs --truthy
  #
  add_param :truthy, Boolean
  ##
  # A boolean parameter that defaults to true, and must be 
  # explicitly set to false in order to turn it off.
  #
  #  echo-inputs --falsey=false
  #  
  add_param :falsey, Boolean, { :default => true, :hidden_value => false, :show_on_false => true }

  ##
  # A file that exists at the time it is provided.
  #
  #  echo-inputs --file=lib/sprout.rb
  #
  add_param :file, File

  ##
  # A collection of files, this parameter can be repeated
  # any number of times.
  #
  #   echo-inputs --files+=rakefile.rb --files+=README.textil
  #
  add_param :files, Files

  ##
  # A numeric value.
  #
  #   echo-inputs --number=23
  #
  add_param :number, Number

  ##
  # A relative or fully-qualified path to a directory.
  # 
  #   echo-inputs --path=lib/
  #
  add_param :path, Path

  ##
  # Relative or fully-qualified paths to directories.
  #
  #   echo-inputs --paths+=lib/ --paths+=test/
  #
  add_param :paths, Paths

  ##
  # A simple string value.
  #
  #   echo-inputs --string='Some String'
  #
  add_param :string, String

  ##
  # A collection of simple string values.
  #
  #   echo-inputs --strings+='First' --strings+='Second'
  #
  add_param :strings, Strings

  ##
  # A short version of another parameter.
  #
  #   echo-inputs -sp+='First' --sp+='Second'
  #
  add_param_alias :sp, :strings


  ##
  # A collection of url values.
  #
  #   echo-inputs --urls+='http://google.com' --urls+='http://yahoo.com'
  #
  add_param :urls, Urls

  ##
  # A custom parameter type that is provided by this tool.
  #
  #   echo-inputs --custom='Some Value'
  #
  add_param :custom,  CustomParameter

  ##
  # A required value with a hidden name. This kind of value is often
  # presented as the default option.
  # 
  #   echo-inputs lib/sprout.rb
  #
  add_param :input, File, { :required => true, :hidden_name => true }

  def execute
    puts "--truthy=#{truthy}" if truthy
    puts "--falsey=#{falsey}" unless falsey
    puts "--file=#{file}" unless file.nil?
    puts "--files=#{files.inspect}" unless files.empty?
    puts "--number=#{number}" unless number.nil?
    puts "--path=#{path}" unless path.nil?
    puts "--paths=#{paths.inspect}" unless paths.empty?
    puts "--string=#{string}" unless string.nil?
    puts "--strings=#{strings.inspect}" unless strings.empty?
    puts "--sp=#{sp.inspect}" unless sp.empty?
    puts "--urls=#{urls.inspect}" unless urls.empty?
    puts "--custom=#{custom}" unless custom.nil?
    puts " [input]: #{input}"
  end
end

if($0 == __FILE__)
  exe = EchoInputs.new
  exe.parse ARGV
  exe.execute
end

