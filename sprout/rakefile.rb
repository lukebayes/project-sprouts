require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'fileutils'
require File.dirname(__FILE__) + '/lib/sprout'
require File.dirname(__FILE__) + '/lib/sprout/version'

PROJECT                 = "sprout"
NAME                    = "sprout"
SUMMARY                 = "Sprout is an open-source, cross-platform project generation, configuration and build tool, that currently suports ActionScript 2, ActionScript 3, Flex and AIR development."
GEM_VERSION             = Sprout::VERSION::STRING
AUTHOR                  = "Luke Bayes"
EMAIL                   = "projectsprouts@googlegroups.com"
HOMEPAGE                = "http://www.projectsprouts.org"
DESCRIPTION             =<<EOF
Sprout is a modular set of tools that take the tedium and frustration out of creating and managing programming projects by automatically installing and configuring external tools, libraries, commands and build tasks. Bundles are currently available to support ActionScript 2, ActionScript 3, Flex and AIR development.
EOF
HOMEPATH                = "http://#{PROJECT}.rubyforge.org"
RELEASE_TYPES           = ["gem"]
PKG_LIST                = FileList['[a-zA-Z]*',
                                  'samples/**/*',
                                  'bin/**/*',
                                  'lib/**/*',
                                  'doc/*'
                                  ]
PKG_LIST.exclude('.svn')
PKG_LIST.exclude('artifacts')
PKG_LIST.each do |file|
  task :package => file
end

def apply_shared_spec(s)
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
    s.has_rdoc            = true
    s.rdoc_options        << '--title' << 'Project Sprouts -- Core Documentation'
    s.rdoc_options        << '--main' << 'Sprout::Sprout'
    s.rdoc_options        << '--line-numbers' << '--inline-source'
    s.rdoc_options        << '--charset' << 'utf-8'
    s.rdoc_options        << '-i' << '.'
    s.files               = PKG_LIST.to_a
    s.executables         = ['sprout']
    s.default_executable  = 'sprout'

    s.add_dependency('rubyzip', '>= 0.9.1')
    s.add_dependency('archive-tar-minitar', '>= 0.5.1')
    s.add_dependency('rubigen', '1.5.2')
    s.add_dependency('net-sftp', '>= 2.0.4')
    s.add_dependency('net-ssh', '>= 2.0.19')
    s.add_dependency('rake')
end

osx_spec = Gem::Specification.new do |s|
  apply_shared_spec(s)
  s.platform = 'darwin'
  # Add osx-specific dependencies here

  # Can't really depend on rb-appscript b/c this requires OS X dev-tool disk
  #s.add_dependency('rb-appscript', '>= 0.5.0')
  s.add_dependency('open4', '>= 0.9.6')
end

osx_snow_leopard_spec = Gem::Specification.new do |s|
  apply_shared_spec(s)
  s.platform = 'x86-darwin-10'
  # Add snow-leopard-specific dependencies here

  # Can't really depend on rb-appscript b/c this requires OS X dev-tool disk
  #s.add_dependency('rb-appscript', '>= 0.5.0')
  s.add_dependency('open4', '>= 0.9.6')
end

nix_spec = Gem::Specification.new do |s|
  apply_shared_spec(s)
  s.platform = 'x86-linux'
  # Add nix-specific dependencies here
  s.add_dependency('open4', '>= 0.9.6')
end

win_spec = Gem::Specification.new do |s|
  apply_shared_spec(s)
  s.platform = 'mswin32'
  # Add win-specific dependencies here
  s.add_dependency('win32-open3', '0.2.5')
  # Added again here b/c win users report
  # having to install these manually:
  s.add_dependency('net-sftp', '>= 2.0.4')
  s.add_dependency('net-ssh', '>= 2.0.19')
end

ruby_spec = Gem::Specification.new do |s|
  apply_shared_spec(s)
  s.platform = Gem::Platform::RUBY
  s.add_dependency('open4', '>= 0.9.6')
end

Rake::GemPackageTask.new(osx_spec) do |pkg|
end

Rake::GemPackageTask.new(osx_snow_leopard_spec) do |pkg|
end

Rake::GemPackageTask.new(nix_spec) do |pkg|
end

Rake::GemPackageTask.new(win_spec) do |pkg|
end

Rake::GemPackageTask.new(ruby_spec) do |pkg|
end

Rake::RDocTask.new do |t|
  t.rdoc_files.include(['doc/*', 'lib/*.rb', 'lib/**/*.rb', 'MIT-LICENSE'])
  t.title    = "Project Sprouts -- Core Documentation"
  t.rdoc_dir = 'rdoc'
  t.main     = 'Sprout::Sprout'
  t.options << '--line-numbers' << '--inline-source'
  t.options << '--charset' << 'utf-8'
  t.options    << '-i .'
end

CLEAN.add('rdoc')


require File.dirname(__FILE__) + '/script/build_helpers'

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

#task :release => :release_rubyforge
