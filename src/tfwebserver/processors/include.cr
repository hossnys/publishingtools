module TFWeb
  class IncludeProcessor < Processor
    # this should match
    # !!!include:$wiki_name:$docname
    # where :$wikiname is optional
    # can be like
    # !!!include:$docname
    INCLUDE_RE = /\!\!\!\s*include\s*(?:\:\s*(.+)\s*)?\:\s*(.+)\s*/

    def get_doc_content(wiki_name, doc_name)
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
              return apply_includes(wiki_name, content)
            end
          end
        end
      end

      raise "could not get doc content for '#{doc_name}' from '#{wiki_name}'"
    end

    def apply_includes(current_wiki, content)
      matches = content.scan(INCLUDE_RE)

      unless matches.empty?
        matches.each do |match|
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
            return ex.message
          end
        end
      end

      return content
    end

    def match(path)
      File.extname(path).strip.downcase == ".md"
    end

    def process(path)
      path
    end
  end
end
