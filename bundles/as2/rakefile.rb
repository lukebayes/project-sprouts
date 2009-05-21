require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/testtask'
require 'lib/sprout/as2/version'

SPROUT_HOME             = ENV['SPROUT_HOME']
PROJECT                 = 'sprout'
NAME                    = 'sprout-as2-bundle'
SUMMARY                 = 'Project and Code Generators for ActionScript 2 Development'
GEM_VERSION             = Sprout::AS2::VERSION::STRING
AUTHOR                  = 'Pattern Park'
EMAIL                   = 'projectsprouts@googlegroups.com'
HOMEPAGE                = 'http://www.projectsprouts.org'
DESCRIPTION             = "Code Generation and Rake Tasks for ActionScript 2.0 Development"
HOMEPATH                = "http://#{PROJECT}.rubyforge.org"
RELEASE_TYPES           = ["gem"]

#########################
# This stuff needs to be before the PKG_LIST declaration
# so that generated tool_doc.rb files get included in the rubygem
require File.join(SPROUT_HOME, 'sprout/script/build_helpers')
$:.push(File.dirname(__FILE__) + '/lib')
require 'sprout/as2'
lib_dir = File.dirname(__FILE__) + '/lib'

add_tool(lib_dir + '/sprout/tasks/swfmill_task.rb', Sprout::SWFMillTask)
add_tool(lib_dir + '/sprout/tasks/mtasc_task.rb', Sprout::MTASCTask)
#########################

PKG_LIST                = FileList['[a-zA-Z]*',
                                  'lib/**/*'
                                  ]

PKG_LIST.exclude('.svn')
PKG_LIST.exclude('artifacts')
PKG_LIST.each do |file|
  task :package => file
end

spec = Gem::Specification.new do |s|
  s.platform            = Gem::Platform::RUBY
  s.summary             = SUMMARY
  s.description         = DESCRIPTION
  s.name                = NAME
  s.version             = GEM_VERSION
  s.author              = AUTHOR
  s.email               = EMAIL
  s.homepage            = HOMEPAGE
  s.rubyforge_project   = PROJECT
  s.require_path        = 'lib'
  s.autorequire         = 'sprout/as2'
  s.has_rdoc            = true
  s.extra_rdoc_files    = %w( README )
  s.rdoc_options        << '--main'         << 'README'
  s.rdoc_options        << '--title'        << DESCRIPTION
  s.rdoc_options        << '--line-numbers' << '--inline-source'
  s.rdoc_options        << '--charset'      << 'utf-8'
  s.rdoc_options        << '-i'             << '.'
  s.files               = PKG_LIST.to_a

  s.add_dependency('sprout', '>= 0.7.189')
  s.add_dependency('sprout-flashplayer-bundle', '>= 10.22.0')
end

Rake::GemPackageTask.new(spec) do |p|
end
