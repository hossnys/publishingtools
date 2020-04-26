require "./processor"
require "./processors/*"
require "file_utils"

module TFWeb
  class MarkdownDocs
    property dirfilesinfo

    #docspath is the path where we will fix and also remember
    def initialize (@docspath : String)

      @all_names = Set(String).new
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
      # {filename => {count: 5, paths=[] }}

      check_dups
      _fixer #does the walk
      # puts "errors #{w.errors}"
      _errors_as_md_write

    end

    def reload_dirfilesinfo()
      path = @docspath
      puts "reloading filesinfo"
      @dirfilesinfo = Hash(String, TFWeb::FInfoTracker).new

      Dir.glob(path + "/**/*").each do |child_path|
        next unless File.directory?(child_path)
        # files only..
        child = File.basename(child_path.to_s)
        if !@dirfilesinfo.has_key?(child.to_s)
          finfo = FInfoTracker.new
          finfo.count = 1
          finfo.paths = [child_path.to_s]
          @dirfilesinfo[child] = finfo
        else
          finfo = @dirfilesinfo[child]
          finfo.count += 1
          finfo.paths << child_path.to_s
          @dirfilesinfo[child] = finfo
        end
      end
    end

    def filesinfo
      @dirfilesinfo
    end

    def errors
      @errors
    end

    #write the errors as md
    def _errors_as_md_write()
      path = @docspath
      content = ""
      @errors.each do |filename, err|
        next if filename == "img" || filename == "_sidebar.md" || filename == "README.md"
        content = content + "# #{filename} \n"
        content = content + err + "\n"
      end
      File.write(File.join(path, "errors.md"), content)
    end

    def should_skip?(path)
      basename = File.basename(path)
      if @skips.includes?(basename)
        puts "[+] skipping #{basename}"
        return true
      end
    end

    def cp_r2(src_path : String, dest_path : String)
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

    def check_dups(path)
      if should_skip?(path)
        return
      end
      path_obj = Path.new(path)
      Dir.each_child path do |child|
        child_path = path_obj.join(child)
        if Dir.exists?(child_path) && child.downcase == "images"
          imgdir = path_obj.join("img").to_s
          if Dir.exists?(path_obj.join("img"))
            cp_r2(child_path.to_s, imgdir)
            FileUtils.rm_rf(child_path.to_s)
          else
            File.rename(child_path.to_s, imgdir) if File.exists?(child_path)
          end
        end
        if Dir.exists? child_path
          #   next if child.downcase == "img"
          check_dups child_path.to_s
        end
        if !@dirfilesinfo.has_key?(child.to_s)
          finfo = FInfoTracker.new
          finfo.count = 1
          finfo.paths = [child_path.to_s]
          @dirfilesinfo[child] = finfo
        else
          finfo = @dirfilesinfo[child]
          finfo.count += 1
          finfo.paths << child_path.to_s
          @dirfilesinfo[child] = finfo
        end

        @dirfilesinfo.each do |filename, theinfo|
          if theinfo.count > 1
            @errors[filename] = "#{theinfo.count.to_s} times. in paths #{theinfo.paths}\n\n"
          end
        end
      end
    end

    #walk over filesystem to buildup the fixer
    def fixer(path)
      if should_skip?(path)
        return
      end
      path_obj = Path.new(path)
      Dir.each_child path do |child|
        if child[0] != "."
          begin
            child_path = path_obj.join(child)
            if @namefixer.match(child)
              @namefixer.process(path_obj, child)
            end
            if Dir.exists? child_path
              if child.downcase == "img"
                next
              end
              fixer child_path.to_s
            else
              if @linksimagesfixer.match(child)
                @linksimagesfixer.process(path_obj, child)
              end
              if @imgdirrenamer.match(child)
                @imgdirrenamer.process(path_obj, child)
              end
              #   if @readme.match(child)
              #     @readme.process(path_obj, child)
              #   end
              if @linksimagesfixer.match(child)
                @linksimagesfixer.process(path_obj, child)
              end
              if @img.match(child)
                @img.process(path_obj, child)
              end
              if @md.match(child)
                @md.process(path_obj, child)
              end
              if @docsifysidebarfixer.match(child)
                @docsifysidebarfixer.process(path_obj, child)
              end
              if @docsifyreadmefixer.match(child)
                @docsifyreadmefixer.process(path_obj, child)
              end
            end
          rescue ex
            puts ex
          end
        end
      end
    end
  end
end
