require 'test_helper'

class UnixSystemTest < Test::Unit::TestCase
  include Sprout::TestHelper

  context "new unix system" do

    setup do
      @user = Sprout::System::UnixSystem.new
      @user.stubs(:home).returns '/home/someone'
    end

    should "escape spaces in paths" do
      assert_equal 'a\ b', @user.clean_path('a b')
    end

    should "snake case application name" do
      assert_equal '.foo_bar', @user.format_application_name('Foo Bar')
    end

    should "have home" do
      assert_equal '/home/someone', @user.home
    end

    should "have library" do
      assert_equal '/home/someone', @user.library
    end

    should "format application home" do
      assert_equal '/home/someone/.sprouts', @user.application_home('Sprouts')
    end

    context "when fed an application with windows line endings" do

      setup do
        exe_with_crlf = "#!/bin/sh\r\n\r\n################################################################################\r\n##\r\n##  ADOBE SYSTEMS INCORPORATED\r\n##  Copyright 2007 Adobe Systems Incorporated\r\n##  All Rights Reserved.\r\n##\r\n##  NOTICE: Adobe permits you to use, modify, and distribute this file\r\n##  in accordance with the terms of the license agreement accompanying it.\r\n##\r\n################################################################################\r\n\r\n#\r\n# mxmlc launch script for unix.  On windows, mxmlc.exe is used and\r\n# java settings are managed in jvm.config in this directory.\r\n#\r\n\r\ncase `uname` in\r\n		CYGWIN*)\r\n			OS=\"Windows\"\r\n		;;\r\n		*)\r\n			OS=Unix\r\nesac\r\n\r\nif [ $OS = \"Windows\" ]; then\r\n	# set FLEX_HOME relative to mxmlc if not set\r\n	test \"$FLEX_HOME\" = \"\" && {\r\n	FLEX_HOME=`dirname $0`/..\r\n    	FLEX_HOME=`cygpath -m $FLEX_HOME`\r\n	}\r\n\r\nelif [ $OS = \"Unix\" ]; then\r\n\r\n	# set FLEX_HOME relative to mxmlc if not set\r\n	test \"$FLEX_HOME\" = \"\" && {\r\n	FLEX_HOME=`dirname \"$0\"`/..\r\n	}\r\n\r\nfi\r\n\r\n# don't use $FLEX_HOME in this variable because it may contain spaces,\r\n# instead put it on the java args directly, with double-quotes around it\r\nVMARGS=\"-Xmx384m -Dsun.io.useCanonCaches=false\"\r\n\r\njava $VMARGS -jar \"$FLEX_HOME/lib/mxmlc.jar\" +flexlib=\"$FLEX_HOME/frameworks\" \"$@\"\r\n"
        @target = File.join fixtures, 'executable', 'windows_line_endings.tmp'
        File.open(@target, 'wb+') do |f|
          f.write exe_with_crlf
        end
      end

      teardown do
        remove_file @target
      end

      should "fix windows line endings" do
        @user.expects :repair_executable
        @user.attempt_to_repair_executable @target
      end
    end
  end
end


