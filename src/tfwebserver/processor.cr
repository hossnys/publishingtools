module TFWeb
  abstract class Processor
    abstract def match
    abstract def process
  end
end
