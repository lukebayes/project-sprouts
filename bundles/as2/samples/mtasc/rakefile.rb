require 'sprout'

# Assign the default task to run
task :default => :run

desc "Run SomeProject.swf using Adobe Flash Player"
flashplayer :run => [:compile] do |t|
  t.swf = 'bin/SomeProject.swf'
end

desc "Compile Using MTASC"        # desc strings show up when you run 'rake -T'
mtasc :compile do |t|
  t.header = '800:600:24'         # width:height:framerate
  t.main = true                   # Look for public static main in input file(s)
  t.strict = true                 # Use strict type checking

  t.input = 'src/SomeProject.as'  # Use this main ActionScript file
  t.out = 'bin/SomeProject.swf'   # Create this swf file
  t.cp << 'src'                   # Add this folder to the classpath
end

