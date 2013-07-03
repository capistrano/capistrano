require 'integration_spec_helper'

describe 'cap deploy:started', slow: true do
  before do
    install_test_app_with(config)
  end

  describe 'deploy:check' do
    let(:config) {
      %{
        set :stage, :#{stage}
        set :deploy_to, '#{deploy_to}'
        set :repo_url, 'git://github.com/capistrano/capistrano.git'
        set :branch, 'v3'
        server 'localhost', roles: %w{web app}, user: '#{current_user}'
        set :linked_files, %w{config/database.yml}
        set :linked_dirs, %w{bin log public/system vendor/bundle}
      }
    }

    describe 'directories' do
      before do
        cap 'deploy:check:directories'
      end

      it 'ensures the directory structure' do
        expect(shared_path).to be_a_directory
        expect(releases_path).to be_a_directory
      end
    end

    describe 'linked_dirs' do
      before do
        cap 'deploy:check:linked_dirs'
      end

      it 'ensure directories to be linked in `shared`' do
        [
          shared_path.join('bin'),
          shared_path.join('log'),
          shared_path.join('public/system'),
          shared_path.join('vendor/bundle'),
        ].each do |dir|
          expect(dir).to be_a_directory
        end
      end
    end

    describe 'linked_files' do

      subject { cap 'deploy:check:linked_files' }

      context 'file does not exist' do
        it 'fails' do
          expect(subject).to match 'config/database.yml does not exist'
        end
      end

      context 'file exists' do
        before do
          create_shared_directory('config')
          create_shared_file('config/database.yml')
        end

        it 'suceeds' do
          expect(subject).not_to match 'config/database.yml does not exist'
          expect(subject).to match 'successful'
        end

      end
    end
  end
end

