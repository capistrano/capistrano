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
        set :repo, 'git://github.com/capistrano/capistrano.git'
        set :branch, 'v3'
        server 'localhost', roles: %w{web app}, user: '#{current_user}'
        set :linked_files, %w{config/database.yml}
        set :linked_dirs, %w{bin log public/system vendor/bundle}
        }
    }

    describe 'log_revision' do
      before do
        cap 'deploy:started'
        cap 'deploy:update'
        cap 'deploy:finalize'
        cap 'deploy:finished'
      end

      it 'writes the log file' do
        expect(deploy_to.join('revisions.log')).to be_a_file
      end
    end
  end
end
