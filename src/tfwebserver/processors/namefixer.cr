module TFWeb
  class NameFixerProcessor < Processor
    def match(path)
      extensions = [".md", ".jpg", ".jpeg", ".png", "svg"]
      if extensions.includes?(path.extension)
        true
      else
        false
      end
    end

    def process(path)
      return if path.to_s.ends_with?("README.md")

      clean_child = path.basename.downcase.gsub({" ": "_", "-": "_"})
      new_path = Path.new(path.dirname, clean_child)
      if new_path.to_s != path.to_s
        Logger.info { "[namesfixer]renaming #{path.to_s} to #{new_path.to_s} " }
        File.rename(path.to_s, new_path.to_s)
      end
      new_path
    end
  end
end
