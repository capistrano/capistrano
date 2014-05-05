dotfile = Pathname.new(File.join(Dir.home, '.capfile'))
Capistrano::Application.load_rakefile_once dotfile if dotfile.file?

