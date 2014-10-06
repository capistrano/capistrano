require 'spec_helper'

module Capistrano
  class DummyTaskEnhancements
    include TaskEnhancements
  end

  describe TaskEnhancements do
    let(:task_enhancements) { DummyTaskEnhancements.new }

    describe 'ordering' do

      after do
        task.clear
        before_task.clear
        after_task.clear
        Rake::Task.clear
      end

      let(:order) { [] }
      let!(:task) do
        Rake::Task.define_task('task', [:order]) do |t, args|
          args['order'].push 'task'
        end
      end

      let!(:before_task) do
        Rake::Task.define_task('before_task') do
          order.push 'before_task'
        end
      end

      let!(:after_task) do
        Rake::Task.define_task('after_task') do
          order.push 'after_task'
        end
      end

      it 'invokes in proper order if define after than before' do
        task_enhancements.after('task', 'after_task')
        task_enhancements.before('task', 'before_task')

        Rake::Task['task'].invoke order

        expect(order).to eq(['before_task', 'task', 'after_task'])
      end

      it 'invokes in proper order if define before than after' do
        task_enhancements.before('task', 'before_task')
        task_enhancements.after('task', 'after_task')

        Rake::Task['task'].invoke order

        expect(order).to eq(['before_task', 'task', 'after_task'])
      end

      it 'invokes in proper order and with arguments and block' do
        task_enhancements.after('task', 'after_task_custom', :order) do |t, args|
          order.push 'after_task'
        end

        task_enhancements.before('task', 'before_task_custom', :order) do |t, args|
          order.push 'before_task'
        end

        Rake::Task['task'].invoke(order)

        expect(order).to eq(['before_task', 'task', 'after_task'])
      end

    end

    describe 'remote_file' do
      subject(:remote_file) { task_enhancements.remote_file('source' => 'destination') }

      it { expect(remote_file.name).to eq('source') }
      it { is_expected.to be_a(Capistrano::UploadTask) }

      describe 'namespaced' do
        let(:app) { Rake.application }
        around { |ex| app.in_namespace('namespace', &ex) }

        it { expect(remote_file.name).to eq('source') }
        it { is_expected.to be_a(Capistrano::UploadTask) }
      end
    end
  end
end
