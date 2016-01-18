require "spec_helper"
require "capistrano/ext/sshkit/backend/thread_local"

module SSHKit
  module Backend
    describe "#current" do
      require "sshkit/dsl"

      it "refers to the currently executing backend" do
        backend = nil
        current = nil

        on(:local) do
          backend = self
          current = SSHKit::Backend.current
        end

        expect(current).to eq(backend)
      end

      it "is nil outside of an on block" do
        on(:local) do
          # nothing
        end

        expect(SSHKit::Backend.current).to be_nil
      end
    end
  end
end
