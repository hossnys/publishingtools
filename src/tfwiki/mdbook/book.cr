require "json"

module TfWiki
  module MdBook
    class Chapter
      include JSON::Serializable

      property name : String?
      property content : String?
      property number : Int32 | Nil | Array(Int32)
      property path : String?
      property parent_names : Array(String)?
      property sub_items : Array(Chapter)?
    end

    class BookItem
      include JSON::Serializable

      @[JSON::Field(key: "Chapter")]
      property chapter : Chapter
    end

    class Book
      include JSON::Serializable

      property sections : Array(BookItem)

      @[JSON::Field(key: "__non_exhaustive")]
      property non_exhaustive : String | Nil
    end
  end
end
