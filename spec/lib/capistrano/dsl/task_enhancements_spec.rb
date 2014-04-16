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

      let!(:task) do
        Rake::Task.define_task('task', [:order]) do |t, args|
          args['order'].push 'task'
        end
      end

      let!(:before_task) do
        Rake::Task.define_task('before_task', [:order, :options]) do |t, args|
          args['order'].push ['before_task', args[:options]].compact.join(':')
        end
      end

      let!(:after_task) do
        Rake::Task.define_task('after_task', [:order, :options]) do |t, args|
          args['order'].push ['after_task', args[:options]].compact.join(':')
        end
      end

      it 'invokes in proper order and forwarding arguments' do
        order = []

        task_enhancements.after('task', 'after_task', order)
        task_enhancements.before('task', 'before_task', order)

        Rake::Task['task'].invoke(order)

        expect(order).to eq(['before_task', 'task', 'after_task'])
      end

      it 'invokes in proper order and with arguments' do
        order = []

        task_enhancements.after('task', 'after_task', order, '-a')
        task_enhancements.before('task', 'before_task', order, '-b')

        Rake::Task['task'].invoke(order)

        expect(order).to eq(['before_task:-b', 'task', 'after_task:-a'])
      end

      it 'invokes in proper order and with arguments and block' do
        order = []

        task_enhancements.after('task', 'after_task_custom', :order) do |t, args|
          args[:order].push 'after_task'
        end

        task_enhancements.before('task', 'before_task_custom', :order) do |t, args|
          args[:order].push 'before_task'
        end

        Rake::Task['task'].invoke(order)

        expect(order).to eq(['before_task', 'task', 'after_task'])
      end
    end
  end
end
