require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/testtask'
require 'lib/sprout/air/version'

PROJECT                 = 'sprout'
NAME                    = 'sprout-air-tool'
SUMMARY                 = 'Adobe Integrate Runtime SDK'
GEM_VERSION             = Sprout::AIR::VERSION::STRING
AUTHOR                  = 'Adobe, Inc.'
EMAIL                   = 'projectsprouts@googlegroups.com'
HOMEPAGE                = 'http://www.adobe.com/products/air'
DESCRIPTION             = "The AIR Rubygem is brought to you by Project Sprouts (http://www.projectsprouts.org)"
HOMEPATH                = "http://#{PROJECT}.rubyforge.org"
RELEASE_TYPES           = ["gem"]
PKG_LIST                = FileList['[a-zA-Z]*',
                                  'bin/**/*',
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
  s.bindir              = 'bin'
  s.has_rdoc            = false
  s.files               = PKG_LIST.to_a
  s.executables         = ['adl', 'adt']
  s.default_executable  = 'adl'

  s.add_dependency('sprout', '>= 0.7.167')
end

Rake::GemPackageTask.new(spec) do |p|
end

require File.dirname(__FILE__) + '/../../sprout/script/build_helpers'
