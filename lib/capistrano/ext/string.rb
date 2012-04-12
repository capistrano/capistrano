class String
  def compact
    self.gsub(/\s+/, ' ')
  end
  
  
  def unindent
    gsub /^#{self[/\A\s*/]}/, ''
  end # unindent
end
