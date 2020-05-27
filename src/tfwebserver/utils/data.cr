module TFWeb
  module Utils
    module YAML
      class Base
        def self.new_empty
          return self.from_yaml("")
        end
      end
    end

    module JSON
      class Base
        def self.new_empty
          return self.from_json("{}")
        end
      end
    end
  end
end
