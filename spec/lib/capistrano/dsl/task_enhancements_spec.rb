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
        Rake::Task.define_task('task', [:order]) do |_t, args|
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

      it 'invokes in proper order when referring to as-yet undefined tasks' do
        task_enhancements.after('task', 'not_loaded_task')

        Rake::Task.define_task('not_loaded_task') do
          order.push 'not_loaded_task'
        end

        Rake::Task['task'].invoke order

        expect(order).to eq(['task', 'not_loaded_task'])
      end

      it 'invokes in proper order and with arguments and block' do
        task_enhancements.after('task', 'after_task_custom', :order) do |_t, _args|
          order.push 'after_task'
        end

        task_enhancements.before('task', 'before_task_custom', :order) do |_t, _args|
          order.push 'before_task'
        end

        Rake::Task['task'].invoke(order)

        expect(order).to eq(['before_task', 'task', 'after_task'])
      end

      it "invokes using the correct namespace when defined within a namespace" do
        Rake.application.in_namespace('namespace') {
          Rake::Task.define_task('task') do |t|
            order.push(t.name)
          end
          task_enhancements.before('task', 'before_task', :order) do |t|
            order.push(t.name)
          end
          task_enhancements.after('task', 'after_task', :order) do |t|
            order.push(t.name)
          end
        }

        Rake::Task['namespace:task'].invoke

        expect(order).to eq(
          ['namespace:before_task', 'namespace:task', 'namespace:after_task']
        )
      end

      it "invokes using the correct namespace when referenced within a namespace" do
        Rake.application.in_namespace('namespace') {
          Rake::Task.define_task('task') do |t|
            order.push(t.name)
          end
          Rake::Task.define_task('before_task') do |t|
            order.push(t.name)
          end
          Rake::Task.define_task('after_task') do |t|
            order.push(t.name)
          end

          task_enhancements.before('task', 'before_task')
          task_enhancements.after('task', 'after_task')
        }

        Rake::Task['namespace:task'].invoke

        expect(order).to eq(
          ['namespace:before_task', 'namespace:task', 'namespace:after_task']
        )
      end

      it 'invokes namespace-qualified enhancements' do
        Rake.application.in_namespace('namespace') {
          Rake::Task.define_task('before_task') do |t|
            order.push(t.name)
          end
          Rake::Task.define_task('after_task') do |t|
            order.push(t.name)
          end
        }
        task_enhancements.before('task', 'namespace:before_task')
        task_enhancements.after('task', 'namespace:after_task')
        Rake::Task['task'].invoke(order)

        expect(order).to eq(
          ['namespace:before_task', 'task', 'namespace:after_task']
        )
      end

      it 'does not use namespace when before/after used outside of namespace block' do
        Rake.application.in_namespace('namespace') do
          # Define a namespaced task that we will enhance
          Rake::Task.define_task('task') do |t|
            order.push(t.name)
          end

          # These tasks should never be invoked. They are only declared here
          # to catch a bug where the task enhancement logic invokes namespaced
          # tasks by mistake.
          Rake::Task.define_task('before_task') do |t|
            order.push("bug! #{t.name}")
          end
          Rake::Task.define_task('after_task') do |t|
            order.push("bug! #{t.name}")
          end
        end

        # These are the tasks we expect to be invoked (defined in `let` above).
        task_enhancements.after('namespace:task', 'after_task')
        task_enhancements.before('namespace:task', 'before_task')

        Rake::Task['namespace:task'].invoke

        expect(order).to eq(
          ['before_task', 'namespace:task', 'after_task']
        )
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
