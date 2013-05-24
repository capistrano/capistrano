dotfile = Pathname.new(File.join(Dir.home, '.capfile'))
load dotfile if dotfile.file?

