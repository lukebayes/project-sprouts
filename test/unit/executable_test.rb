require File.dirname(__FILE__) + '/test_helper'
require 'test/fixtures/executable/mxmlc'
require 'test/unit/fake_other_executable'
require 'test/fixtures/executable/subclass/executable_superclass'
require 'test/fixtures/executable/subclass/executable_subclass'

class ExecutableTest < Test::Unit::TestCase
  include SproutTestCase

  context "a new executable delegate" do

    setup do
      @tool       = FakeOtherExecutableTask.new
      @subclassed = ExecutableSubclass.new
    end

    should "add subclass params after those added by superclass" do
      @subclassed.superclass_param = 'A.txt'
      @subclassed.subclass_param = 'B.txt'
      assert_equal '--superclass-param=A.txt --subclass-param=B.txt', @subclassed.to_shell
    end

    should "accept boolean param" do
      @tool.boolean_param = true
      assert @tool.boolean_param
      assert_equal "--boolean-param", @tool.to_shell
    end

    should "serialize to a hash" do
      @tool.boolean_param = true
      hash = @tool.to_hash
      assert_equal true, hash[:boolean_param]
    end

    should "serialize from a hash" do
      hash = { :boolean_param => true }
      @tool.from_hash hash
      assert_equal true, @tool.boolean_param
    end

    should "accept a string param" do
      @tool.string_param = "string1"
      assert_equal "string1", @tool.string_param
      assert_equal "--string-param=string1", @tool.to_shell
    end

    should "not share parameter values across instances" do
      first = FakeOtherExecutableTask.new
      second = FakeOtherExecutableTask.new
      first.string_param = 'value1'
      second.string_param = 'value2'
      assert first.string_param != second.string_param
    end

    should "accept strings param" do
      @tool.strings_param << 'string1'
      @tool.strings_param << 'string2'

      assert_equal ['string1', 'string2'], @tool.strings_param
      assert_equal "--strings-param+=string1 --strings-param+=string2", @tool.to_shell
    end

    should "accept number param" do
      @tool.number_param = 1234
      assert_equal 1234, @tool.number_param
    end

    should "accept parameter alias" do
      @tool.strings_param << "a"
      @tool.sp << "b"

      assert_equal ["a", "b"], @tool.sp
    end

    should "raise UsageError with unknown type" do
      assert_raises Sprout::Errors::UsageError do
        class BrokenExecutable
          include Sprout::Executable
          add_param :broken_param, nil
        end

        tool = BrokenExecutable.new
      end
    end

    should "raise Error if type is not a Class" do
      assert_raises Sprout::Errors::UsageError do
        class BrokenExecutable2
          include Sprout::Executable
          add_param :some_name, :string
        end
      end
    end

    should "raise Error when requested param name already exists" do
      assert_raises Sprout::Errors::DuplicateMemberError do
        class BrokenExecutable3
          include Sprout::Executable
          attr_accessor :existing_method

          add_param :existing_method, String
        end
      end
    end

    should "raise Error if a block is provided to add_param" do
      assert_raises Sprout::Errors::UsageError do
        class BrokenExecutable4
          include Sprout::Executable
          add_param :name, String do
            # this is no longer how it's done...
          end
        end
      end
    end

    should "define a new method" do
      class WorkingTool
        include Sprout::Executable
        add_param :custom_name, String
      end

      tool1 = WorkingTool.new
      tool1.custom_name = "Foo Bar"
      assert_equal "Foo Bar", tool1.custom_name

      tool2 = WorkingTool.new
      tool2.custom_name = "Bar Baz"
      assert_equal "Bar Baz", tool2.custom_name
    end

    should "accept custom reader" do
      class WorkingTool
        include Sprout::Executable
        add_param :custom1, String, { :reader => :read_custom }
        def read_custom
          "#{@custom1} world"
        end
      end

      tool = WorkingTool.new
      tool.custom1 = 'hello'
      assert_equal 'hello world', tool.custom1
    end

    should "accept custom writer" do
      class WorkingTool
        include Sprout::Executable
        add_param :custom2, String, { :writer => :write_custom }
        def write_custom(value)
          @custom2 = "#{value} world"
        end
      end

      tool = WorkingTool.new
      tool.custom2 = 'hello'
      assert_equal 'hello world', tool.custom2
    end

    # TODO: Ensure that file, files, path and paths
    # validate the existence of the references.

    # TODO: Ensure that a helpful error message is thrown
    # when assignment operator is used on collection params
  end

  context "a new mxmlc task" do

    setup do
      @tool = Sprout::MXMLC.new
      @mxmlc_executable = File.join(fixtures, 'executable', 'flex3sdk_gem', 'mxmlc')
    end

    should "accept input" do
      as_a_unix_system do
        @tool.input = "test/fixtures/executable/src/Main.as"
        assert_equal "test/fixtures/executable/src/Main.as", @tool.input
        assert_equal "test/fixtures/executable/src/Main.as", @tool.to_shell
      end
    end

    should "accept default gem name" do
      assert_equal 'flex4sdk', @tool.pkg_name
    end

    should "override default gem name" do
      @tool.pkg_name = 'flex5sdk'
      assert_equal 'flex5sdk', @tool.pkg_name
    end

    should "accept default gem version" do
      assert_equal '>= 1.0.pre', @tool.pkg_version
    end

    should "override default gem version" do
      @tool.pkg_version = '1.1.pre'
      assert_equal '1.1.pre', @tool.pkg_version
    end

    should "accept default gem executable" do
      assert_equal :mxmlc, @tool.executable
    end

    should "override default gem executable" do
      @tool.executable = :compc
      assert_equal :compc, @tool.executable
    end

    should "accept configuration as a file task" do
      as_a_unix_system do
        @tool = mxmlc 'bin/SomeFile.swf' do |t|
          t.source_path << 'test/fixtures/executable/src'
          t.input = 'test/fixtures/executable/src/Main.as'
        end
        assert_equal 'bin/SomeFile.swf', @tool.output
        assert_equal "--output=bin/SomeFile.swf --source-path+=test/fixtures/executable/src test/fixtures/executable/src/Main.as", @tool.to_shell
      end
    end

    should "accept configuration with prereqs as a file task" do
      as_a_unix_system do
        task :other_task
        @tool = mxmlc 'bin/SomeFile.swf' => [:clean, :other_task] do |t|
          t.source_path << 'test/fixtures/executable/src'
          t.input = 'test/fixtures/executable/src/Main.as'
        end
        assert_equal 'bin/SomeFile.swf', @tool.output
        assert_equal "--output=bin/SomeFile.swf --source-path+=test/fixtures/executable/src test/fixtures/executable/src/Main.as", @tool.to_shell
      end
    end

    should "to_shell input" do
      as_a_unix_system do
        @tool.debug = true
        @tool.source_path << "test/fixtures/executable/src"
        assert_equal "--debug --source-path+=test/fixtures/executable/src", @tool.to_shell
      end
    end

    should "execute the registered executable" do
      # Configure stub executable:
      @tool.input = 'test/fixtures/executable/src/Main.as'
      @tool.source_path << 'test/fixtures/executable/src'
      @tool.debug = true
      response = OpenStruct.new(:path => @mxmlc_executable)
      Sprout::Executable.expects(:load).with(:mxmlc, 'flex4sdk', '>= 1.0.pre').returns response

      # Ensure the exe file mode is NOT valid:
      File.chmod 0644, @mxmlc_executable
      first = File.stat(@mxmlc_executable).mode

      # Execute the stub executable:
      @tool.execute

      # Ensure the file mode was updated:
      assert "non-executable file mode should be updated by execute", first != File.stat(@mxmlc_executable).mode
    end

    should "include prerequisites" do
      @tool.input = 'test/fixtures/executable/src/Main.as'
      file_task = @tool.to_rake('bin/SomeProject.swf')
      assert_equal 2, file_task.prerequisites.size
    end
  end

end

