require 'sprout'
sprout 'sprout-as3-bundle'

# To run the sample:
# 1) Open a terminal
# 2) cd into the directory that contains this file
# 3) run 'rake'
# 4) the flash player should block the shell input and launch in your os
# 5) Close the flash player and you should return to the shell

# Make the default (no-name)
# rake task compile using mxmlc
task :default => :run

desc "Launch a swf with the Flash Player"
flashplayer :run => 'bin/SomeProject.swf'


desc "Launch a swf, run AsUnit test cases, write results to a file and close the Flash Player when complete"
flashplayer :test => 'bin/SomeProjectRunner.swf'
