module TFWeb
  module Utils
    module FS
      class WalkFilter
        property dir_pattern : Regex
        property file_pattern : Regex

        def initialize(@dir_pattern, @file_pattern)
        end
      end

      # by default, skip .git, out directories
      # and any file or directory that start with "_"
      DEFAULT_FILTER = WalkFilter.new(
        dir_pattern: /((\.git)|(out)|(^_.*))/i,
        file_pattern: /^_((?!sidebar|navbar).)*$/i
      )

      def list_dirs(path, &block)
        Dir.children(path).each do |sub_path|
          full_path = File.join(path, sub_path)
          if File.directory?(full_path)
            yield sub_path
          end
        end
      end

      def list_files(path, ext = "", &block)
        Dir.children(path).each do |sub_path|
          full_path = File.join(path, sub_path)
          if File.file?(full_path) && full_path.strip.downcase.ends_with?(ext)
            yield sub_path
          end
        end
      end

      def walk_files(root, filter : WalkFilter = DEFAULT_FILTER, &block : String ->)
        Dir.each_child(root) do |entry|
          path = File.join(root, entry)

          if File.directory?(path)
            if filter.dir_pattern.match(entry.strip)
              Logger.debug { "skipping directory: '#{entry}' at '#{root}'" }
              next
            end
            walk_files(path, &block)
          else
            if filter.file_pattern.match(entry.strip)
              Logger.debug { "skipping file: '#{entry}' at '#{root}'" }
              next
            end
            yield path
          end
        end
      end
    end
  end
end
