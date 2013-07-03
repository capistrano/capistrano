require 'integration_spec_helper'

describe 'cap deploy:finished', slow: true do
  before do
    install_test_app_with(config)
  end

  describe 'deploy' do
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

    describe 'symlink' do
      before do
        cap 'deploy:started'
        cap 'deploy:update'
        cap 'deploy:finalize'
      end

      describe 'release' do
        it 'symlinks the release to `current`' do
          expect(File.symlink?(current_path)).to be_true
          expect(File.readlink(current_path)).to match /\/tmp\/test_app\/deploy_to\/releases\/\d{14}/
        end
      end
    end
  end
end
