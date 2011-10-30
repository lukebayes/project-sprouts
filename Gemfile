source "http://rubygems.org"

gem "bundler", ">= 0.9.19"
gem "rake", ">= 0.9.2"
gem "rubyzip", "0.9.4"
gem "archive-tar-minitar", "0.5.2"

if RUBY_PLATFORM =~ /mswin/i
  gem "win32-open3", "0.2.5" # Win32 only
else
  gem "open4", ">= 0.9.6" # All others
end

group :development do
  gem "yard"
  #gem "RedCloth" # This doesn't work Windows for some reason...
  gem "shoulda"
  gem "mocha"
  gem "flay"
  gem "flog"
  gem "heckle"

  # rcov doesn't appear to install on
  # debian/ubuntu. Boo. Ideas?
  if RUBY_PLATFORM =~ /darwin/i
    gem "rcov"
  end
end

