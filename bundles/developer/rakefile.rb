require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/testtask'
require 'lib/sprout/developer/version'

SPROUT_HOME = ENV['SPROUT_HOME']

PROJECT                 = 'sprout'
NAME                    = 'sprout-developer-bundle'
SUMMARY                 = 'Project and Code Generators for Sprout development'
GEM_VERSION             = Sprout::Developer::VERSION::STRING
AUTHOR                  = 'Pattern Park'
EMAIL                   = 'projectsprouts@googlegroups.com'
HOMEPAGE                = 'http://www.projectsprouts.org'
DESCRIPTION             = "Project and Code Generators for Sprout development"
HOMEPATH                = "http://#{PROJECT}.rubyforge.org"
RELEASE_TYPES           = ["gem"]
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
  s.autorequire         = 'sprout/as3'
  s.has_rdoc            = false
  s.files               = PKG_LIST.to_a

  s.add_dependency('sprout', '>= 0.7.1')
end

Rake::GemPackageTask.new(spec) do |p|
end

require File.join(SPROUT_HOME, 'sprout/script/build_helpers')

# Each task that wants this feature, needs to set this up
# because the flexsdks shouldn't get it...
#task :release => :increment_revision
