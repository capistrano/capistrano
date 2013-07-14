require 'integration_spec_helper'

describe 'cap deploy:updating', slow: true do
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
        create_shared_directory('config')
        create_shared_file('config/database.yml')
        cap 'deploy:symlink:shared'
      end

      describe 'linked_dirs' do
        it 'symlinks the directories in shared to `current`' do
          %w{bin log public/system vendor/bundle}.each do |dir|
            expect(release_path.join(dir)).to be_a_symlink_to shared_path.join(dir)
          end
        end
      end

      describe 'linked_files' do
        it 'symlinks the files in shared to `current`' do
          file = 'config/database.yml'
          expect(release_path.join(file)).to be_a_symlink_to shared_path.join(file)
        end
      end
    end
  end
end
