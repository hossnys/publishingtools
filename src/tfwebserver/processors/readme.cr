require "colorize"

module TFWeb
  class ReadMeProcessor < Processor
    def match(path)
      return path.basename.downcase == "readme.md"
    end

    def process(path)
      clean_child = "#{Path.new(path.dirname).basename}.md".downcase.gsub({" ": "_"})
      new_path = Path.new(path.dirname, clean_child)
      puts "[readme]renaming #{path.to_s} to #{new_path.to_s} ".colorize(:blue) if path.to_s != new_path.to_s

      File.rename(path.to_s, new_path.to_s) if path.to_s != new_path.to_s
      new_path
    end
  end
end
