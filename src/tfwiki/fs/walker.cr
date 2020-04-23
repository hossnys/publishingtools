require "./processor"
require "./processors/*"

module TfWiki
  class Walker
    def initialize
      @all_names = Set(String).new
      @img = ImageProcessor.new
      @md = MdProcessor.new
      @readme = ReadMeProcessor.new
    end

    def check_dups(path)
      path_obj = Path.new(path)
      Dir.each_child path do |child|
        child_path = path_obj.join(child)
        if Dir.exists? child_path
          if child.downcase == "img"
            next
          end
          check_dups child_path.to_s
        elsif @readme.match(child)
          child = "#{child_path.parent.basename}.md"
        end
        is_new = @all_names.add? child.downcase
        if !is_new
          raise "File name: #{child} not unique for path: #{child_path}"
        end
      end
    end

    def fixer(path)
      path_obj = Path.new(path)
      Dir.each_child path do |child|
        child_path = path_obj.join(child)
        if Dir.exists? child_path
          if child.downcase == "img"
            next
          end
          fixer child_path.to_s
        else
          if @readme.match(child)
            @readme.process(path_obj, child)
          elsif @img.match(child)
            @img.process(path_obj, child)
          elsif @md.match(child)
            @md.process(path_obj, child)
          end
        end
      end
    end
  end
end
