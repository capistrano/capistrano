require "spec_helper"

describe Capistrano::DSL do
  let(:dsl) { Class.new.extend Capistrano::DSL }

  before do
    Capistrano::Configuration.reset!
  end

  describe "setting and fetching hosts" do
    describe "when defining a host using the `server` syntax" do
      before do
        dsl.server "example1.com", roles: %w{web}, active: true
        dsl.server "example2.com", roles: %w{web}
        dsl.server "example3.com", roles: %w{app web}, active: true
        dsl.server "example4.com", roles: %w{app}, primary: true
        dsl.server "example5.com", roles: %w{db}, no_release: true, active: true
      end

      describe "fetching all servers" do
        subject { dsl.roles(:all) }

        it "returns all servers" do
          expect(subject.map(&:hostname)).to eq %w{example1.com example2.com example3.com example4.com example5.com}
        end
      end

      describe "fetching all release servers" do
        context "with no additional options" do
          subject { dsl.release_roles(:all) }

          it "returns all release servers" do
            expect(subject.map(&:hostname)).to eq %w{example1.com example2.com example3.com example4.com}
          end
        end

        context "with property filter options" do
          subject { dsl.release_roles(:all, filter: :active) }

          it "returns all release servers that match the property filter" do
            expect(subject.map(&:hostname)).to eq %w{example1.com example3.com}
          end
        end
      end

      describe "fetching servers by multiple roles" do
        it "does not confuse the last role with options" do
          expect(dsl.roles(:app, :web).count).to eq 4
          expect(dsl.roles(:app, :web, filter: :active).count).to eq 2
        end
      end

      describe "fetching servers by role" do
        subject { dsl.roles(:app) }

        it "returns the servers" do
          expect(subject.map(&:hostname)).to eq %w{example3.com example4.com}
        end
      end

      describe "fetching servers by an array of roles" do
        subject { dsl.roles([:app]) }

        it "returns the servers" do
          expect(subject.map(&:hostname)).to eq %w{example3.com example4.com}
        end
      end

      describe "fetching filtered servers by role" do
        subject { dsl.roles(:app, filter: :active) }

        it "returns the servers" do
          expect(subject.map(&:hostname)).to eq %w{example3.com}
        end
      end

      describe "fetching selected servers by role" do
        subject { dsl.roles(:app, select: :active) }

        it "returns the servers" do
          expect(subject.map(&:hostname)).to eq %w{example3.com}
        end
      end

      describe "fetching the primary server by role" do
        context "when inferring primary status based on order" do
          subject { dsl.primary(:web) }
          it "returns the servers" do
            expect(subject.hostname).to eq "example1.com"
          end
        end

        context "when the attribute `primary` is explicitly set" do
          subject { dsl.primary(:app) }
          it "returns the servers" do
            expect(subject.hostname).to eq "example4.com"
          end
        end
      end

      describe "setting an internal host filter" do
        subject { dsl.roles(:app) }
        it "is ignored" do
          dsl.set :filter, host: "example3.com"
          expect(subject.map(&:hostname)).to eq(["example3.com", "example4.com"])
        end
      end

      describe "setting an internal role filter" do
        subject { dsl.roles(:app) }
        it "ignores it" do
          dsl.set :filter, role: :web
          expect(subject.map(&:hostname)).to eq(["example3.com", "example4.com"])
        end
      end

      describe "setting an internal host and role filter" do
        subject { dsl.roles(:app) }
        it "ignores it" do
          dsl.set :filter, role: :web, host: "example1.com"
          expect(subject.map(&:hostname)).to eq(["example3.com", "example4.com"])
        end
      end

      describe "setting an internal regexp host filter" do
        subject { dsl.roles(:all) }
        it "is ignored" do
          dsl.set :filter, host: /1/
          expect(subject.map(&:hostname)).to eq(%w{example1.com example2.com example3.com example4.com example5.com})
        end
      end

      describe "setting an internal hosts filter" do
        subject { dsl.roles(:app) }
        it "is ignored" do
          dsl.set :filter, hosts: "example3.com"
          expect(subject.map(&:hostname)).to eq(["example3.com", "example4.com"])
        end
      end

      describe "setting an internal roles filter" do
        subject { dsl.roles(:app) }
        it "ignores it" do
          dsl.set :filter, roles: :web
          expect(subject.map(&:hostname)).to eq(["example3.com", "example4.com"])
        end
      end

      describe "setting an internal hosts and roles filter" do
        subject { dsl.roles(:app) }
        it "ignores it" do
          dsl.set :filter, roles: :web, hosts: "example1.com"
          expect(subject.map(&:hostname)).to eq(["example3.com", "example4.com"])
        end
      end

      describe "setting an internal regexp hosts filter" do
        subject { dsl.roles(:all) }
        it "is ignored" do
          dsl.set :filter, hosts: /1/
          expect(subject.map(&:hostname)).to eq(%w{example1.com example2.com example3.com example4.com example5.com})
        end
      end
    end

    describe "when defining role with reserved name" do
      it "fails with ArgumentError" do
        expect do
          dsl.role :all, %w{example1.com}
        end.to raise_error(ArgumentError, "all reserved name for role. Please choose another name")
      end
    end

    describe "when defining hosts using the `role` syntax" do
      before do
        dsl.role :web, %w{example1.com example2.com example3.com}
        dsl.role :web, %w{example1.com}, active: true
        dsl.role :app, %w{example3.com example4.com}
        dsl.role :app, %w{example3.com}, active: true
        dsl.role :app, %w{example4.com}, primary: true
        dsl.role :db, %w{example5.com}, no_release: true
      end

      describe "fetching all servers" do
        subject { dsl.roles(:all) }

        it "returns all servers" do
          expect(subject.map(&:hostname)).to eq %w{example1.com example2.com example3.com example4.com example5.com}
        end
      end

      describe "fetching all release servers" do
        context "with no additional options" do
          subject { dsl.release_roles(:all) }

          it "returns all release servers" do
            expect(subject.map(&:hostname)).to eq %w{example1.com example2.com example3.com example4.com}
          end
        end

        context "with filter options" do
          subject { dsl.release_roles(:all, filter: :active) }

          it "returns all release servers that match the filter" do
            expect(subject.map(&:hostname)).to eq %w{example1.com example3.com}
          end
        end
      end

      describe "fetching servers by role" do
        subject { dsl.roles(:app) }

        it "returns the servers" do
          expect(subject.map(&:hostname)).to eq %w{example3.com example4.com}
        end
      end

      describe "fetching servers by an array of roles" do
        subject { dsl.roles([:app]) }

        it "returns the servers" do
          expect(subject.map(&:hostname)).to eq %w{example3.com example4.com}
        end
      end

      describe "fetching filtered servers by role" do
        subject { dsl.roles(:app, filter: :active) }

        it "returns the servers" do
          expect(subject.map(&:hostname)).to eq %w{example3.com}
        end
      end

      describe "fetching selected servers by role" do
        subject { dsl.roles(:app, select: :active) }

        it "returns the servers" do
          expect(subject.map(&:hostname)).to eq %w{example3.com}
        end
      end

      describe "fetching the primary server by role" do
        context "when inferring primary status based on order" do
          subject { dsl.primary(:web) }
          it "returns the servers" do
            expect(subject.hostname).to eq "example1.com"
          end
        end

        context "when the attribute `primary` is explicitly set" do
          subject { dsl.primary(:app) }
          it "returns the servers" do
            expect(subject.hostname).to eq "example4.com"
          end
        end
      end
    end

    describe "when defining a host using a combination of the `server` and `role` syntax" do
      before do
        dsl.server "db@example1.com:1234", roles: %w{db}, active: true
        dsl.server "root@example1.com:1234", roles: %w{web}, active: true
        dsl.server "example1.com:5678", roles: %w{web}, active: true
        dsl.role :app, %w{deployer@example1.com:1234}
        dsl.role :app, %w{example1.com:5678}
      end

      describe "fetching all servers" do
        it "creates one server per hostname, ignoring user combinations" do
          expect(dsl.roles(:all).size).to eq(2)
        end
      end

      describe "fetching servers for a role" do
        it "roles defined using the `server` syntax are included" do
          as = dsl.roles(:web).map { |server| "#{server.user}@#{server.hostname}:#{server.port}" }
          expect(as.size).to eq(2)
          expect(as[0]).to eq("deployer@example1.com:1234")
          expect(as[1]).to eq("@example1.com:5678")
        end

        it "roles defined using the `role` syntax are included" do
          as = dsl.roles(:app).map { |server| "#{server.user}@#{server.hostname}:#{server.port}" }
          expect(as.size).to eq(2)
          expect(as[0]).to eq("deployer@example1.com:1234")
          expect(as[1]).to eq("@example1.com:5678")
        end
      end
    end

    describe "when setting user and port" do
      subject { dsl.roles(:all).map { |server| "#{server.user}@#{server.hostname}:#{server.port}" }.first }

      describe "using the :user property" do
        it "takes precedence over in the host string" do
          dsl.server "db@example1.com:1234", roles: %w{db}, active: true, user: "brian"
          expect(subject).to eq("brian@example1.com:1234")
        end
      end

      describe "using the :port property" do
        it "takes precedence over in the host string" do
          dsl.server "db@example1.com:9090", roles: %w{db}, active: true, port: 1234
          expect(subject).to eq("db@example1.com:1234")
        end
      end
    end
  end

  describe "setting and fetching variables" do
    before do
      dsl.set :scm, :git
    end

    context "without a default" do
      context "when the variables is defined" do
        it "returns the variable" do
          expect(dsl.fetch(:scm)).to eq :git
        end
      end

      context "when the variables is undefined" do
        it "returns nil" do
          expect(dsl.fetch(:source_control)).to be_nil
        end
      end
    end

    context "with a default" do
      context "when the variables is defined" do
        it "returns the variable" do
          expect(dsl.fetch(:scm, :svn)).to eq :git
        end
      end

      context "when the variables is undefined" do
        it "returns the default" do
          expect(dsl.fetch(:source_control, :svn)).to eq :svn
        end
      end
    end

    context "with a block" do
      context "when the variables is defined" do
        it "returns the variable" do
          expect(dsl.fetch(:scm) { :svn }).to eq :git
        end
      end

      context "when the variables is undefined" do
        it "calls the block" do
          expect(dsl.fetch(:source_control) { :svn }).to eq :svn
        end
      end
    end
  end

  describe "asking for a variable" do
    let(:stdin) { stub(tty?: true) }

    before do
      dsl.ask(:scm, :svn, stdin: stdin)
      $stdout.stubs(:print)
    end

    context "variable is provided" do
      before do
        stdin.expects(:gets).returns("git")
      end

      it "sets the input as the variable" do
        expect(dsl.fetch(:scm)).to eq "git"
      end
    end

    context "variable is not provided" do
      before do
        stdin.expects(:gets).returns("")
      end

      it "sets the variable as the default" do
        expect(dsl.fetch(:scm)).to eq :svn
      end
    end
  end

  describe "checking for presence" do
    subject { dsl.any? :linked_files }

    before do
      dsl.set(:linked_files, linked_files)
    end

    context "variable is an non-empty array" do
      let(:linked_files) { %w{1} }

      it { expect(subject).to be_truthy }
    end

    context "variable is an empty array" do
      let(:linked_files) { [] }
      it { expect(subject).to be_falsey }
    end

    context "variable exists, is not an array" do
      let(:linked_files) { stub }
      it { expect(subject).to be_truthy }
    end

    context "variable is nil" do
      let(:linked_files) { nil }
      it { expect(subject).to be_falsey }
    end
  end

  describe "configuration SSHKit" do
    let(:config) { SSHKit.config }
    let(:backend) { SSHKit.config.backend.config }
    let(:default_env) { { rails_env: :production } }

    before do
      dsl.set(:format, :dot)
      dsl.set(:log_level, :debug)
      dsl.set(:default_env, default_env)
      dsl.set(:pty, true)
      dsl.set(:connection_timeout, 10)
      dsl.set(:ssh_options, keys: %w(/home/user/.ssh/id_rsa),
                            forward_agent: false,
                            auth_methods: %w(publickey password))
      dsl.configure_backend
    end

    it "sets the output" do
      expect(config.output).to be_a SSHKit::Formatter::Dot
    end

    it "sets the output verbosity" do
      expect(config.output_verbosity).to eq 0
    end

    it "sets the default env" do
      expect(config.default_env).to eq default_env
    end

    it "sets the backend pty" do
      expect(backend.pty).to be_truthy
    end

    it "sets the backend connection timeout" do
      expect(backend.connection_timeout).to eq 10
    end

    it "sets the backend ssh_options" do
      expect(backend.ssh_options[:keys]).to eq %w(/home/user/.ssh/id_rsa)
      expect(backend.ssh_options[:forward_agent]).to eq false
      expect(backend.ssh_options[:auth_methods]).to eq %w(publickey password)
    end
  end

  describe "on()" do
    describe "when passed server objects" do
      before do
        dsl.server "example1.com", roles: %w{web}, active: true
        dsl.server "example2.com", roles: %w{web}
        dsl.server "example3.com", roles: %w{app web}, active: true
        dsl.server "example4.com", roles: %w{app}, primary: true
        dsl.server "example5.com", roles: %w{db}, no_release: true
        @coordinator = mock("coordinator")
        @coordinator.expects(:each).returns(nil)
        ENV.delete "ROLES"
        ENV.delete "HOSTS"
      end

      it "filters by role from the :filter variable" do
        hosts = dsl.roles(:web)
        all = dsl.roles(:all)
        SSHKit::Coordinator.expects(:new).with(hosts).returns(@coordinator)
        dsl.set :filter, role: "web"
        dsl.on(all)
      end

      it "filters by host and role from the :filter variable" do
        all = dsl.roles(:all)
        SSHKit::Coordinator.expects(:new).with([]).returns(@coordinator)
        dsl.set :filter, role: "db", host: "example3.com"
        dsl.on(all)
      end

      it "filters by roles from the :filter variable" do
        hosts = dsl.roles(:web)
        all = dsl.roles(:all)
        SSHKit::Coordinator.expects(:new).with(hosts).returns(@coordinator)
        dsl.set :filter, roles: "web"
        dsl.on(all)
      end

      it "filters by hosts and roles from the :filter variable" do
        all = dsl.roles(:all)
        SSHKit::Coordinator.expects(:new).with([]).returns(@coordinator)
        dsl.set :filter, roles: "db", hosts: "example3.com"
        dsl.on(all)
      end

      it "filters from ENV[ROLES]" do
        hosts = dsl.roles(:db)
        all = dsl.roles(:all)
        SSHKit::Coordinator.expects(:new).with(hosts).returns(@coordinator)
        ENV["ROLES"] = "db"
        dsl.on(all)
      end

      it "filters from ENV[HOSTS]" do
        hosts = dsl.roles(:db)
        all = dsl.roles(:all)
        SSHKit::Coordinator.expects(:new).with(hosts).returns(@coordinator)
        ENV["HOSTS"] = "example5.com"
        dsl.on(all)
      end

      it "filters by ENV[HOSTS] && ENV[ROLES]" do
        all = dsl.roles(:all)
        SSHKit::Coordinator.expects(:new).with([]).returns(@coordinator)
        ENV["HOSTS"] = "example5.com"
        ENV["ROLES"] = "web"
        dsl.on(all)
      end
    end

    describe "when passed server literal names" do
      before do
        ENV.delete "ROLES"
        ENV.delete "HOSTS"
        @coordinator = mock("coordinator")
        @coordinator.expects(:each).returns(nil)
      end

      it "selects nothing when a role filter is present" do
        dsl.set :filter, role: "web"
        SSHKit::Coordinator.expects(:new).with([]).returns(@coordinator)
        dsl.on("my.server")
      end

      it "selects using the string when a host filter is present" do
        dsl.set :filter, host: "server.local"
        SSHKit::Coordinator.expects(:new).with(["server.local"]).returns(@coordinator)
        dsl.on("server.local")
      end

      it "doesn't select when a host filter is present that doesn't match" do
        dsl.set :filter, host: "ruby.local"
        SSHKit::Coordinator.expects(:new).with([]).returns(@coordinator)
        dsl.on("server.local")
      end

      it "selects nothing when a roles filter is present" do
        dsl.set :filter, roles: "web"
        SSHKit::Coordinator.expects(:new).with([]).returns(@coordinator)
        dsl.on("my.server")
      end

      it "selects using the string when a hosts filter is present" do
        dsl.set :filter, hosts: "server.local"
        SSHKit::Coordinator.expects(:new).with(["server.local"]).returns(@coordinator)
        dsl.on("server.local")
      end

      it "doesn't select when a hosts filter is present that doesn't match" do
        dsl.set :filter, hosts: "ruby.local"
        SSHKit::Coordinator.expects(:new).with([]).returns(@coordinator)
        dsl.on("server.local")
      end
    end
  end

  describe "role_properties()" do
    before do
      dsl.role :redis, %w[example1.com example2.com], redis: { port: 6379, type: :slave }
      dsl.server "example1.com", roles: %w{web}, active: true, web: { port: 80 }
      dsl.server "example2.com", roles: %w{web redis}, web: { port: 81 }, redis: { type: :master }
      dsl.server "example3.com", roles: %w{app}, primary: true
    end

    it "retrieves properties for a single role as a set" do
      rps = dsl.role_properties(:app)
      expect(rps).to eq(Set[{ hostname: "example3.com", role: :app }])
    end

    it "retrieves properties for multiple roles as a set" do
      rps = dsl.role_properties(:app, :web)
      expect(rps).to eq(Set[{ hostname: "example3.com", role: :app }, { hostname: "example1.com", role: :web, port: 80 }, { hostname: "example2.com", role: :web, port: 81 }])
    end

    it "yields the properties for a single role" do
      recipient = mock("recipient")
      recipient.expects(:doit).with("example1.com", :redis, port: 6379, type: :slave)
      recipient.expects(:doit).with("example2.com", :redis, port: 6379, type: :master)
      dsl.role_properties(:redis) do |host, role, props|
        recipient.doit(host, role, props)
      end
    end

    it "yields the properties for multiple roles" do
      recipient = mock("recipient")
      recipient.expects(:doit).with("example1.com", :redis, port: 6379, type: :slave)
      recipient.expects(:doit).with("example2.com", :redis, port: 6379, type: :master)
      recipient.expects(:doit).with("example3.com", :app, nil)
      dsl.role_properties(:redis, :app) do |host, role, props|
        recipient.doit(host, role, props)
      end
    end

    it "yields the merged properties for multiple roles" do
      recipient = mock("recipient")
      recipient.expects(:doit).with("example1.com", :redis, port: 6379, type: :slave)
      recipient.expects(:doit).with("example2.com", :redis, port: 6379, type: :master)
      recipient.expects(:doit).with("example1.com", :web, port: 80)
      recipient.expects(:doit).with("example2.com", :web, port: 81)
      dsl.role_properties(:redis, :web) do |host, role, props|
        recipient.doit(host, role, props)
      end
    end

    it "honours a property filter before yielding" do
      recipient = mock("recipient")
      recipient.expects(:doit).with("example1.com", :redis, port: 6379, type: :slave)
      recipient.expects(:doit).with("example1.com", :web, port: 80)
      dsl.role_properties(:redis, :web, select: :active) do |host, role, props|
        recipient.doit(host, role, props)
      end
    end
  end
end
