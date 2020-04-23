module TfWiki
  class ImagesDirProcessor # < Processor
    def match(file_name)
      return file_name == "images"
    end

    def process(path_obj, child)
      puts "renaming dir images at #{path_obj.to_s} to #{path_obj.to_s}/img"
      File.rename("images", "img")
    end
  end
end
