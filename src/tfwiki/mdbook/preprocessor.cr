module TfWiki
  module MdBook
    class Preprocessor
      def initialize(book)
      end

      def process
      end

      def to_json
      end
    end
  end
end

# require "json"

# content = STDIN.gets_to_end
# if !content.empty?
#   book_data = JSON.parse(content)
#   context = book_data[0]
#   book = book_data[1]

#   book.to_json(STDOUT)
# end
