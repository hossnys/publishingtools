module TFWeb
  class ImagesDirProcessor < Processor
    def match(path)
      return path.basename == "images"
    end

    def process(path)
      newname = Path.new(path.dirname, "img").to_s
      Logger.info { "[img->images]renaming dir images at #{path.to_s} to #{newname}" }
      File.rename(path.to_s, newname)
      newname
    end
  end
end
