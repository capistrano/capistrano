require 'spec_helper'
require 'fileutils'

describe Capistrano::DSL::Paths do

  let(:tmp_folder){File.join(File.dirname(__FILE__), 'tmp')}
  let(:tasks_filename){File.join(TestApp.task_dir, 'tasks.rake')}

  before :each do
    FileUtils.mkpath tmp_folder

    TestApp.install(tmp_folder)

  end

  after :each do
    FileUtils.rm_rf(tmp_folder) unless ENV['KEEP_RUNNING']
    TestApp.test_app_path=nil
  end

  describe '#capfile_path' do
    let(:taskname){'show_capfile_path'}


    before :each do
      File.write(tasks_filename, <<-EOSTR
        task :#{taskname} do
           puts capfile_path
        end
      EOSTR
      )
    end


     it 'returns the capfile path' do
       (success, output) = TestApp.cap taskname
       output.chomp!
       expect(success).to be true
       expect(output).to eq(TestApp.test_app_path.to_s)
     end

    it 'returns the capfile path even in subfolders' do
      (success, output) = TestApp.cap taskname, TestApp.task_dir
      output.chomp!
      expect(success).to be true
      expect(output).to eq(TestApp.test_app_path.to_s)
    end
  end

  describe '#stage_config_path' do
    let(:taskname){'show_stage_config_path'}

    before :each do
      File.write(tasks_filename, <<-EOSTR
        task :#{taskname} do
           puts stage_config_path
        end
      EOSTR
      )
    end


    it 'returns the stage_config_path' do
      (success, output) = TestApp.cap taskname
      output.chomp!
      expect(success).to be true
      expect(output).to eq(TestApp.test_app_path.join('config/deploy').to_s)
    end

    it 'returns the stage_config_path even in subfolders' do
      (success, output) = TestApp.cap taskname, TestApp.task_dir
      output.chomp!
      expect(success).to be true
      expect(output).to eq(TestApp.test_app_path.join('config/deploy').to_s)
    end

  end

  describe '#deploy_config_path' do
    let(:taskname){'show_deploy_config_path'}

    before :each do
      File.write(tasks_filename, <<-EOSTR
        task :#{taskname} do
           puts deploy_config_path
        end
      EOSTR
      )
    end


    it 'returns the deploy_config_path' do
      (success, output) = TestApp.cap taskname
      output.chomp!
      expect(success).to be true
      expect(output).to eq(TestApp.test_app_path.join('config/deploy.rb').to_s)
    end

    it 'returns the deploy_config_path even in subfolders' do
      (success, output) = TestApp.cap taskname, TestApp.task_dir
      output.chomp!
      expect(success).to be true
      expect(output).to eq(TestApp.test_app_path.join('config/deploy.rb').to_s)
    end

  end
end
