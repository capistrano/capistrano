require 'spec_helper'

module Capistrano
  module DSL

    class DummyPaths
      include Paths
    end

    describe Paths do
      let(:paths) { DummyPaths.new }
      let(:parent) { Pathname.new('/var/shared') }

      let(:linked_dirs) { %w{log public/system} }
      let(:linked_files) { %w{config/database.yml log/my.log} }


      describe '#linked_dirs' do
        subject { paths.linked_dirs(parent) }

        before do
          paths.expects(:fetch).with(:linked_dirs).returns(linked_dirs)
        end

        it 'returns the full pathnames' do
          expect(subject).to eq [Pathname.new('/var/shared/log'), Pathname.new('/var/shared/public/system')]
        end
      end


      describe '#linked_files' do
        subject { paths.linked_files(parent) }

        before do
          paths.expects(:fetch).with(:linked_files).returns(linked_files)
        end

        it 'returns the full pathnames' do
          expect(subject).to eq [Pathname.new('/var/shared/config/database.yml'), Pathname.new('/var/shared/log/my.log')]
        end
      end

      describe '#linked_file_dirs' do
        subject { paths.linked_file_dirs(parent) }

        before do
          paths.expects(:fetch).with(:linked_files).returns(linked_files)
        end

        it 'returns the full paths names of the parent dirs' do
          expect(subject).to eq [Pathname.new('/var/shared/config'), Pathname.new('/var/shared/log')]
        end
      end

      describe '#linked_dir_parents' do
        subject { paths.linked_dir_parents(parent) }

        before do
          paths.expects(:fetch).with(:linked_dirs).returns(linked_dirs)
        end

        it 'returns the full paths names of the parent dirs' do
          expect(subject).to eq [Pathname.new('/var/shared'), Pathname.new('/var/shared/public')]
        end
      end

    end
  end
end
