require "spec_helper"

describe Capistrano::UploadTask do
  let(:app) { Rake.application = Rake::Application.new }

  subject(:upload_task) { described_class.define_task("path/file.yml") }

  it { is_expected.to be_a(Rake::FileCreationTask) }
  it { is_expected.to be_needed }

  context "inside namespace" do
    let(:normal_task) { Rake::Task.define_task("path/other_file.yml") }

    around { |ex| app.in_namespace("namespace", &ex) }

    it { expect(upload_task.name).to eq("path/file.yml") }
    it { expect(upload_task.scope.path).to eq("namespace") }
  end
end
