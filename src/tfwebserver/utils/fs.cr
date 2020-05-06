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
    end
  end
end
