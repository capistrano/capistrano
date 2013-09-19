require 'integration_spec_helper'

describe 'cap deploy' do
  let(:config) {
    %{
      set :stage, :custom
    }
  }

  before do
    install_test_app_with(config)
    copy_task_to_test_app('spec/support/tasks/custom_stage.cap')
  end

  it 'writes the log file' do
    out = cap 'deploy:print_stage'
    out.should include('custom')
  end
end
