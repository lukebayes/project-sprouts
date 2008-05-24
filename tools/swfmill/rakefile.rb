require 'rake'
require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/testtask'
require 'lib/sprout/swfmill/version'

PROJECT                 = 'sprout'
NAME                    = 'sprout-swfmill-tool'
SUMMARY                 = 'SWFMill'
GEM_VERSION             = Sprout::SWFMill::VERSION::STRING
AUTHOR                  = 'Daniel Fischer'
EMAIL                   = 'projectsprouts@googlegroups.com'
HOMEPAGE                = 'http://www.swfmill.org'
DESCRIPTION             = "The SWFMill Rubygem is brought to you by Project Sprouts (http://www.projectsprouts.org)"
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

def configure_spec(spec)
  spec.summary             = SUMMARY
  spec.description         = DESCRIPTION
  spec.name                = NAME
  spec.version             = GEM_VERSION
  spec.author              = AUTHOR
  spec.email               = EMAIL
  spec.homepage            = HOMEPAGE
  spec.rubyforge_project   = PROJECT
  spec.require_path        = 'lib'
  spec.has_rdoc            = false
  spec.files               = PKG_LIST.to_a
  spec.add_dependency("sprout", ">= 0.7.1")
end

ruby_spec = Gem::Specification.new do |spec|
  configure_spec(spec)
  spec.platform            = Gem::Platform::RUBY
  spec.bindir              = 'bin'
  spec.executables         = ['swfmill']
  spec.default_executable  = 'swfmill'
end

# Do not add the binary to the Linux build
linux_spec = Gem::Specification.new do |spec|
  configure_spec(spec)
  spec.platform            = 'x86-linux'
end

Rake::GemPackageTask.new(ruby_spec) do |p|
end

Rake::GemPackageTask.new(linux_spec) do |p|
end

require File.dirname(__FILE__) + '/../../sprout/script/build_helpers'
# Each task that wants this feature, needs to set this up
# because the flexsdks shouldn't get it...
task :release => :increment_revision
