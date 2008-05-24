require 'sprout'

# To run the sample:
# 1) Open a terminal
# 2) cd into the directory that contains this file
# 3) run 'rake'
# 4) check the size of the newly-created Library.swf file
# 5) run 'rake clean' to get rid of the generated files

task :default => :compile_library

desc "Task description"
swfmill :compile_library do |t|
  t.input = 'assets'
  t.output = 'Library.swf'
  t.template = 'Template.erb'
  t.simple = true
end
