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

  # TODO: better to do this as a custom Markd::Renderer
  # instead of passing the content between processors

  class NodeProcessor
    # A base processor for any markdown document node type
    def match_type(node_type)
      return true
    end

    def process_node(node, content)
      return content
    end

    def apply(content, **options)
      document = Markd::Parser.parse(content, Markd::Options.new(time: false))
      walker = document.walker
      while event = walker.next
        node, entering = event
        unless entering
          next
        end

        if match_type(node.type)
          content = process_node(node, content)
        end
      end

      content
    end
  end

  class LinkProcessor < NodeProcessor
    # Base processor for links and images

    def match_type(node_type)
      node_type == Markd::Node::Type::Link || node_type == Markd::Node::Type::Image
    end

    def process_link(title, dest)
      return title, dest
    end

    def process_node(node, content)
      # every link node has a child text node with title
      dest = node.data["destination"].as(String)

      # full link, no need to process
      if dest.starts_with?(/\s*(http|mailto)/i)
        return content
      end

      title = node.data["title"].as(String)
      if title.empty?
        if node.type == Markd::Node::Type::Link
          title = node.first_child.text
        end
      end

      orig_link = "[#{title}](#{dest})"
      if node.type == Markd::Node::Type::Image
        orig_link = "!#{orig_link}"
      end

      new_title, new_dest = process_link(title, dest)
      if new_title != title || new_dest != dest
        new_link = "[#{title}](#{new_dest})"
        content = content.gsub(orig_link, new_link)
      end

      content
    end
  end
end
