desc "Display a Capistrano troubleshooting report (all doctor: tasks)"
task doctor: ["doctor:environment", "doctor:gems", "doctor:variables", "doctor:servers"]

namespace :doctor do
  desc "Display Ruby environment details"
  task :environment do
    Capistrano::Doctor::EnvironmentDoctor.new.call
  end

  desc "Display Capistrano gem versions"
  task :gems do
    Capistrano::Doctor::GemsDoctor.new.call
  end

  desc "Display the values of all Capistrano variables"
  task :variables do
    Capistrano::Doctor::VariablesDoctor.new.call
  end

  desc "Display the effective servers configuration"
  task :servers do
    Capistrano::Doctor::ServersDoctor.new.call
  end
end
