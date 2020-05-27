module TFWeb
  class LinkIncludeProcessor < LinkProcessor
    def initialize(@wiki_name : String)
    end

    def process_link(title, dest)
      unless dest.includes?(':')
        # append current source wiki for this include to dest
        return title, "#{@wiki_name}:#{dest}"
      end

      return title, dest
    end
  end

  class IncludeProcessor < ContentProcessor
    # this should match
    # !!!include:$wiki_name:$docname
    # where :$wikiname is optional
    # can be like
    # !!!include:$docname
    # include macro should be included in a line without any other content
    INCLUDE_RE = /^\s*\!\!\!\s*include\s*(?:\:\s*(.+)\s*)?\:\s*(.+)\s*$/

    def get_doc_content(wiki_name, doc_name)
      puts "get doc content #{wiki_name} #{doc_name}".colorize :red
      wiki_name = wiki_name.strip
      WebServer.markdowndocs_collections.try do |mdocs|
        unless mdocs.has_key?(wiki_name)
          raise "wiki name of '#{wiki_name}' is not configured"
        end

        mdoc = mdocs[wiki_name]
        filesinfo = mdoc.filesinfo
        # try to match this doc name inside map
        # doc_name can be a path too if n
        doc_name = doc_name.strip
        basename = File.basename(doc_name)
        finfo = nil

        if filesinfo.has_key?(basename)
          finfo = filesinfo[basename]
        elsif filesinfo.has_key?(basename.downcase)
          finfo = filesinfo[basename.downcase]
        end

        finfo.try do |info|
          info.paths.each do |path|
            if path.strip.downcase.ends_with?(doc_name)
              content = File.read(path)
              # apply includes on doc itself too
              # # TODO: remove when we settle on a proper specs for that include.
              if doc_name.includes?("_sidebar.md")
                return content
              end

              linker = LinkIncludeProcessor.new(wiki_name)
              content = linker.apply(content)
              return apply(content, current_wiki: wiki_name)
            end
          end
        end
      end

      raise "could not get doc content for '#{doc_name}' from '#{wiki_name}'"
    end

    def get_matches(content)
      content.split("\n").each do |line|
        match = line.match(INCLUDE_RE)
        unless match.nil?
          yield match
        end
      end
    end

    def apply(content, **options)
      current_wiki = options.fetch("current_wiki", "")

      get_matches(content) do |match|
        full_include = match[0]
        wiki_name = match[1]? || current_wiki
        doc_name = match[2].strip

        unless doc_name.downcase.ends_with?(".md")
          doc_name += ".md"
        end

        begin
          newcontent = get_doc_content(wiki_name.downcase, doc_name.downcase).not_nil! + "\n"
          content = content.gsub(full_include, newcontent)
        rescue ex
          return ex.message.as(String)
        end
      end

      content
    end

    def match(path)
      File.extname(path).strip.downcase == ".md"
    end
  end
end
