# frozen_string_literal: true

require 'test_helper'

class MediaFileTest < ActiveSupport::TestCase
  test 'should get file path array from media_path' do
    expect_file_paths = [
      '/app/test/fixtures/files/artist1_album1.flac',
      '/app/test/fixtures/files/artist2_album3.ogg',
      '/app/test/fixtures/files/artist1_album2.mp3',
      '/app/test/fixtures/files/artist2_album3.wav',
      '/app/test/fixtures/files/artist1_album1.m4a'
    ]

    Setting.media_path = Rails.root.join('test', 'fixtures', 'files')

    MediaFile.file_paths.each do |file_path|
      assert_includes expect_file_paths, file_path
    end
  end

  test 'should ignore not supported files under media_path' do
    Setting.media_path = Rails.root.join('test', 'fixtures', 'files')

    assert_not_includes MediaFile.file_paths, '/app/test/fixtures/files/not_supported_file.txt'
  end

  test 'should raise error when media_path is not exist' do
    Setting.media_path = '/not_exist'

    assert_raises BlackCandyError::InvalidFilePath  do
      MediaFile.file_paths
    end
  end

  test 'should raise error when media_path is unreadble' do
    Dir.mkdir 'test_files'
    File.chmod(100, 'test_files')
    Setting.media_path = 'test_dir'

    begin
      assert_not File.readable? 'test_dir'
      assert_raises BlackCandyError::InvalidFilePath do
        MediaFile.file_paths
      end
    ensure
      File.chmod(770, 'test_files')
      FileUtils.remove_entry('test_files')
    end
  end

  test 'should get correct format' do
    assert_equal 'mp3', MediaFile.format(file_fixture('artist1_album2.mp3'))
    assert_equal 'flac', MediaFile.format(file_fixture('artist1_album1.flac'))
    assert_equal 'ogg', MediaFile.format(file_fixture('artist2_album3.ogg'))
    assert_equal 'wav', MediaFile.format(file_fixture('artist2_album3.wav'))
    assert_equal 'm4a', MediaFile.format(file_fixture('artist1_album1.m4a'))
  end

  test 'should get image from media file' do
    cover_image_binary = file_fixture('cover_image.jpg').read.force_encoding('BINARY').strip

    %w(artist1_album2.mp3 artist1_album1.m4a artist1_album1.flac artist2_album3.wav).each do |file|
      assert_equal cover_image_binary, MediaFile.image(file_fixture(file)).strip
    end
  end

  test 'should get tag info from mp3 file' do
    tag_info = MediaFile.send(:get_tag_info, file_fixture('artist1_album2.mp3'))

    assert_equal 'mp3_sample', tag_info[:name]
    assert_equal 'album2', tag_info[:album_name]
    assert_equal 'artist1', tag_info[:artist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:length]
  end

  test 'should get tag info from flac file' do
    tag_info = MediaFile.send(:get_tag_info, file_fixture('artist1_album1.flac'))

    assert_equal 'flac_sample', tag_info[:name]
    assert_equal 'album1', tag_info[:album_name]
    assert_equal 'artist1', tag_info[:artist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:length]
  end

  test 'should get tag info from ogg file' do
    tag_info = MediaFile.send(:get_tag_info, file_fixture('artist2_album3.ogg'))

    assert_equal 'ogg_sample', tag_info[:name]
    assert_equal 'album3', tag_info[:album_name]
    assert_equal 'artist2', tag_info[:artist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:length]
  end

  test 'should get tag info from wav file' do
    tag_info = MediaFile.send(:get_tag_info, file_fixture('artist2_album3.wav'))

    assert_equal 'wav_sample', tag_info[:name]
    assert_equal 'album3', tag_info[:album_name]
    assert_equal 'artist2', tag_info[:artist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:length]
  end

  test 'should get tag info from m4a file' do
    tag_info = MediaFile.send(:get_tag_info, file_fixture('artist1_album1.m4a'))

    assert_equal 'm4a_sample', tag_info[:name]
    assert_equal 'album1', tag_info[:album_name]
    assert_equal 'artist1', tag_info[:artist_name]
    assert_equal 1, tag_info[:tracknum]
    assert_equal 8, tag_info[:length]
  end

  test 'should get md5 hash from file' do
    assert_equal '9AmrqHK6AFRyk0dDIy60rw==', MediaFile.file_info(file_fixture('artist1_album2.mp3'))[:md5_hash]
  end

  test 'should raise error from file_info when file is not exist' do
    assert_raises do
      MediaFile.file_info('/not_exist')
    end
  end
end
