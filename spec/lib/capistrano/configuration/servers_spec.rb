require "spec_helper"

module Capistrano
  class Configuration
    describe Servers do
      let(:servers) { Servers.new }

      describe "adding a role" do
        it "adds two new server instances" do
          expect { servers.add_role(:app, %w{1 2}) }
            .to change { servers.count }.from(0).to(2)
        end

        it "handles de-duplification within roles" do
          servers.add_role(:app, %w{1})
          servers.add_role(:app, %w{1})
          expect(servers.count).to eq 1
        end

        it "handles de-duplification within roles with users" do
          servers.add_role(:app, %w{1}, user: "nick")
          servers.add_role(:app, %w{1}, user: "fred")
          expect(servers.count).to eq 1
        end

        it "accepts instances of server objects" do
          servers.add_role(:app, [Capistrano::Configuration::Server.new("example.net"), "example.com"])
          expect(servers.roles_for([:app]).length).to eq 2
        end

        it "accepts non-enumerable types" do
          servers.add_role(:app, "1")
          expect(servers.roles_for([:app]).count).to eq 1
        end

        it "creates distinct server properties" do
          servers.add_role(:db, %w{1 2}, db: { port: 1234 })
          servers.add_host("1", db: { master: true })
          expect(servers.count).to eq(2)
          expect(servers.roles_for([:db]).count).to eq 2
          expect(servers.find { |s| s.hostname == "1" }.properties.db).to eq(port: 1234, master: true)
          expect(servers.find { |s| s.hostname == "2" }.properties.db).to eq(port: 1234)
        end
      end

      describe "adding a role to an existing server" do
        before do
          servers.add_role(:web, %w{1 2})
          servers.add_role(:app, %w{1 2})
        end

        it "adds new roles to existing servers" do
          expect(servers.count).to eq 2
        end
      end

      describe "collecting server roles" do
        let(:app) { Set.new([:app]) }
        let(:web_app) { Set.new(%i(web app)) }
        let(:web) { Set.new([:web]) }

        before do
          servers.add_role(:app, %w{1 2 3})
          servers.add_role(:web, %w{2 3 4})
        end

        it "returns an array of the roles" do
          expect(servers.roles_for([:app]).collect(&:roles)).to eq [app, web_app, web_app]
          expect(servers.roles_for([:web]).collect(&:roles)).to eq [web_app, web_app, web]
        end
      end

      describe "finding the primary server" do
        after do
          Configuration.reset!
        end
        it "takes the first server if none have the primary property" do
          servers.add_role(:app, %w{1 2})
          expect(servers.fetch_primary(:app).hostname).to eq("1")
        end

        it "takes the first server with the primary have the primary flag" do
          servers.add_role(:app, %w{1 2})
          servers.add_host("2", primary: true)
          expect(servers.fetch_primary(:app).hostname).to eq("2")
        end

        it "ignores any on_filters" do
          Configuration.env.set :filter, host: "1"
          servers.add_role(:app, %w{1 2})
          servers.add_host("2", primary: true)
          expect(servers.fetch_primary(:app).hostname).to eq("2")
        end
      end

      describe "fetching servers" do
        before do
          servers.add_role(:app, %w{1 2})
          servers.add_role(:web, %w{2 3})
        end

        it "returns the correct app servers" do
          expect(servers.roles_for([:app]).map(&:hostname)).to eq %w{1 2}
        end

        it "returns the correct web servers" do
          expect(servers.roles_for([:web]).map(&:hostname)).to eq %w{2 3}
        end

        it "returns the correct app and web servers" do
          expect(servers.roles_for(%i(app web)).map(&:hostname)).to eq %w{1 2 3}
        end

        it "returns all servers" do
          expect(servers.roles_for([:all]).map(&:hostname)).to eq %w{1 2 3}
        end
      end

      describe "adding a server" do
        before do
          servers.add_host("1", roles: [:app, "web"], test: :value)
        end

        it "can create a server with properties" do
          expect(servers.roles_for([:app]).first.hostname).to eq "1"
          expect(servers.roles_for([:web]).first.hostname).to eq "1"
          expect(servers.roles_for([:all]).first.properties.test).to eq :value
          expect(servers.roles_for([:all]).first.properties.keys).to eq [:test]
        end

        it "can accept multiple servers with the same hostname but different ports or users" do
          servers.add_host("1", roles: [:app, "web"], test: :value, port: 12)
          expect(servers.count).to eq(2)
          servers.add_host("1", roles: [:app, "web"], test: :value, port: 34)
          servers.add_host("1", roles: [:app, "web"], test: :value, user: "root")
          servers.add_host("1", roles: [:app, "web"], test: :value, user: "deployer")
          servers.add_host("1", roles: [:app, "web"], test: :value, user: "root", port: 34)
          servers.add_host("1", roles: [:app, "web"], test: :value, user: "deployer", port: 34)
          servers.add_host("1", roles: [:app, "web"], test: :value, user: "deployer", port: 56)
          expect(servers.count).to eq(4)
        end

        describe "with a :user property" do
          it "sets the server ssh username" do
            servers.add_host("1", roles: [:app, "web"], user: "nick")
            expect(servers.count).to eq(1)
            expect(servers.roles_for([:all]).first.user).to eq "nick"
          end

          it "overwrites the value of a user specified in the hostname" do
            servers.add_host("brian@1", roles: [:app, "web"], user: "nick")
            expect(servers.count).to eq(1)
            expect(servers.roles_for([:all]).first.user).to eq "nick"
          end
        end

        it "overwrites the value of a previously defined scalar property" do
          servers.add_host("1", roles: [:app, "web"], test: :volatile)
          expect(servers.count).to eq(1)
          expect(servers.roles_for([:all]).first.properties.test).to eq :volatile
        end

        it "merges previously defined hash properties" do
          servers.add_host("1", roles: [:b], db: { port: 1234 })
          servers.add_host("1", roles: [:b], db: { master: true })
          expect(servers.count).to eq(1)
          expect(servers.roles_for([:b]).first.properties.db).to eq(port: 1234, master: true)
        end

        it "concatenates previously defined array properties" do
          servers.add_host("1", roles: [:b], steps: [1, 3, 5])
          servers.add_host("1", roles: [:b], steps: [1, 9])
          expect(servers.count).to eq(1)
          expect(servers.roles_for([:b]).first.properties.steps).to eq([1, 3, 5, 1, 9])
        end

        it "merges previously defined set properties" do
          servers.add_host("1", roles: [:b], endpoints: Set[123, 333])
          servers.add_host("1", roles: [:b], endpoints: Set[222, 333])
          expect(servers.count).to eq(1)
          expect(servers.roles_for([:b]).first.properties.endpoints).to eq(Set[123, 222, 333])
        end

        it "adds array property value only ones for a new host" do
          servers.add_host("2", roles: [:array_test], array_property: [1, 2])
          expect(servers.roles_for([:array_test]).first.properties.array_property).to eq [1, 2]
        end

        it "updates roles when custom user defined" do
          servers.add_host("1", roles: ["foo"], user: "custom")
          servers.add_host("1", roles: ["bar"], user: "custom")
          expect(servers.roles_for([:foo]).first.hostname).to eq "1"
          expect(servers.roles_for([:bar]).first.hostname).to eq "1"
        end

        it "updates roles when custom port defined" do
          servers.add_host("1", roles: ["foo"], port: 1234)
          servers.add_host("1", roles: ["bar"], port: 1234)
          expect(servers.roles_for([:foo]).first.hostname).to eq "1"
          expect(servers.roles_for([:bar]).first.hostname).to eq "1"
        end
      end

      describe "selecting roles" do
        before do
          servers.add_host("1", roles: :app, active: true)
          servers.add_host("2", roles: :app)
        end

        it "is empty if the filter would remove all matching hosts" do
          expect(servers.roles_for([:app, select: :inactive])).to be_empty
        end

        it "can filter hosts by properties on the host object using symbol as shorthand" do
          expect(servers.roles_for([:app, filter: :active]).length).to eq 1
        end

        it "can select hosts by properties on the host object using symbol as shorthand" do
          expect(servers.roles_for([:app, select: :active]).length).to eq 1
        end

        it "can filter hosts by properties on the host using a regular proc" do
          expect(servers.roles_for([:app, filter: ->(h) { h.properties.active }]).length).to eq 1
        end

        it "can select hosts by properties on the host using a regular proc" do
          expect(servers.roles_for([:app, select: ->(h) { h.properties.active }]).length).to eq 1
        end

        it "is empty if the regular proc filter would remove all matching hosts" do
          expect(servers.roles_for([:app, select: ->(h) { h.properties.inactive }])).to be_empty
        end
      end

      describe "excluding by property" do
        before do
          servers.add_host("1", roles: :app, active: true)
          servers.add_host("2", roles: :app, active: true, no_release: true)
        end

        it "is empty if the filter would remove all matching hosts" do
          hosts = servers.roles_for([:app, exclude: :active])
          expect(hosts.map(&:hostname)).to be_empty
        end

        it "returns the servers without the attributes specified" do
          hosts = servers.roles_for([:app, exclude: :no_release])
          expect(hosts.map(&:hostname)).to eq %w{1}
        end

        it "can exclude hosts by properties on the host using a regular proc" do
          hosts = servers.roles_for([:app, exclude: ->(h) { h.properties.no_release }])
          expect(hosts.map(&:hostname)).to eq %w{1}
        end

        it "is empty if the regular proc filter would remove all matching hosts" do
          hosts = servers.roles_for([:app, exclude: ->(h) { h.properties.active }])
          expect(hosts.map(&:hostname)).to be_empty
        end
      end

      describe "filtering roles internally" do
        before do
          servers.add_host("1", roles: :app, active: true)
          servers.add_host("2", roles: :app)
          servers.add_host("3", roles: :web)
          servers.add_host("4", roles: :web)
          servers.add_host("5", roles: :db)
        end

        subject { servers.roles_for(roles).map(&:hostname) }

        context "with the ROLES environment variable set" do
          before do
            ENV.stubs(:[]).with("ROLES").returns("web,db")
            ENV.stubs(:[]).with("HOSTS").returns(nil)
          end

          context "when selecting all roles" do
            let(:roles) { [:all] }
            it "ignores it" do
              expect(subject).to eq %w{1 2 3 4 5}
            end
          end

          context "when selecting specific roles" do
            let(:roles) { %i(app web) }
            it "ignores it" do
              expect(subject).to eq %w{1 2 3 4}
            end
          end

          context "when selecting roles not included in ROLE" do
            let(:roles) { [:app] }
            it "ignores it" do
              expect(subject).to eq %w{1 2}
            end
          end
        end

        context "with the HOSTS environment variable set" do
          before do
            ENV.stubs(:[]).with("ROLES").returns(nil)
            ENV.stubs(:[]).with("HOSTS").returns("3,5")
          end

          context "when selecting all roles" do
            let(:roles) { [:all] }
            it "ignores it" do
              expect(subject).to eq %w{1 2 3 4 5}
            end
          end

          context "when selecting specific roles" do
            let(:roles) { %i(app web) }
            it "ignores it" do
              expect(subject).to eq %w{1 2 3 4}
            end
          end

          context "when selecting no roles" do
            let(:roles) { [] }
            it "ignores it" do
              expect(subject).to be_empty
            end
          end
        end
      end
    end
  end
end
