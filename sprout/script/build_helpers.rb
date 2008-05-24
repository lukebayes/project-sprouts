$:.push(File.expand_path(File.dirname(__FILE__) + '/../lib/'))
require 'sprout'
require 'sprout/tasks/sftp_task'
require 'rake'
require 'rake/rdoctask'

ARTIFACTS = ENV['CC_BUILD_ARTIFACTS'] || 'artifacts'
CLEAN.add('pkg')

Rake::TestTask.new('test') do |t|
  t.pattern = 'test/**/*_test.rb'
  t.warning = false
end

task :release => [:package]

desc "Publish and release files to RubyForge."
 task :release_rubyforge do
#  system("svn commit -m 'Created release #{VERS}'")
#  system("svn copy -m 'Created tag for release #{VERS}' https://projectsprouts.googlecode.com/svn/trunk/ https://projectsprouts.googlecode.com/svn/tags/#{VERS}")

  system('rubyforge login')
  for ext in RELEASE_TYPES
    release_command = "rubyforge add_release #{PROJECT} #{NAME} '#{GEM_VERSION}' pkg/#{NAME}-#{GEM_VERSION}.#{ext}"
    puts release_command
    system(release_command)
  end
end

# Duplicate code from ../../rakefile.rb!
def add_tool(file, clazz)
  name = File.basename(file).gsub(/.rb$/, '').gsub(/_task/, '')
  doc_file = File.expand_path(File.dirname(file) + "/#{name}_rdoc.rb")
  content = clazz.new(name, Rake::application).to_rdoc

  File.open(doc_file, 'w') do |f|
    f.write content
  end

  CLEAN.add(doc_file)

  task :package => doc_file
  task :rdoc => doc_file
end

#desc "Create documentation for concrete ToolTasks"
#def test_generate_rdoc_output
#  puts "test generate rdoc output"
#  mxmlc_task = mxmlc 'SomeProject.swf'
#  result = mxmlc_task.to_rdoc

#  File.open(File.dirname(__FILE__) + '/mxmlc_doc.rb', 'w') do |f|
#    f.write result
#  end
#end

desc "Increment the release revision"
task :increment_revision do
  name = NAME.gsub('sprout-', '')
  name = name.gsub('-bundle', '')
  name = name.gsub('-tool', '')
  version_file = File.join('lib', 'sprout', name, 'version.rb')
  if(!File.exists?(version_file))
    version_file = File.join('lib', 'sprout', 'version.rb')
  end
  
  raise StandardError.new("[ERROR] Unable to increment revision, version file not found at: #{version_file}") unless File.exists?(version_file)

  file = File.open(version_file, 'r+')
  lines = ''
  file.readlines.each do |line|
    if(line.match(/^\s+TINY/))
      d = line.match(/\d+/)
      incr = d.to_s.to_i + 1
      newline = line.gsub(/(\d+)/, incr.to_s)
      lines << newline
      puts "Incremented revision to #{incr.to_s}"
      next
    end
    lines << line
  end
  
  File.open(version_file, 'w') do |file|
    file.puts lines
  end
end

desc "Reinstall this gem"
task :reinstall do |t|
  system "sudo gem uninstall #{NAME}"
  system "rake clean package"
  system "sudo gem install -f pkg/#{NAME}-#{GEM_VERSION}.gem"
end

