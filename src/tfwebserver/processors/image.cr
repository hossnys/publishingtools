module TFWeb
  IMAGE_REGEX = /(.*)(.jpg$)|(.*)(.jpeg$)|(.*)(.svg$)|(.*)(.png$)/

  class ImageProcessor < Processor
    def match(path)
      return path.basename.match(IMAGE_REGEX)
    end

    def process(path)
      new_image_name = path.basename.downcase.gsub({" ": "_"})

      original_image_path = path.to_s
      new_image_path = Path.new(path.dirname, new_image_name).to_s

      if original_image_path != new_image_path
        File.rename(original_image_path, new_image_path)
        return new_image_path
      end
      # if we are in img dir .. do nothing
      return new_image_path if new_image_path.includes?("/img") # if structured on any levels within img dir we return.

      image_dest_dir = Path.new(path.dirname, "img").to_s
      unless Dir.exists?(image_dest_dir)
        Dir.mkdir_p(image_dest_dir)
      end
      image_in_img_dir_path = File.join(image_dest_dir, new_image_name)
      File.rename(new_image_path, image_in_img_dir_path)
    end
  end
end
