include ::Capistrano::Runit
require 'pry'

namespace :load do
  task :defaults do
    set :runit_rake_run_template, nil
    set :runit_rake_default_hooks, -> { true }
    set :runit_rake_role, -> { :app }
    set :runit_rake_tasks, -> { {} }
  end
end

namespace :deploy do
  before :starting, :runit_check_rake_hooks do
    invoke 'runit:rake:add_default_hooks' if fetch(:runit_rake_default_hooks)
  end
end

namespace :runit do
  namespace :rake do |rake_namespace|
    # Helpers
    def collect_rake_run_command(task)
      array = []
      array << env_variables
      array << "RAILS_ENV=#{fetch(:rails_env)}"
      array << "exec #{SSHKit.config.command_map[:rake]} #{task}"
      array.compact.join(' ')
    end

    def generate_namespace_for_rake_task(name, task_name, parent_task)
      my_namespace = "runit:rake:#{name}"
      parent_task.application.define_task Rake::Task, "#{my_namespace}:setup" do
        setup_service("rake_#{name}", collect_rake_run_command(task_name))
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:enable" do
        enable_service("rake_#{name}")
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:disable" do
        disable_service("rake_#{name}")
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:start" do
        start_service("rake_#{name}")
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:stop" do
        on roles fetch("runit_rake_#{name}_role".to_sym) do
          runit_execute_command("rake_#{name}", 'down')
        end
      end
      parent_task.application.define_task Rake::Task, "#{my_namespace}:restart" do
        restart_service("rake_#{name}")
      end
    end

    task :add_default_hooks do
      after 'deploy:check', 'runit:rake:check'
      after 'deploy:updated', 'runit:rake:stop'
      after 'deploy:reverted', 'runit:rake:stop'
      after 'deploy:published', 'runit:rake:start'
    end

    task :hook do |task|
      fetch(:runit_rake_tasks).each do |key, value|
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        set "runit_rake_#{name}_role".to_sym, -> { :app }
        generate_namespace_for_rake_task(name, value, task)
      end
    end

    task :check do
      fetch(:runit_rake_tasks).each do |key, value|
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        check_service('rake', name)
      end
    end

    task :stop do
      fetch(:runit_rake_tasks).each do |key, value|
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["runit:rake:#{name}:stop"].invoke
      end
    end

    task :start do
      fetch(:runit_rake_tasks).each do |key, value|
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["runit:rake:#{name}:start"].invoke
      end
    end

    task :restart do
      fetch(:runit_rake_tasks).each do |key, value|
        name = key.gsub(/\s*[^A-Za-z0-9\.\-]\s*/, '_')
        ::Rake::Task["runit:rake:#{name}:restart"].invoke
      end
    end

  end
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'runit:rake:hook'
end
