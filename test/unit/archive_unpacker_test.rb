require File.dirname(__FILE__) + '/test_helper'

class ArchiveUnpackerTest < Test::Unit::TestCase
  include SproutTestCase

  def setup
    super
    fixture      = File.join fixtures, 'archive_unpacker'
    @some_file   = File.join fixture, 'some_file.zip'
    @some_folder = File.join fixture, 'some folder.zip'
  end

  context "a zip archive" do

    setup do
      @unpacker = Sprout::ArchiveUnpacker.new
    end

    should "be identified as such" do
      assert @unpacker.is_zip?("foo.zip"), "zip"
      assert !@unpacker.is_zip?("foo"), "not zip"
    end

    should "fail with invalid archive" do
      assert_raises Sprout::ArchiveUnpackerError do
        @unpacker.unpack "SomeUnknownFile.zip", temp_path
      end
    end

    should "fail with invalid destination" do
      assert_raises Sprout::ArchiveUnpackerError do
        @unpacker.unpack @some_file, "SomeInvalidDestination"
      end
    end

    should "unpack a single zipped file" do
      expected_file = File.join temp_path, 'some_file.rb'

      @unpacker.unpack @some_file, temp_path
      assert_file expected_file
      assert_matches /hello world/, File.read(expected_file)
    end

    should "clobber existing files if necessary" do
      expected_file = File.join temp_path, 'some_file.rb'
      FileUtils.touch expected_file

      @unpacker.unpack_zip @some_file, temp_path, :clobber
      assert_file expected_file
      assert_matches /hello world/, File.read(expected_file)
    end

    should "not clobber if not told to do so" do
      expected_file = File.join temp_path, 'some_file.rb'
      FileUtils.touch expected_file

      assert_raises Zip::ZipDestinationFileExistsError do
        @unpacker.unpack_zip @some_file, temp_path, :no_clobber
      end
    end

    should "unpack a nested, zipped file" do
      expected_file = File.join temp_path, 'some folder', 'child folder', 'child child folder', 'some_file.rb'

      @unpacker.unpack @some_folder, temp_path
      assert_file expected_file
      assert_matches /hello world/, File.read(expected_file)
    end

  end
end

