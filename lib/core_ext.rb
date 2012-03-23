# Custom extensions to core library

class String
  def to_file_name
    downcase.squeeze(' ').gsub(/ /, '-')
  end
end
