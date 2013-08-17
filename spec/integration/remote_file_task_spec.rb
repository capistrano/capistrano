require 'integration_spec_helper'

describe 'cap deploy:started', slow: true do
  before do
    install_test_app_with(config)
    copy_task_to_test_app('spec/support/tasks/database.cap')
  end

  let(:config) {
    %{
      set :stage, :#{stage}
      set :deploy_to, '#{deploy_to}'
      set :repo_url, 'git://github.com/capistrano/capistrano.git'
      set :branch, 'v3'
      server 'localhost', roles: %w{web app}, user: '#{current_user}'
      set :linked_files, %w{config/database.yml}
      set :linked_dirs, %w{config}
    }
  }

  describe 'linked_files' do

    before do
      cap 'deploy:check:linked_dirs'
    end

    subject { cap 'deploy:check:linked_files' }

    context 'where the file does not exist' do
      it 'creates the file with the remote_task prerequisite' do
        expect(subject).to match 'Uploading'
        expect(subject).not_to match 'config/database.yml does not exist'
        expect(subject).to match 'successful'
      end
    end

    context 'where the file already exists' do
      before do
        FileUtils.touch(shared_path.join('config/database.yml'))
      end

      it 'will not recreate the file if it already exists' do
        expect(subject).not_to match 'Uploading'
        expect(subject).not_to match 'config/database.yml does not exist'
        expect(subject).to match 'successful'
      end
    end

  end
end

