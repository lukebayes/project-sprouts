require 'rubygems'
require 'bundler'
Bundler.require

library :corelib

# Configure the default environment:
env :default do
  set :input, 'src/SomeProject.as'
  set :output, 'bin/SomeProject.swf'
  set :libraries, [:corelib]
end

# Configure the deployed environment:
env :deploy => :default do
  set :debug, false
end

# Configure the demo environment:
env :demo => :deploy do
  set :debug, true
end

# Configure the test environment:
env :test => :deploy do
  set :input , 'src/SomeProjectRunner.as'
  set :output, 'bin/SomeProjectRunner.swf'

  library :asunit4
  set :libraries, [:corelib, :asunit4]
end

# Configure the Continuous Integration environment:
evn :ci => :test do
  set :input, 'src/SomeProjectXMLRunner.as'
  set :output, 'bin/SomeProjectXMLRunner.swf'
end


desc 'Build the application'
mxmlc get(:output) => get(:libraries) do |t|
  t.input = get(:input)
  t.debug = get(:debug)
end

desc 'Compile and run the application'
flashplayer :run => get(:output)

desc 'Compile and debug the application'
fdb :debug => get(:output) do |t|
  t.kill_on_fault = true
end

task :default => :run

