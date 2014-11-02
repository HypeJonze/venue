require 'spec_helper'

describe ImageUploader do
  include CarrierWave::Test::Matchers

  let!(:venue) { create(:venue) }
  let!(:path_to_file) { Rails.root.join('spec', 'fixtures', 'images', '400x400.png') }

  before do
    ImageUploader.enable_processing = true
    @uploader = ImageUploader.new(venue, :logo)
  end

  after do
    ImageUploader.enable_processing = false
    @uploader.remove!
  end

  describe '#store' do
    it 'stores an image file' do
      expect(@uploader.store!(File.open(path_to_file))).to be_true
    end
  end

  describe 'image versions' do
    before do
      @uploader.store!(File.open(path_to_file))
    end

    context "thumb version" do
      it 'scales image to 64x64 pixels' do
        @uploader.thumb.should have_dimensions(64, 64)
      end
    end

    context 'portrait_small version' do
      it 'scales image to 250x350 pixels' do
        @uploader.portrait_small.should have_dimensions(250, 350)
      end
    end

    context 'portrait_large version' do
      it 'scales image to 500x700 pixels' do
        @uploader.portrait_large.should have_dimensions(500, 700)
      end
    end

    context 'square_small version' do
      it 'scales image to 200x200 pixels' do
        @uploader.square_small.should have_dimensions(200, 200)
      end
    end

    context 'square_large version' do
      it 'scales image to 400x400 pixels' do
        @uploader.square_large.should have_dimensions(400, 400)
      end
    end

    context 'landscape_small version' do
      it 'scales image to 300x150 pixels' do
        @uploader.landscape_small.should have_dimensions(300, 150)
      end
    end

    context 'landscape_large version' do
      it 'scales image to 800x400 pixels' do
        @uploader.landscape_large.should have_dimensions(800, 400)
      end
    end
  end
end