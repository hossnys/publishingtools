require "./processor"
require "./processors/*"
require "file_utils"

module TFWeb
  class MarkdownDocs
    property dirfilesinfo
    property docspath

    # docspath is the path where we will fix and also remember
    def initialize(@docspath : String)
      @imgdirrenamer = ImagesDirProcessor.new
      @img = ImageProcessor.new
      @md = MdProcessor.new
      @readme = ReadMeProcessor.new
      @linksimagesfixer = LinksImagesProcessor.new
      @docsifysidebarfixer = DocsifySidebarFixerProcessor.new
      @docsifyreadmefixer = DocsifyReadmeFixerProcessor.new
      @namefixer = NameFixerProcessor.new

      @skips = [".git", "_archive", "out"]
      @errors = Hash(String, String).new
      @dirfilesinfo = Hash(String, TFWeb::FInfoTracker).new

      @all_links = Array(String).new
      @all_images = Array(String).new
      # {filename => {count: 5, paths=[] }}
    end

    def checks_dups_and_fix
      _fix @docspath # does the walk
      _check_dups(@docspath)

      write_errors_as_md
    end

    def filesinfo
      @dirfilesinfo
    end

    def errors
      @errors
    end

    # write the errors as md
    def write_errors_as_md
      path = @docspath
      content = ""
      @all_links.each do |l|
        # puts "errors for link: #{l}"
        baselink = File.basename(l)
        next if l.starts_with?("http") || @dirfilesinfo.has_key?(baselink) || l.starts_with?("#") || l.includes?("_archive") || l.includes?("_beta")
        # puts "error link  #{l} #{baselink} is used but doesn't exist in the repo."
        @errors[baselink + " link"] = "#{baselink} is used but doesn't exist in the repo."
      end
      @all_images.each do |im|
        baseimg = File.basename(im)
        # puts "errors for img: #{im}"
        next if @dirfilesinfo.has_key?(baseimg) || im.starts_with?("http") || im.includes?("_archive") || im.includes?("_beta")
        # puts "error image #{im} #{baseimg} is used but doesn't exist in the repo."
        @errors[baseimg + " img"] = "#{baseimg} is used but doesn't exist in the repo."
      end

      #   puts @errors
      @errors.each do |filename, err|
        # puts "#{filename} #{err}"
        has_no_ext = File.extname(filename) == ""
        next if filename == "img" || filename == "_sidebar.md" || filename == "README.md" || has_no_ext || filename.includes?("#")
        content = content + "# #{filename} \n"
        content = content + err + "\n"
      end
      puts "saving errors to #{File.join(path, "errors.md")}"
      errpath = File.join(path, "errors.md")
      File.write(errpath, content)
      # add errors.md to files
      ferrors = FInfoTracker.new

      ferrors.count = 1
      ferrors.paths << errpath
      @dirfilesinfo["errors.md"] = ferrors
      puts @dirfilesinfo.keys
    end

    private def should_skip?(path)
      basename = File.basename(path)
      if @skips.includes?(basename)
        puts "[+] skipping #{basename}"
        return true
      end
    end

    private def cp_r2(src_path : String, dest_path : String)
      if Dir.exists?(src_path)
        Dir.mkdir(dest_path) unless Dir.exists?(dest_path)
        Dir.each_child(src_path) do |entry|
          src = File.join(src_path, entry)
          dest = File.join(dest_path, entry)
          cp_r2(src, dest)
        end
      else
        FileUtils.cp(src_path, dest_path)
      end
    end

    private def _check_dups(path)
      if should_skip?(path)
        return
      end
      @dirfilesinfo = Hash(String, TFWeb::FInfoTracker).new # reset.
      Dir.glob("#{path}/**/*") do |thepath|
        next if Dir.exists?(thepath)

        child = File.basename(thepath)
        # next if child.starts_with?("_")
        if !@dirfilesinfo.has_key?(child.to_s)
          finfo = FInfoTracker.new
          finfo.count = 1
          finfo.paths = [thepath.to_s]
          @dirfilesinfo[child] = finfo
        else
          finfo = @dirfilesinfo[child]
          finfo.count += 1
          finfo.paths << thepath.to_s
          @dirfilesinfo[child] = finfo
        end
      end

      @dirfilesinfo.each do |filename, theinfo|
        if theinfo.count > 1
          @errors[filename] = "#{theinfo.count.to_s} times. in paths #{theinfo.paths}\n\n"
        end
      end
    end

    # walk over filesystem to buildup the fixer
    private def _fix(path)
      if should_skip?(path)
        return
      end

      seen = Array(String).new
      Dir.glob("#{path}/**/*") do |thepath|
        next if thepath == "#{docspath}/README.md"
        next if thepath == "#{docspath}/readme.md"
        # if seen.includes?(thepath)
        #   puts "seen it before #{thepath}"
        # end
        next if seen.includes?(thepath)
        seen << thepath.to_s

        path_obj = Path.new(File.dirname(thepath))
        child = File.basename(thepath)
        next if child.starts_with?("_")
        procs = [@namefixer, @readme, @img, @md, @docsifyreadmefixer, @docsifysidebarfixer, @linksimagesfixer, @imgdirrenamer] of Processor
        procs.each do |p|
          begin
            # puts "thepath: #{thepath}"
            # puts "currentprocessor: #{p}"
            if p.match(child)
              thepath = p.process(path_obj, child)
              #   puts "thepath: after processing: #{thepath}"
              thepath.try do |apath|
                path_obj = Path.new(File.dirname(apath))
                child = File.basename(apath)
              end
            end
          rescue exception
            puts "error in #{p} for #{child} in #{path_obj} #{exception}"
            # raise exception
          end
        end

        @linksimagesfixer.all_images.each do |im|
          unless @all_images.includes?(im)
            @all_images << im
          end
        end
        @linksimagesfixer.all_links.each do |l|
          unless @all_links.includes?(l)
            @all_links << l
          end
        end
      end
    end
  end
end
