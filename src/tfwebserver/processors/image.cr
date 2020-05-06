module TFWeb
  IMAGE_REGEX = /(.*)(.jpg$)|(.*)(.jpeg$)|(.*)(.svg$)|(.*)(.png$)/

  class ImageProcessor < Processor
    def match(file_name)
      return file_name.match(IMAGE_REGEX)
    end

    def process(path_obj, child)
      original_image_name = child
      new_image_name = child.downcase.gsub({" ": "_"})

      original_image_path = path_obj.join(original_image_name).to_s
      new_image_path = path_obj.join(new_image_name).to_s

      if original_image_path != new_image_path
        File.rename(original_image_path, new_image_path)
        return new_image_path
      end
      # if we are in img dir .. do nothing
      return new_image_path if new_image_path.includes?("/img") # if structured on any levels within img dir we return.

      image_dest_dir = path_obj.join("img").to_s
      unless Dir.exists?(image_dest_dir)
        Dir.mkdir_p(image_dest_dir)
      end
      image_in_img_dir_path = File.join(image_dest_dir, new_image_name)
      File.rename(new_image_path, image_in_img_dir_path)
    end
  end
end
