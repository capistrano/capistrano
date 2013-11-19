desc 'Execute remote commands'
task :console do
  stage = fetch(:stage)
  puts I18n.t('console.welcome', scope: :capistrano, stage: stage)
  loop do
    print "#{stage}> "

    if input = $stdin.gets
      command = input.chomp
    else
      command = 'exit'
    end

    next if command.empty?

    if %w{quit exit q}.include? command
      puts t('console.bye')
      break
    else
      begin
        on roles :all do
          execute command
        end
      rescue => e
        puts e
      end
    end
  end
end
