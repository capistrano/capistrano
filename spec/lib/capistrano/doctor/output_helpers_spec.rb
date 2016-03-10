require "spec_helper"
require "capistrano/doctor/output_helpers"

module Capistrano
  module Doctor
    describe OutputHelpers do
      include OutputHelpers

      # Force color for the purpose of these tests
      before { ENV.stubs(:[]).with("SSHKIT_COLOR").returns("1") }

      it "prints titles in blue with newlines and without indentation" do
        expect { title("Hello!") }.to\
          output("\e[0;34;49m\nHello!\n\e[0m\n").to_stdout
      end

      it "prints warnings in yellow with 4-space indentation" do
        expect { warning("Yikes!") }.to\
          output("    \e[0;33;49mYikes!\e[0m\n").to_stdout
      end

      it "overrides puts to indent 4 spaces per line" do
        expect { puts("one\ntwo") }.to output("    one\n    two\n").to_stdout
      end

      it "formats tables with indent, aligned columns and per-row color" do
        data = [
          ["one", ".", "1"],
          ["two", "..", "2"],
          ["three", "...", "3"]
        ]
        block = proc do |record, row|
          row.yellow if record.first == "two"
          row << record[0]
          row << record[1]
          row << record[2]
        end
        expected_output = <<-OUT
    one   .   1
    \e[0;33;49mtwo   ..  2\e[0m
    three ... 3
        OUT
        expect { table(data, &block) }.to output(expected_output).to_stdout
      end
    end
  end
end
