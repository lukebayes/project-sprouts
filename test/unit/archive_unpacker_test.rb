require 'test_helper'

class ArchiveUnpackerTest < Test::Unit::TestCase
  include SproutTestHelper

  def setup
    super
    fixture     = File.join fixtures, 'archive_unpacker'
    @zip_file   = File.join fixture, 'zip', 'some_file.zip'
    @zip_folder = File.join fixture, 'zip', 'some folder.zip'
    
    @tgz_file   = File.join fixture, 'tgz', 'some_file.tgz'
    @tgz_folder = File.join fixture, 'tgz', 'some folder.tgz'

    @exe_file   = File.join fixture, 'copyable', 'some_file.exe'
    @swc_file   = File.join fixture, 'copyable', 'some_file.swc'
    @rb_file    = File.join fixture, 'copyable', 'some_file.rb'

    @file_name  = 'some_file.rb'

    @unpacker = Sprout::ArchiveUnpacker.new
  end

  context "an archive unpacker" do

    should "be identified as zip" do
      assert @unpacker.is_zip?("foo.zip"), "zip"
      assert !@unpacker.is_zip?("foo"), "not zip"
    end

    should "be identified as tgz" do
      assert @unpacker.is_tgz?("foo.tgz"), "tgz"
      assert @unpacker.is_tgz?("foo.tar.gz"), "tgz"
      assert !@unpacker.is_tgz?("foo"), "not tgz"
    end

    should "raise on unknown file types" do
      assert_raises Sprout::Errors::UnknownArchiveType do
        @unpacker.unpack 'SomeUnknowFileType', temp_path
      end
    end

    should "unpack zip on darwin specially" do
      as_a_mac_system do
        @unpacker.expects(:unpack_zip_on_darwin)
        @unpacker.unpack @zip_file, temp_path
      end
    end

    ['exe', 'swc', 'rb'].each do |format|
      should "copy #{format} files" do
        file = eval("@#{format}_file")
        assert @unpacker.unpack file, temp_path
        assert_file File.join(temp_path, File.basename(file))
      end
    end

    ['zip', 'tgz'].each do |format|

      context "with a #{format} archive" do

        setup do
          @archive_file   = eval("@#{format.gsub(/\./, '')}_file")
          @archive_folder = eval("@#{format.gsub(/\./, '')}_folder")
        end

        should "fail with missing file" do
          assert_raises Sprout::Errors::ArchiveUnpackerError do
            @unpacker.unpack "SomeUnknownFile.#{format}", temp_path
          end
        end

        should "fail with missing destination" do
          assert_raises Sprout::Errors::ArchiveUnpackerError do
            @unpacker.unpack @archive_file, "SomeInvalidDestination"
          end
        end

        should "unpack a single archive" do
          expected_file = File.join temp_path, @file_name

          @unpacker.unpack @archive_file, temp_path
          assert_file expected_file
          assert_matches /hello world/, File.read(expected_file)
        end

        should "clobber existing files if necessary" do
          expected_file = File.join temp_path, @file_name
          FileUtils.touch expected_file

          as_a_windows_system do
            @unpacker.unpack @archive_file, temp_path, nil, :clobber
            assert_file expected_file
            assert_matches /hello world/, File.read(expected_file)
          end
        end

        should "not clobber if not told to do so" do
          expected_file = File.join temp_path, @file_name
          FileUtils.touch expected_file

          as_a_windows_system do
            assert_raises Sprout::Errors::DestinationExistsError do
              @unpacker.unpack @archive_file, temp_path, nil, :no_clobber
            end
          end
        end

        should "unpack a nested archive" do
          expected_file = File.join temp_path, 'some folder', 'child folder', 'child child folder', @file_name

          as_a_windows_system do
            @unpacker.unpack @archive_folder, temp_path
            assert_file expected_file
            assert_matches /hello world/, File.read(expected_file)
          end
        end
      end
    end
  end
end

