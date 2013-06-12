require 'git'
 
module Jekyll
  class GitActivityTag < Liquid::Tag
 
    def initialize(tag_name, text, tokens)
      super
    end
 
    def render(context)
      result = ""
      g = Git.open(File.join(Dir.getwd, ".."))
      
      index = 0
      g.log.each do |log| 
        if(index < 10)
          result << "<li>" 
          result << log.date.strftime("%d %b")
          result << " - <a href='https://github.com/capistrano/capistrano-documentation/commit/"
          result << log.sha
          result << "/'>"
          result << log.message
          result << "</a></li>"
          index += 1
        end
      end
      "<ul>#{result}</ul>"
    end
  end
end
 
Liquid::Template.register_tag('gitactivity', Jekyll::GitActivityTag)