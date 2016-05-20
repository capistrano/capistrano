require "capistrano/doctor/environment_doctor"
require "capistrano/doctor/gems_doctor"
require "capistrano/doctor/variables_doctor"
require "capistrano/doctor/servers_doctor"

load File.expand_path("../tasks/doctor.rake", __FILE__)
