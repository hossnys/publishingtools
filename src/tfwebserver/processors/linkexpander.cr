require "markd"

module TFWeb
  class LinkExpander < LinkProcessor
    # this processor will expand a link destination to the full link
    # to wiki/blog/website
    # it will use the domain field in tfweb server config if set
    # examples
    # [grid](wiki2:grid.md) => [grid](/wiki2/#/grid.md)
    # [threefold team](threefold:public/#/team) => [threefold team](https://threefold.io:public/#/team)
    # [blog post](xmonblog:posts/nim-community-survey-2018-results) => [blog post](/blog/xmonblog/posts/nim-community-survey-2018-results)

    def process_link(title, dest)
      # skip docsify helpers like ':ingore'
      doit = dest.includes?(":") && !dest.includes?("':")
      if dest.includes?(":") && !dest.includes?("':")
        parts = dest.split(":")

        if parts.size == 2
          site_name, sub_dest = parts
          new_dest = resolve(site_name.strip, sub_dest.strip)
          unless new_dest.nil?
            dest = "#{new_dest} ':ignore'"
          end
        end
      end

      return title, dest
    end

    private def link_for_site(site, sub_dest, is_blog = false)
      if site.domain.empty?
        server_config = TFWeb::WebServer.config.not_nil!["server"].as(Hash)
        addr = server_config["addr"]
        port = server_config["port"]
        base = "http://#{addr}:#{port}"

        if is_blog
          "#{base}/blog/#{site.name}/#{sub_dest}"
        else
          "#{base}/#{site.name}/#{sub_dest}"
        end
      else
        base = "https://#{site.domain}"
        if is_blog
          "#{base}/blog/#{site.name}/#{sub_dest}"
        else
          "#{base}/#{sub_dest}"
        end
      end
    end

    private def resolve(site_name, sub_dest)
      if TFWeb::WebServer.wikis.has_key?(site_name)
        site = TFWeb::WebServer.wikis[site_name]
        ext = File.extname(sub_dest).strip.downcase
        if ext == ".md" || ext.empty?
          # then it's a document served by docsify, append hash
          sub_dest = "#/#{sub_dest}"
        end
        link_for_site(site, sub_dest)
      elsif TFWeb::WebServer.websites.has_key?(site_name)
        site = TFWeb::WebServer.websites[site_name]
        link_for_site(site, sub_dest)
      elsif TFWeb::WebServer.blogs.has_key?(site_name)
        site = TFWeb::WebServer.blogs[site_name]
        unless sub_dest.starts_with?("pages") || sub_dest.starts_with?("posts")
          sub_dest = "posts/#{sub_dest}"
        end
        link_for_site(site, sub_dest, true)
      end
    end
  end
end
