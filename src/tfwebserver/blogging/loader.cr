require "yaml"

module TFWeb
  module Blogging
    class Document
      META_REGX = /^\-{3}(.*?)\-{3}$/

      def initialize(@path : String)
        content = File.read(@path)
        match = content..strip().match(META_REGX)
        if match
        end
      end
    end
  end
end
