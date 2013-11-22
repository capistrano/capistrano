require 'spec_helper'

describe Capistrano::DSL do

  let(:dsl) { Class.new.extend Capistrano::DSL }

  before do
    Capistrano::Configuration.reset!
  end

  describe 'setting and fetching hosts' do
    describe 'when defining a host using the `server` syntax' do
      before do
        dsl.server 'example1.com', roles: %w{web}, active: true
        dsl.server 'example2.com', roles: %w{web}
        dsl.server 'example3.com', roles: %w{app web}, active: true
        dsl.server 'example4.com', roles: %w{app}, primary: true
        dsl.server 'example5.com', roles: %w{db}, no_release: true
      end

      describe 'fetching all servers' do
        subject { dsl.roles(:all) }

        it 'returns all servers' do
          expect(subject.map(&:hostname)).to eq %w{example1.com example2.com example3.com example4.com example5.com}
        end
      end

      describe 'fetching all release servers' do

        context 'with no additional options' do
          subject { dsl.release_roles(:all) }

          it 'returns all release servers' do
            expect(subject.map(&:hostname)).to eq %w{example1.com example2.com example3.com example4.com}
          end
        end

        context 'with filter options' do
          subject { dsl.release_roles(:all, filter: :active) }

          it 'returns all release servers that match the filter' do
            expect(subject.map(&:hostname)).to eq %w{example1.com example3.com}
          end
        end
      end

      describe 'fetching servers by multiple roles' do
        it "does not confuse the last role with options" do
          expect(dsl.roles(:app, :web).count).to eq 4
          expect(dsl.roles(:app, :web, filter: :active).count).to eq 2
        end
      end

      describe 'fetching servers by role' do
        subject { dsl.roles(:app) }

        it 'returns the servers' do
          expect(subject.map(&:hostname)).to eq %w{example3.com example4.com}
        end
      end

      describe 'fetching servers by an array of roles' do
        subject { dsl.roles([:app]) }

        it 'returns the servers' do
          expect(subject.map(&:hostname)).to eq %w{example3.com example4.com}
        end
      end

      describe 'fetching filtered servers by role' do
        subject { dsl.roles(:app, filter: :active) }

        it 'returns the servers' do
          expect(subject.map(&:hostname)).to eq %w{example3.com}
        end
      end

      describe 'fetching selected servers by role' do
        subject { dsl.roles(:app, select: :active) }

        it 'returns the servers' do
          expect(subject.map(&:hostname)).to eq %w{example3.com}
        end
      end

      describe 'fetching the primary server by role' do
        context 'when inferring primary status based on order' do
          subject { dsl.primary(:web) }
          it 'returns the servers' do
            expect(subject.hostname).to eq 'example1.com'
          end
        end

        context 'when the attribute `primary` is explicity set' do
          subject { dsl.primary(:app) }
          it 'returns the servers' do
            expect(subject.hostname).to eq 'example4.com'
          end
        end
      end

    end

    describe 'when defining role with reserved name' do
      it 'fails with ArgumentError' do
        expect {
          dsl.role :all, %w{example1.com}
        }.to raise_error(ArgumentError, "all reserved name for role. Please choose another name")
      end
    end

    describe 'when defining hosts using the `role` syntax' do
      before do
        dsl.role :web, %w{example1.com example2.com example3.com}
        dsl.role :web, %w{example1.com}, active: true
        dsl.role :app, %w{example3.com example4.com}
        dsl.role :app, %w{example3.com}, active: true
        dsl.role :app, %w{example4.com}, primary: true
        dsl.role :db, %w{example5.com}, no_release: true
      end

      describe 'fetching all servers' do
        subject { dsl.roles(:all) }

        it 'returns all servers' do
          expect(subject.map(&:hostname)).to eq %w{example1.com example2.com example3.com example4.com example5.com}
        end
      end

      describe 'fetching all release servers' do

        context 'with no additional options' do
          subject { dsl.release_roles(:all) }

          it 'returns all release servers' do
            expect(subject.map(&:hostname)).to eq %w{example1.com example2.com example3.com example4.com}
          end
        end

        context 'with filter options' do
          subject { dsl.release_roles(:all, filter: :active) }

          it 'returns all release servers that match the filter' do
            expect(subject.map(&:hostname)).to eq %w{example1.com example3.com}
          end
        end
      end


      describe 'fetching servers by role' do
        subject { dsl.roles(:app) }

        it 'returns the servers' do
          expect(subject.map(&:hostname)).to eq %w{example3.com example4.com}
        end
      end

      describe 'fetching servers by an array of roles' do
        subject { dsl.roles([:app]) }

        it 'returns the servers' do
          expect(subject.map(&:hostname)).to eq %w{example3.com example4.com}
        end
      end

      describe 'fetching filtered servers by role' do
        subject { dsl.roles(:app, filter: :active) }

        it 'returns the servers' do
          expect(subject.map(&:hostname)).to eq %w{example3.com}
        end
      end

      describe 'fetching selected servers by role' do
        subject { dsl.roles(:app, select: :active) }

        it 'returns the servers' do
          expect(subject.map(&:hostname)).to eq %w{example3.com}
        end
      end

      describe 'fetching the primary server by role' do
        context 'when inferring primary status based on order' do
          subject { dsl.primary(:web) }
          it 'returns the servers' do
            expect(subject.hostname).to eq 'example1.com'
          end
        end

        context 'when the attribute `primary` is explicity set' do
          subject { dsl.primary(:app) }
          it 'returns the servers' do
            expect(subject.hostname).to eq 'example4.com'
          end
        end
      end

    end

    describe 'when defining a host using a combination of the `server` and `role` syntax' do

      before do
        dsl.server 'example1.com:1234', roles: %w{web}, active: true
        dsl.server 'example1.com:5678', roles: %w{web}, active: true
        dsl.role :app, %w{example1.com:5678}
      end

      describe 'fetching all servers' do
        subject { dsl.roles(:all).map { |server| "#{server.hostname}:#{server.port}" } }

        it 'creates a server instance for each unique host:port combination' do
          expect(subject).to eq %w{example1.com:1234 example1.com:5678}
        end
      end

      describe 'fetching servers for a role' do
        it 'roles defined using the `server` syntax are included' do
          expect(dsl.roles(:web)).to have(2).items
        end

        it 'roles defined using the `role` syntax are included' do
          expect(dsl.roles(:app)).to have(1).items
        end
      end

    end

  end

  describe 'setting and fetching variables' do

    before do
      dsl.set :scm, :git
    end

    context 'without a default' do
      context 'when the variables is defined' do
        it 'returns the variable' do
          expect(dsl.fetch(:scm)).to eq :git
        end
      end

      context 'when the variables is undefined' do
        it 'returns nil' do
          expect(dsl.fetch(:source_control)).to be_nil
        end
      end
    end

    context 'with a default' do
      context 'when the variables is defined' do
        it 'returns the variable' do
          expect(dsl.fetch(:scm, :svn)).to eq :git
        end
      end

      context 'when the variables is undefined' do
        it 'returns the default' do
          expect(dsl.fetch(:source_control, :svn)).to eq :svn
        end
      end
    end

    context 'with a block' do
      context 'when the variables is defined' do
        it 'returns the variable' do
          expect(dsl.fetch(:scm) { :svn }).to eq :git
        end
      end

      context 'when the variables is undefined' do
        it 'calls the block' do
          expect(dsl.fetch(:source_control) { :svn }).to eq :svn
        end
      end
    end

  end

  describe 'asking for a variable' do
    before do
      dsl.ask(:scm, :svn)
      $stdout.stubs(:puts)
    end

    context 'variable is provided' do
      before do
        $stdin.expects(:gets).returns('git')
      end

      it 'sets the input as the variable' do
        expect(dsl.fetch(:scm)).to eq 'git'
      end
    end

    context 'variable is not provided' do
      before do
        $stdin.expects(:gets).returns('')
      end

      it 'sets the variable as the default' do
        expect(dsl.fetch(:scm)).to eq :svn
      end
    end
  end

  describe 'checking for presence' do
    subject { dsl.any? :linked_files }

    before do
      dsl.set(:linked_files, linked_files)
    end

    context 'variable is an non-empty array' do
      let(:linked_files) { %w{1} }

      it { should be_true }
    end

    context 'variable is an empty array' do
      let(:linked_files) { [] }
      it { should be_false }
    end

    context 'variable exists, is not an array' do
      let(:linked_files) { stub }
      it { should be_true }
    end

    context 'variable is nil' do
      let(:linked_files) { nil }
      it { should be_false }
    end
  end

  describe 'configuration SSHKit' do
    let(:config) { SSHKit.config }
    let(:backend) { SSHKit.config.backend.config }
    let(:default_env) { { rails_env: :production } }

    before do
      dsl.set(:format, :dot)
      dsl.set(:log_level, :debug)
      dsl.set(:default_env, default_env)
      dsl.set(:pty, true)
      dsl.set(:connection_timeout, 10)
      dsl.set(:ssh_options, {
        keys: %w(/home/user/.ssh/id_rsa),
        forward_agent: false,
        auth_methods: %w(publickey password)
      })
      dsl.configure_backend
    end

    it 'sets the output' do
      expect(config.output).to be_a SSHKit::Formatter::Dot
    end

    it 'sets the output verbosity' do
      expect(config.output_verbosity).to eq 0
    end

    it 'sets the default env' do
      expect(config.default_env).to eq default_env
    end

    it 'sets the backend pty' do
      expect(backend.pty).to be_true
    end

    it 'sets the backend connection timeout' do
      expect(backend.connection_timeout).to eq 10
    end

    it 'sets the backend ssh_options' do
      expect(backend.ssh_options[:keys]).to eq %w(/home/user/.ssh/id_rsa)
      expect(backend.ssh_options[:forward_agent]).to eq false
      expect(backend.ssh_options[:auth_methods]).to eq %w(publickey password)
    end

  end

  describe 'release path' do

    before do
      dsl.set(:deploy_to, '/var/www')
    end

    describe 'fetching release path' do
      subject { dsl.release_path }

      context 'where no release path has been set' do
        before do
          dsl.delete(:release_path)
        end

        it 'returns the `current_path` value' do
          expect(subject.to_s).to eq '/var/www/current'
        end
      end

      context 'where the release path has been set' do
        before do
          dsl.set(:release_path, '/var/www/release_path')
        end

        it 'returns the set `release_path` value' do
          expect(subject.to_s).to eq '/var/www/release_path'
        end
      end
    end

    describe 'setting release path' do
      let(:now) { Time.parse("Oct 21 16:29:00 2015") }
      subject { dsl.release_path }

      context 'without a timestamp' do
        before do
          dsl.env.expects(:timestamp).returns(now)
          dsl.set_release_path
        end

        it 'returns the release path with the current env timestamp' do
          expect(subject.to_s).to eq '/var/www/releases/20151021162900'
        end
      end

      context 'with a timestamp' do
        before do
          dsl.set_release_path('timestamp')
        end

        it 'returns the release path with the timestamp' do
          expect(subject.to_s).to eq '/var/www/releases/timestamp'
        end
      end
    end

    describe 'setting deploy configuration path' do
      subject { dsl.deploy_config_path.to_s }

      context 'where no config path is set' do
        before do
          dsl.delete(:deploy_config_path)
        end

        it 'returns "config/deploy.rb"' do
          expect(subject).to eq 'config/deploy.rb'
        end
      end

      context 'where a custom path is set' do
        before do
          dsl.set(:deploy_config_path, 'my/custom/path.rb')
        end

        it 'returns the custom path' do
          expect(subject).to eq 'my/custom/path.rb'
        end
      end
    end

    describe 'setting stage configuration path' do
      subject { dsl.stage_config_path.to_s }

      context 'where no config path is set' do

        before do
          dsl.delete(:stage_config_path)
        end

        it 'returns "config/deploy"' do
          expect(subject).to eq 'config/deploy'
        end
      end

      context 'where a custom path is set' do
        before do
          dsl.set(:stage_config_path, 'my/custom/path')
        end

        it 'returns the custom path' do
          expect(subject).to eq 'my/custom/path'
        end
      end
    end
  end
end
