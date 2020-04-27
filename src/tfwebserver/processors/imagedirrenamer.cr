module TFWeb
  class ImagesDirProcessor # < Processor
    def match(file_name)
      return file_name == "images"
    end

    def process(path_obj, child)
      fullpath = path_obj.join(child)
      puts "[img->images]renaming dir images at #{fullpath.to_s} to #{path_obj.to_s}/img"
      File.rename(fullpath.to_s, path_obj.join("img").to_s)
    end
  end
end
