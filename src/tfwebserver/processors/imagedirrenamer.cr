module TFWeb
  class ImagesDirProcessor # < Processor
    def match(file_name)
      return file_name == "images"
    end

    def process(path_obj, child)
      puts "[abdoimg->images]renaming dir images at #{path_obj.to_s} to #{path_obj.to_s}/img"
      File.rename(path_obj.to_s, path_obj.join("img").to_s)
    end
  end
end
