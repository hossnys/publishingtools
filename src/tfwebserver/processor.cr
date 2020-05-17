module TFWeb
  class Processor
    def match(path)
    end

    def process(path) : String
      ""
    end
  end

  class ContentProcessor
    def match(path)
    end

    def apply(content, **options)
    end
  end
end
