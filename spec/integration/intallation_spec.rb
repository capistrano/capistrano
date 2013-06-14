require 'spec_helper'

describe 'cap install' do
  let(:test_app_path) { Pathname.new('/tmp/test_app') }
  let(:path_to_cap) { File.expand_path('.') }
  let(:gemfile) { test_app_path.join('Gemfile') }

  context 'with defaults' do
    before :all do
      FileUtils.rm_rf(test_app_path)
      FileUtils.mkdir(test_app_path)

      File.open(gemfile, 'w+') do |file|
        file.write "gem 'capistrano', path: '#{path_to_cap}'"
      end

      Dir.chdir(test_app_path) do
        %x[bundle]
        %x[bundle exec cap install]
      end
    end

    describe 'installation' do

      it 'creates config/deploy' do
        path = test_app_path.join('config/deploy')
        expect(Dir.exists?(path)).to be_true
      end

      it 'creates lib/capistrano/tasks' do
        path = test_app_path.join('lib/capistrano/tasks')
        expect(Dir.exists?(path)).to be_true
      end

      it 'creates the deploy file' do
        file = test_app_path.join('config/deploy.rb')
        expect(File.exists?(file)).to be_true
      end

      it 'creates the stage files' do
        staging = test_app_path.join('config/deploy/staging.rb')
        production = test_app_path.join('config/deploy/production.rb')
        expect(File.exists?(staging)).to be_true
        expect(File.exists?(production)).to be_true
      end

    end
  end

  context 'with STAGES' do
    before :all do
      FileUtils.rm_rf(test_app_path)
      FileUtils.mkdir(test_app_path)

      File.open(gemfile, 'w+') do |file|
        file.write "gem 'capistrano', path: '#{path_to_cap}'"
      end

      Dir.chdir(test_app_path) do
        %x[bundle]
        %x[bundle exec cap install STAGES=qa,production]
      end
    end

    describe 'installation' do

      it 'creates config/deploy' do
        path = test_app_path.join('config/deploy')
        expect(Dir.exists?(path)).to be_true
      end

      it 'creates lib/capistrano/tasks' do
        path = test_app_path.join('lib/capistrano/tasks')
        expect(Dir.exists?(path)).to be_true
      end

      it 'creates the deploy file' do
        file = test_app_path.join('config/deploy.rb')
        expect(File.exists?(file)).to be_true
      end

      it 'creates the stage files' do
        qa = test_app_path.join('config/deploy/qa.rb')
        production = test_app_path.join('config/deploy/production.rb')
        staging = test_app_path.join('config/deploy/staging.rb')
        expect(File.exists?(qa)).to be_true
        expect(File.exists?(production)).to be_true
        expect(File.exists?(staging)).to be_false
      end

    end
  end

end
