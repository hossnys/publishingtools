module TfWiki
  module MdBook
    class Preprocessor
      getter :book

      ESCAPE_SEQ = {
        "\n": ";;NEWLINE;;",
        "\t": ";;TAB;;",
      }

      @context : JSON::Any

      def initialize(input : String)
        input = JSON.parse(input)
        @context = input[0]
        @book = Book.from_json(input[1].to_json)
      end

      def replace_escape_seq(input)
        ESCAPE_SEQ.each do |key, value|
          input = input.gsub(key.to_s, value)
        end

        input
      end

      def restore_escape_seq(input)
        ESCAPE_SEQ.each do |key, value|
          input = input.gsub(value, key.to_s)
        end

        input
      end

      def process
      end

      def to_json(*args, **kwargs)
        @book.to_json(*args, **kwargs)
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
