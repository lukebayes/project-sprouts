require 'rake/clean'
require 'sprout'
require 'sprout/tasks/sftp_task'

FILES = File.join(File.dirname(__FILE__), 'files')
PKG = File.join(File.dirname(__FILE__), 'pkg')
ARTIFACTS = ENV['CC_BUILD_ARTIFACTS'] || 'artifact'

Dir.glob("#{FILES}/**").each do |file|
  load file

  name = File.basename(file).split('.rb').join('')
  task :package => name
end

CLEAN.add(PKG)

desc "Package all libraries as gems"
task :package do
  Dir.glob("#{PKG}/**").each do |file|
    if(File.directory?(file))
      FileUtils.rm_rf(file)
    end
  end
end

desc "Increment Revision"
task :increment_revision do
  # library tasks should be incremented independently...
end
