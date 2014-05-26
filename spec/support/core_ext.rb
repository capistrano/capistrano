unless File.respond_to? :write
 class File 
   def self.write path, data, mode = 'wb'
      open(path, mode) {|f| f.write data }
   end
 end
end
