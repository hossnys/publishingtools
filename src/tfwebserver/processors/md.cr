module TFWeb
  class MdProcessor < Processor
    def match(path)
      return File.extname(path) == ".md"
    end

    def process(path)
      return if path.to_s.ends_with?("README.md")

      clean_child = path.basename.downcase.gsub({" ": "_", "-": "_"})
      new_path = Path.new(path.dirname, clean_child)
      if new_path != path
        Logger.info { "[md]renaming #{path.to_s} to #{new_path.to_s} " }
        File.rename(path.to_s, new_path.to_s)
      end
      new_path
    end
  end
end
