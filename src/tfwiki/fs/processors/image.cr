module TfWiki
  IMAGE_REGEX = /(.*)(.jpg$)|(.*)(.jpeg$)|(.*)(.svg$)|(.*)(.png$)/

  class ImageProcessor # < Processor
    def match(file_name)
      return file_name.match(IMAGE_REGEX)
    end

    def process(path_obj, child)
      child_path = path_obj.join(child)
      clean_child = child.downcase.gsub({" ": "_"})
      Dir.mkdir_p(path_obj.join("img").to_s)
      new_path = path_obj.join("img", clean_child)
      File.rename(child_path.to_s, new_path.to_s)
    end
  end
end
