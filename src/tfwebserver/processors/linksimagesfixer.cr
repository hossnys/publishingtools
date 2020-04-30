require "markd"
require "colorize"

module TFWeb
  class MyLinksImagesRenderer < Markd::HTMLRenderer
    property links = Array(String).new
    property images = Array(String).new

    def initialize(@options = Options.new)
      super.initialize
      @links = [] of String
      @images = [] of String
    end

    def link(node, entering)
      @links << node.data["destination"].as(String)
    end

    def image(node, entering)
      @images << node.data["destination"].as(String)
    end
  end

  class LinksImagesProcessor < Processor
    property all_images = Array(String).new
    property all_links = Array(String).new

    def all_links
      @all_links
    end

    def all_images
      @all_images
    end

    def match(file_name)
      return File.extname(file_name) == ".md"
    end

    private def getlinks(content)
      options = Markd::Options.new(time: false)
      document = Markd::Parser.parse(content, options)
      renderer = MyLinksImagesRenderer.new(options)
      renderer.render(document)
      renderer
    end

    def process(path_obj, child)
      child_path = path_obj.join(child)
      content = ""
      content = File.read(child_path)
      processor = getlinks(content)
      @all_links = processor.links
      @all_images = processor.images
      links = processor.links
      images = processor.images
      #   p links, images
      links.each do |link|
        next if link.starts_with?("http")

        # TODO: probably should check if has extension in general. next unless link.ends_with?(".md")
        if link.ends_with?(".md")
          # on filesystem
          linkbasename = File.basename(link)
          dirlink = File.basename(File.dirname(link) + ".md")
          newlink = linkbasename
          if linkbasename.downcase == "readme.md"
            newlink = dirlink
          end

          newlink = newlink.downcase.gsub({"-": "_"})
          if link != newlink
            newcontent = content.gsub link, newlink
            content = newcontent
            puts "[linksfixer]old link is #{link}  and new link should be #{newlink}".colorize(:blue) if link != newlink
          end
        end
      end

      #   puts "abdo #{images}"
      images.uniq.each do |img|
        unless img.starts_with?("http")
          # on filesystem
          # TODO: probably should check if has extension instead
          next unless img.ends_with?(".png") || img.ends_with?(".jpg") || img.ends_with?(".jpeg")
          baseimg = File.basename(img)
          newimg = File.basename(img)

          newimg = newimg.downcase.gsub({"-": "_"})

          if File.exists?(path_obj.join("img").join(baseimg))
            newimg = "./img/#{newimg}"
          end
          puts "#{path_obj} #{child} [imagefixer]old img is #{baseimg}  and new img should be #{newimg}".colorize(:blue) if img != newimg

          newcontent = content.gsub(img, newimg)
          content = newcontent
        end
      end
      if images.size > 0 || links.size > 0
        File.write(child_path, content)
      end
      child_path
    end
  end
end
