require "colorize"

module TFWeb
  class MdProcessor < Processor
    def match(file_name)
      return File.extname(file_name) == ".md"
    end

    def process(path_obj, child)
      child_path = path_obj.join(child)
      return if child_path.to_s.ends_with?("README.md")

      clean_child = child.downcase.gsub({" ": "_", "-": "_"})
      new_path = path_obj.join(clean_child)
      unless clean_child != child_path.to_s
        puts "[md]renaming #{child_path.to_s} to #{new_path.to_s} ".colorize(:blue) if clean_child != child_path.to_s
        File.rename(child_path.to_s, new_path.to_s) if clean_child != child_path.to_s
      end
      new_path
    end
  end
end
