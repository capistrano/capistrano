require 'spec_helper'

module Capistrano
  class DummyTaskEnhancements
    include TaskEnhancements
  end

  describe TaskEnhancements do
    let(:task_enhancements) { DummyTaskEnhancements.new }

    describe 'ordering' do
      let!(:task) do
        Rake::Task.define_task('task', [:order]) do |t, args|
          args['order'].push 'task'
        end
      end
!
      let!(:before_task) do
        Rake::Task.define_task('before_task', [:order]) do |t, args|
          args['order'].push 'before_task'
        end
      end

      let!(:after_task) do
        Rake::Task.define_task('after_task', [:order]) do |t, args|
          args['order'].push 'after_task'
        end
      end

      it 'invokes in proper order and forwarding arguments' do
        task_enhancements.after('task', 'after_task')
        task_enhancements.before('task', 'before_task')

        order = []

        Rake::Task['task'].invoke(order)

        expect(order).to eq(['before_task', 'task', 'after_task'])
      end
    end
  end
end
