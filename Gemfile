source "http://rubygems.org"

gem "rake"
gem "rubyzip", "0.9.4"
gem "archive-tar-minitar", ">= 0.5.2"

if RUBY_PLATFORM =~ /mswin/i
  # Win32 only:
  gem "win32-open3", "0.2.5"
else
  # Darwin and Nix only:
  gem "open4", ">= 0.9.6"

  group :test do
    gem "rcov"
  end
end

group :test do
  gem "shoulda"
  gem "mocha"
  gem "flay"
  gem "flog"
  gem "heckle"
end

