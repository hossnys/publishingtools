require "colorize"

module TFWeb
  class ImagesDirProcessor < Processor
    def match(path)
      return path.basename == "images"
    end

    def process(path)
      newname = Path.new(path.dirname, "img").to_s
      puts "[img->images]renaming dir images at #{path.to_s} to #{newname}".colorize(:blue)
      File.rename(path.to_s, newname)
      newname
    end
  end
end
