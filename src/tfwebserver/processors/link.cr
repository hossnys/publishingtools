require "markd"

module TFWeb
  class LinkProcessor < ContentProcessor
    def match(path)
      return File.extname(path) == ".md"
    end

    def apply(content, **options)
      document = Markd::Parser.parse(content, Markd::Options.new(time: false))

      walker = document.walker
      while event = walker.next
        node, entering = event
        unless entering
          next
        end

        case node.type
        when Markd::Node::Type::Link
          dest = node.data["destination"].as(String)
          if dest.starts_with?(/\s*(http|mailto)/i)
            next
          end

          # every link node has a child text node with title
          title = node.first_child.text
          source = "[#{title}](#{dest})"

          dest = dest.strip
          if dest.includes?(":")
            parts = dest.split(":")
            if parts.size == 2
              wiki, doc = parts
              new_dest = resolve(wiki.strip, doc.strip)
              unless new_dest.nil?
                link = "[#{title}](#{new_dest} ':ignore')"
                content = content.gsub(source, link)
              end
            end
          end
        end
      end

      content
    end

    private def resolve(wiki_name, doc_name)
      if TFWeb::WebServer.wikis.has_key?(wiki_name)
        wiki = TFWeb::WebServer.wikis[wiki_name]
        if wiki.domain.empty?
          "/#{wiki.name}/#/#{doc_name}"
        else
          "https://#{wiki.domain}/#/#{doc_name}"
        end
      end
    end
  end
end
