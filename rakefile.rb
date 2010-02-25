require 'rubygems'
require 'rake/clean'
require 'rake/rdoctask'

PROJECT_NAME = 'sprout'
ARTIFACTS = File.expand_path(ENV['CC_BUILD_ARTIFACTS'] || 'pkg')
PROJECTS = ['tools/flashplayer',
            'tools/flex2sdk',
            'tools/flex3sdk',
            'tools/mtasc',
            'tools/swfmill',
            'bundles/developer',
            'bundles/as2', 
            'bundles/as3',
            'bundles/flashplayer',
            'libraries',
            'sprout'
            ]

if(File.basename(ARTIFACTS) == 'pkg')
  CLEAN.add(ARTIFACTS)
end

Rake::RDocTask.new do |t|
  t.rdoc_files.include(['sprout/doc/*',
                        'sprout/lib/**/*.rb',
                        'bundles/**/lib/**/*.rb',
                        'bundles/**/README'
                        ])
  t.title    = "Project Sprouts"
  t.rdoc_dir = 'rdoc'
  t.options << '-i . -i sprout'
  t.main = 'Sprout::Sprout'
end

desc "Copy rdoc output to the site directory"
task :copy_rdoc => :rdoc do |t|
  FileUtils.rm_rf('../site/www/rdoc')
  FileUtils.cp_r('rdoc', '../site/www/rdoc')
end

CLEAN.add('rdoc')

# Duplicate code from sprout/script/build_helpers.rb!
def add_tool(file, clazz)
  name = File.basename(file).gsub(/.rb$/, '').gsub(/_task/, '')
  doc_file = File.expand_path(File.dirname(file) + "/#{name}_documentation.rb")
  content = clazz.new(name, Rake::application).to_rdoc

  deps = FileList['**/**/*.rb']
  file deps

  file doc_file => deps do |t|
    puts ">> Writing #{doc_file}"
    File.open(doc_file, 'w') do |f|
      f.write content
    end
  end
  
  CLEAN.add(doc_file)
  task :rdoc => doc_file
end

$:.push(File.dirname(__FILE__) + '/sprout/lib')
$:.push(File.dirname(__FILE__) + '/bundles/as2/lib')
$:.push(File.dirname(__FILE__) + '/bundles/as3/lib')

require 'sprout/as2'
require 'sprout/as3'

add_tool(File.dirname(__FILE__) + '/bundles/as2/lib/sprout/tasks/swfmill_task.rb', Sprout::SWFMillTask)
add_tool(File.dirname(__FILE__) + '/bundles/as2/lib/sprout/tasks/mtasc_task.rb', Sprout::MTASCTask)

add_tool(File.dirname(__FILE__) + '/bundles/as3/lib/sprout/tasks/mxmlc_task.rb', Sprout::MXMLCTask)
add_tool(File.dirname(__FILE__) + '/bundles/as3/lib/sprout/tasks/compc_task.rb', Sprout::COMPCTask)

add_tool(File.dirname(__FILE__) + '/bundles/as3/lib/sprout/tasks/adl.rb', Sprout::ADLTask)
add_tool(File.dirname(__FILE__) + '/bundles/as3/lib/sprout/tasks/adt_task.rb', Sprout::ADTTask)
add_tool(File.dirname(__FILE__) + '/bundles/as3/lib/sprout/tasks/adt_cert_task.rb', Sprout::ADTCertTask)

def execute_in_each_project(str)
  PROJECTS.each do |p|
    puts "----------------------"
    puts ">> Execute #{p} #{str}"
    execute_in_project(p, str)
  end
end

def execute_in_project(project, str)
  start = File.expand_path(Dir.pwd)
  Dir.chdir project
  begin
    raise "[ERROR] '#{project}' exited with errors: #{$?}" unless system(str)
  ensure
    Dir.chdir start
  end
end

task :cruise => [:clean, :package]

desc "Increment the revision number for everything"
task :increment_revision do |t|
  execute_in_each_project("rake increment_revision")
end

def fix_x86_mswin
  files = Dir.glob('pkg/*x86-mswin*')
  files.each do |name|
    new_name = name.gsub('-x86', '')
    puts "Renaming x86-mswin gem from #{name} to #{new_name}"
    File.move(name, new_name)
  end
end

task :package do
  fix_x86_mswin
end

desc "Package #{PROJECTS.join(', ')} sprouts"
task :package do |t|
  execute_in_each_project("rake package CC_BUILD_ARTIFACTS=#{ARTIFACTS}")

  FileUtils.mkdir_p(ARTIFACTS)
  PROJECTS.each do |p|
    files = FileList["#{p}/pkg/*"]
    FileUtils.cp(files, "#{ARTIFACTS}/")
  end
  
  fix_x86_mswin
end

task :clean do |t|
  execute_in_each_project("rake clean CC_BUILD_ARTIFACTS=#{ARTIFACTS}")
end

def gem_suffixes
  return {'darwin' => true, 'mswin32' => true, 'linux' => true, 'x86' => true}
end

##########################
# Rubyforge Support

def build_expected_package_names(releases)
  basename = nil
  packages = {}
  releases.each do |file|
    parts = File.basename(file.gsub(/.gem$/,'')).split('-')
    version = parts.pop
    while(gem_suffixes[version]) do
      version = parts.pop
    end
    package_name = parts.join('-')
    if(packages[package_name].nil?)
      #puts "Creating new package for: #{package_name}"
      packages[package_name] = {:version => version, :files => []}
    end
    #puts ">> Adding file: #{file} version #{version} to package #{package_name}"
    packages[package_name][:files] << file
  end

  return packages
end

class RubyForgeError < StandardError; end

class RubyForge

  def get_group_id(group_name)
    groups.each do |key, value|
      puts ">> looking for #{group_name} against: #{key}"
      if(key == group_name)
        return value
      end
    end
    raise RubyForgeError.new("Unable to find group_id for #{group_name}")
  end
  
  def ensure_package_exists(group_id, package_name)
    if(!packages[package_name])
      raise RubyForgeError.new("Package Name must be non-null for creation") unless package_name
      puts ">> Creating new package for #{package_name}"
      create_package(group_id, package_name)
    end
    return packages[package_name]
  end
  
  def has_release?(package_name, release_name)
    begin
      package = self.releases[package_name]
      package.each do |release|
        if(release[0] == release_name)
          return true
        end
      end
      return false
    rescue StandardError => e
      return false
    end
  end
  
  def releases
    @autoconfig['release_ids']
  end
  
  def packages
    @autoconfig['package_ids']
  end
  
  def groups
    @autoconfig['group_ids']
  end
  
end

desc "Release the contents of 'pkg/*.gem' to Rubyforge"
task :release_to_rubyforge do |t|
  require 'rubyforge'
  releases = Dir.glob('pkg/*')
  expected_packages = build_expected_package_names(releases)

  known_packages = {}
  rubyforge = RubyForge.new
  rubyforge.configure
  rubyforge.login
  
  group_id = rubyforge.get_group_id(PROJECT_NAME)
  raise RubyForgeError.new("Cannot create packages or add releases without expected group_id for #{PROJECT_NAME}") unless (group_id)
  
  puts "-------------------"
  
  expected_packages.each do |package_name, release|

    package_id = rubyforge.ensure_package_exists(group_id, package_name)
    files = release[:files]
    version = release[:version]
    
    puts ">> Checking: #{package_name} [#{version}] with: #{files.join(', ')}"
    if(!rubyforge.has_release?(package_name, version))

      begin
        # Build up arguments list because the *files arg is strangely implemented
        args = [group_id, package_id, version]
        args = args.concat(files)
        rubyforge.send(:add_release, *args)
        puts "++ RELEASED #{package_name} #{version} with #{files.join(', ')}"
      rescue StandardError => e
        if(e.message.index('already released this version'))
          puts ">> Rubyforge already has a release for: #{package_name} #{version}"
        elsif(e.message.index('Invalid package_id'))
          puts ">> Rubyforge cannot work with #{package_name}"
        else
          puts ">> Unhandled Rubyforge exception on #{package_name} for #{version}"
          raise e
        end
      end

    else
      puts ">> No release necessary for: #{package_name} #{version}"
    end

  end

end

desc "Release to gems.projectsprouts.org (cannot work from *all* sprouts)"
task :release_to_dev do |t|
  exec 'scp pkg/* dev.patternpark.com:/var/www/projectsprouts/current/gems/'
end

require File.join(File.dirname(__FILE__), 'sprout', 'lib', 'sprout', 'tasks', 'ssh_task')

desc "Update the remote gem index immediately"
ssh :update_gem_index => :release_to_dev do |t|
  t.host          = 'dev.patternpark.com'
  t.commands      << 'cd /var/www/projectsprouts/current/gems'
  t.commands      << 'gem generate_index -d .'
end

=begin
desc "Release rdocs to www.projectsprouts.org/rdoc"
sftp :release_rdoc => :clear_rdoc do |t|
  t.host          = 'dev.patternpark.com'
  t.remote_path   = '/var/www/projectsprouts/current/rdoc'
  t.files         = Dir.glob("rdoc/**/**/*")
  t.local_path    = "rdoc"
end

desc "Remove the existing rdoc build"
ssh :clear_rdoc do |t|
  t.host          = 'dev.patternpark.com'
  t.commands      << 'rm -Rf /var/www/projectsprouts/current/rdoc'
  t.commands      << 'mkdir /var/www/projectsprouts/current/rdoc'
end
=end

# desc "Release to RubyForge and ProjectSprouts"
# task :release => [:update_gem_index, :release_to_rubyforge]

##########################

def gem_files
  FileList['pkg/*.gem'].each do |name|
    yield name if block_given?
  end
end

desc "Migrate gems from RubyForge to GemCutter"
task :migrate do
  gem_files.each do |file|
    name = name.gsub(/.gem$/, '')
    name = name.gsub(/-\d.*$/, '')
    name = name.gsub(/^pkg\//, '')
    begin
      puts "Migrating: #{name}"
      sh "gem migrate #{name}"
    rescue
      puts ">> [ERROR] There was a problem migrating: #{name}"
    end
  end
end

desc "Release gems to gemcutter.org"
task :release do
  gem_files.each do |file|
    begin
      sh "gem push #{file}"
    rescue
      puts ">> [ERROR] There was a problem pushing #{name}"
    end
  end
end

desc "Remove all gems that begin with 'sprout-'"
task :remove_all do |t|
  RubiGen::GemGeneratorSource.new().each_sprout do |sprout|
    puts "found sprout: #{sprout.name}"
    raise ">> Exited with errors: #{$?}" unless system("gem uninstall -x -a #{sprout.name}")
  end
end

# Add required support for remove_all task
gem 'rubigen'
require 'rubigen'

module RubiGen
  class GemGeneratorSource < AbstractGemSource

    def each_sprout
      Gem::cache.search(/sprout-*/).inject({}) { |latest, gem|
        hem = latest[gem.name]
        latest[gem.name] = gem if hem.nil? or gem.version > hem.version
        latest
      }.values.each { |gem|
        yield Spec.new(gem.name, gem.full_gem_path, label)
      }
    end
  end
end
