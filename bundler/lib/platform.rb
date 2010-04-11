#
# platform.rb: naive platform detection for Ruby
# original author: Matt Mower
#
# == Platform
#
# Platform is a simple module which parses the Ruby constant
# RUBY_PLATFORM and works out the OS, it's implementation,
# and the architecture it's running on.
#
# The motivation for writing this was coming across a case where
#
# +if RUBY_PLATFORM =~ /win/+
#
# didn't behave as expected (i.e. on powerpc-darwin-8.1.0)
#
# It is hoped that providing a library for parsing the platform
# means that we can cover all the cases and have something which
# works reliably 99% of the time.
#
# Please report any anomalies or new combinations to the author(s).
#
# == Use
#
# require "platform"
#
# defines
#
# Platform::OS (:unix,:win32,:vms,:os2)
# Platform::impl (:macosx,:linux,:mswin)
# Platform::arch (:powerpc,:x86,:alpha)
#
# if an unknown configuration is encountered any (or all) of
# these constant may have the value :unknown.
#
# To display the combination for your setup run
#
# ruby platform.rb
#
module Platform #:nodoc:
   os = nil
   impl = nil
   arch = nil
   
   if RUBY_PLATFORM =~ /darwin/i
      os = :unix
      impl = :macosx
   elsif RUBY_PLATFORM =~ /linux/i
      os = :unix
      impl = :linux
   elsif RUBY_PLATFORM =~ /freebsd/i
      os = :unix
      impl = :freebsd
   elsif RUBY_PLATFORM =~ /netbsd/i
      os = :unix
      impl = :netbsd
   elsif RUBY_PLATFORM =~ /solaris/i
      os = :unix
      impl = :linux # Our platform checks currently examine 'impl' instead of 'os'
   elsif RUBY_PLATFORM =~ /vista/i
      os = :win32
      impl = :vista
   elsif RUBY_PLATFORM =~ /mswin/i
      os = :win32
      impl = :mswin
   elsif RUBY_PLATFORM =~ /cygwin/i
      os = :win32
      impl = :cygwin
   elsif RUBY_PLATFORM =~ /mingw/i
      os = :win32
      impl = :mingw
   elsif RUBY_PLATFORM =~ /bccwin/i
      os = :win32
      impl = :bccwin
   elsif RUBY_PLATFORM =~ /wince/i
      os = :win32
      impl = :wince
   elsif RUBY_PLATFORM =~ /vms/i
      os = :vms
      impl = :vms
   elsif RUBY_PLATFORM =~ /os2/i
      os = :os2
      impl = :os2 # maybe there is some better choice here?
   else
      os = :unknown
      impl = :unknown
   end
   
   # whither AIX, SOLARIS, and the other unixen?
   # i386-solaris2.11
   
   if RUBY_PLATFORM =~ /(i\d86)/i
      arch = :x86
   elsif RUBY_PLATFORM =~ /ia64/i
      arch = :ia64
   elsif RUBY_PLATFORM =~ /powerpc/i
      arch = :powerpc
   elsif RUBY_PLATFORM =~ /alpha/i
      arch = :alpha
   else
      arch = :unknown
   end
   
   OS = os
   IMPL = impl
   ARCH = arch
   # What about AMD, Turion, Motorola, etc..?
   
end

if __FILE__ == $0
   puts "Platform OS=#{Platform::OS}, impl=#{Platform::IMPL}, arch=#{Platform::ARCH}"
end

