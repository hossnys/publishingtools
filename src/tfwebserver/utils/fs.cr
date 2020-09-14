module TFWeb
  module Utils
    module FS
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

      def walk_files(root, skips = [] of String, &block : String ->)
        Dir.each_child(root) do |entry|
          if skips.includes?(entry.strip.downcase)
            Logger.debug { "skipping '#{entry}' at '#{root}'" }
            next
          end

          path = File.join(root, entry)
          if File.directory?(path)
            walk_files(path, &block)
          else
            yield path
          end
        end
      end
    end
  end
end
