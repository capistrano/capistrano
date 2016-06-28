require "spec_helper"

describe Capistrano::DSL::Paths do
  let(:dsl) { Class.new.extend Capistrano::DSL }
  let(:parent) { Pathname.new("/var/shared") }
  let(:paths) { Class.new.extend Capistrano::DSL::Paths }

  let(:linked_dirs) { %w{log public/system} }
  let(:linked_files) { %w{config/database.yml log/my.log log/access.log} }

  before do
    dsl.set(:deploy_to, "/var/www")
  end

  describe "#linked_dirs" do
    subject { paths.linked_dirs(parent) }

    before do
      paths.expects(:fetch).with(:linked_dirs).returns(linked_dirs)
    end

    it "returns the full pathnames" do
      expect(subject).to eq [
        Pathname.new("/var/shared/log"),
        Pathname.new("/var/shared/public/system")
      ]
    end
  end

  describe "#linked_files" do
    subject { paths.linked_files(parent) }

    before do
      paths.expects(:fetch).with(:linked_files).returns(linked_files)
    end

    it "returns the full pathnames" do
      expect(subject).to eq [
        Pathname.new("/var/shared/config/database.yml"),
        Pathname.new("/var/shared/log/my.log"),
        Pathname.new("/var/shared/log/access.log")
      ]
    end
  end

  describe "#linked_file_dirs" do
    subject { paths.linked_file_dirs(parent) }

    before do
      paths.expects(:fetch).with(:linked_files).returns(linked_files)
    end

    it "returns the full paths names of the parent dirs" do
      expect(subject).to eq [
        Pathname.new("/var/shared/config"),
        Pathname.new("/var/shared/log")
      ]
    end
  end

  describe "#linked_dir_parents" do
    subject { paths.linked_dir_parents(parent) }

    before do
      paths.expects(:fetch).with(:linked_dirs).returns(linked_dirs)
    end

    it "returns the full paths names of the parent dirs" do
      expect(subject).to eq [
        Pathname.new("/var/shared"),
        Pathname.new("/var/shared/public")
      ]
    end
  end

  describe "#release path" do
    subject { dsl.release_path }

    context "where no release path has been set" do
      before do
        dsl.delete(:release_path)
      end

      it "returns the `current_path` value" do
        expect(subject.to_s).to eq "/var/www/current"
      end
    end

    context "where the release path has been set" do
      before do
        dsl.set(:release_path, "/var/www/release_path")
      end

      it "returns the set `release_path` value" do
        expect(subject.to_s).to eq "/var/www/release_path"
      end
    end
  end

  describe "#set_release_path" do
    let(:now) { Time.parse("Oct 21 16:29:00 2015") }
    subject { dsl.release_path }

    context "without a timestamp" do
      before do
        dsl.env.expects(:timestamp).returns(now)
        dsl.set_release_path
      end

      it "returns the release path with the current env timestamp" do
        expect(subject.to_s).to eq "/var/www/releases/20151021162900"
      end
    end

    context "with a timestamp" do
      before do
        dsl.set_release_path("timestamp")
      end

      it "returns the release path with the timestamp" do
        expect(subject.to_s).to eq "/var/www/releases/timestamp"
      end
    end
  end

  describe "#deploy_config_path" do
    subject { dsl.deploy_config_path.to_s }

    context "when not specified" do
      before do
        dsl.delete(:deploy_config_path)
      end

      it 'returns "config/deploy.rb"' do
        expect(subject).to eq "config/deploy.rb"
      end
    end

    context "when the variable :deploy_config_path is set" do
      before do
        dsl.set(:deploy_config_path, "my/custom/path.rb")
      end

      it "returns the custom path" do
        expect(subject).to eq "my/custom/path.rb"
      end
    end
  end

  describe "#stage_config_path" do
    subject { dsl.stage_config_path.to_s }

    context "when not specified" do
      before do
        dsl.delete(:stage_config_path)
      end

      it 'returns "config/deploy"' do
        expect(subject).to eq "config/deploy"
      end
    end

    context "when the variable :stage_config_path is set" do
      before do
        dsl.set(:stage_config_path, "my/custom/path")
      end

      it "returns the custom path" do
        expect(subject).to eq "my/custom/path"
      end
    end
  end

  describe "#repo_path" do
    subject { dsl.repo_path.to_s }

    context "when not specified" do
      before do
        dsl.delete(:repo_path)
      end

      it 'returns the default #{deploy_to}/repo' do
        dsl.set(:deploy_to, "/var/www")
        expect(subject).to eq "/var/www/repo"
      end
    end

    context "when the variable :repo_path is set" do
      before do
        dsl.set(:repo_path, "my/custom/path")
      end

      it "returns the custom path" do
        expect(subject).to eq "my/custom/path"
      end
    end
  end
end
