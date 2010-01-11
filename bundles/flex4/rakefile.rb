require 'rake/gempackagetask'
require 'rake/clean'
require 'rake/testtask'
require 'lib/sprout/flex4/version'

SPROUT_HOME             = ENV['SPROUT_HOME']
PROJECT                 = 'sprout'
NAME                    = 'sprout-flex4-bundle'
SUMMARY                 = 'Project and Code Generators for Flex 4 Development'
GEM_VERSION             = Sprout::Flex4::VERSION::STRING
AUTHOR                  = 'Pattern Park'
EMAIL                   = 'projectsprouts@googlegroups.com'
HOMEPAGE                = 'http://www.projectsprouts.org'
DESCRIPTION             = "Code Generation and Rake Tasks for MXML Development"
HOMEPATH                = "http://#{PROJECT}.rubyforge.org"
RELEASE_TYPES           = ["gem"]

require File.join(SPROUT_HOME, 'sprout/script/build_helpers')

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
  s.autorequire         = 'sprout/flex4'
  s.has_rdoc            = true
  s.extra_rdoc_files    = %w( README )
  s.rdoc_options        << '--main'         << 'README'
  s.rdoc_options        << '--title'        << DESCRIPTION
  s.rdoc_options        << '--line-numbers' << '--inline-source'
  s.rdoc_options        << '--charset'      << 'utf-8'
  s.rdoc_options        << '-i'             << '.'
  s.files               = PKG_LIST.to_a

  s.add_dependency('sprout', '>= 0.7.211')
  s.add_dependency('sprout-as3-bundle', '>= 1.0.28')
  s.add_dependency('sprout-flex4sdk-tool', '>= 4.2.10')
end

Rake::GemPackageTask.new(spec) do |p|
end
