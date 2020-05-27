require "markd"
require "colorize"

module TFWeb
  class MDElement
    property url = ""
    property filepath = ""

    def initialize(@url : String, @filepath : String)
    end

    def to_s
      "#{@url} in #{@filepath} "
    end

    def file_basename
      File.basename(@filepath)
    end
  end

  class MDLink < MDElement
  end

  class MDImage < MDElement
  end

  class MyLinksImagesRenderer < Markd::HTMLRenderer
    property links = [] of MDLink
    property images = [] of MDImage
    property filepath = ""

    def initialize(@options = Options.new)
      super.initialize
    end

    def link(node, entering)
      if entering
        linkurl = node.data["destination"].as(String)
        @links << MDLink.new(url: linkurl, filepath: @filepath)
      end
    end

    def image(node, entering)
      if entering
        imgurl = node.data["destination"].as(String)
        @images << MDImage.new(url: imgurl, filepath: filepath)
      end
    end
  end

  class LinksImagesProcessor < Processor
    property all_mdimages = [] of MDImage
    property all_mdlinks = [] of MDLink
    property filepath = ""

    def match(path)
      return File.extname(path) == ".md"
    end

    private def process_links_and_images(filepath)
      options = Markd::Options.new(time: false)
      content = File.read(filepath)
      document = Markd::Parser.parse(content, options)
      renderer = MyLinksImagesRenderer.new(options)
      renderer.filepath = filepath.to_s
      renderer.render(document)
      renderer
    end

    def process(path)
      content = ""
      content = File.read(path)
      therenderer = process_links_and_images(path)

      mdlinks = therenderer.links
      mdimages = therenderer.images

      #   p mdlinks.size, mdimages
      mdlinks.each do |mdlink|
        link = mdlink.url
        next if link.starts_with?("http") || link.starts_with?("#") || link.starts_with?("/")

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
          # TODO: make sure we fix links written in windows machine \ -> /
          if link != newlink
            newcontent = content.gsub link, newlink
            content = newcontent
            puts "[linksfixer]old link is #{link}  and new link should be #{newlink} in #{therenderer.filepath}".colorize(:blue) if link != newlink
          end
        end
      end

      #   puts "abdo #{images}"
      mdimages.uniq.each do |mdimg|
        img = mdimg.url
        next if img.includes?("/img")

        unless img.starts_with?("http")
          # on filesystem
          # TODO: probably should check if has extension instead
          next unless img.ends_with?(".png") || img.ends_with?(".jpg") || img.ends_with?(".jpeg")
          baseimg = File.basename(img)
          newimg = File.basename(img)

          newimg = newimg.downcase.gsub({"-": "_"})

          if File.exists?(Path.new(path.dirname, "img", baseimg))
            newimg = "./img/#{newimg}"
          end
          puts "#{path.to_s} [imagefixer]old img is #{baseimg}  and new img should be #{newimg} in #{therenderer.filepath}".colorize(:blue) if img != newimg

          newcontent = content.gsub(img, newimg)
          content = newcontent
        end
      end

      @all_mdimages.concat mdimages
      @all_mdlinks.concat mdlinks
      if all_mdimages.size > 0 || all_mdlinks.size > 0
        File.write(path, content)
      end
      path
    end
  end
end
