crystal_doc_search_index_callback({"repository_name":"github.com/threefoldtech/builders","body":"# mdbookfixer\n\nworks together with mdbook tool written in rust\n\naim is that it will work as pre-processor and fix the mdbook items and also execute macro's\n\n## first functionality is \n\n - fix links to docs & images\n - rename paths of each doc/image to lowercase, _ (no spaces, or uppercases or other special chars)\n - make sure all images are in subfolder /img of where the image has been found first\n - each doc/image has a unique name (lower case) and can be referenced like that\n - when readme.md (make sure to lowercase found file) found in a dir \n     - replace name to $dirname.lowercase() and check is unique !\n\n## why\n\nthe aim is more easy of use for users\n\n- that users only refereces images and other docs by name only.\n- they see list of errors e.g. broken links to docs inside the repo or images\n- file names become consistent (lower case, no spaces) : easier to reference\n- keep it super fast\n- provide some userfriendly macros: e.g. include file from other repo\n\n## how to use\n\n- standallone, means from directory run the tool\n- as mdbook preprocessor (md links are changed to full paths in mem only not on disk)\n- the markdown docs are changed & files renamed\n\n## Installation\n\nTODO: Write installation instructions here\n\n## Usage\n\nTODO: Write usage instructions here\n\n## Development\n\nTODO: Write development instructions here\n\n## Contributing\n\n1. Fork it (<https://github.com/your-github-user/mdbookfixer/fork>)\n2. Create your feature branch (`git checkout -b my-new-feature`)\n3. Commit your changes (`git commit -am 'Add some feature'`)\n4. Push to the branch (`git push origin my-new-feature`)\n5. Create a new Pull Request\n\n## Contributors\n\n- [kristof](https://github.com/your-github-user) - creator and maintainer\n","program":{"html_id":"github.com/threefoldtech/builders/toplevel","path":"toplevel.html","kind":"module","full_name":"Top Level Namespace","name":"Top Level Namespace","abstract":false,"superclass":null,"ancestors":[],"locations":[],"repository_name":"github.com/threefoldtech/builders","program":true,"enum":false,"alias":false,"aliased":"","const":false,"constants":[{"id":"DOC_REGEX","name":"DOC_REGEX","value":"/(.*)(.md$)/","doc":null,"summary":null},{"id":"IMAGE_REGEX","name":"IMAGE_REGEX","value":"/(.*)(.jpg$)|(.*)(.jpeg$)|(.*)(.svg$)|(.*)(.png$)/","doc":null,"summary":null},{"id":"LINK_REGEX1","name":"LINK_REGEX1","value":"/\\[[\\.\\w -\\:]*\\]\\(.+\\)/","doc":"LINK_REGEX = /(\\[[\\.\\w -\\:]*\\]$)(.md$)/","summary":"<p>LINK_REGEX = /(\\[[\\.\\w -\\:]*\\]$)(.md$)/</p>"},{"id":"LINK_REGEX2","name":"LINK_REGEX2","value":"/\\[[\\.\\w -\\:]*\\]$/","doc":null,"summary":null},{"id":"R","name":"R","value":"[LINK_REGEX1, LINK_REGEX2]","doc":"TODO: also need to match: <img src=img/3bot_wallet_4.png height=\"450\"> #TODO:","summary":"<p><span class=\"flag orange\">TODO</span>  also need to match: &lt;img src=img/3bot_wallet_4.png height=\"450\"> #TODO:</p>"}],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":null,"summary":null,"class_methods":[],"constructors":[],"instance_methods":[],"macros":[],"types":[{"html_id":"github.com/threefoldtech/builders/DocObj","path":"DocObj.html","kind":"class","full_name":"DocObj","name":"DocObj","abstract":false,"superclass":{"html_id":"github.com/threefoldtech/builders/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"github.com/threefoldtech/builders/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"github.com/threefoldtech/builders/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"mdbookobj.cr","line_number":26,"url":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr"}],"repository_name":"github.com/threefoldtech/builders","program":false,"enum":false,"alias":false,"aliased":"","const":false,"constants":[],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":"represents a full blown markdown document","summary":"<p>represents a full blown markdown document</p>","class_methods":[],"constructors":[{"id":"new(path:String)-class-method","html_id":"new(path:String)-class-method","name":"new","doc":null,"summary":null,"abstract":false,"args":[{"name":"path","doc":null,"default_value":"","external_name":"path","restriction":"String"}],"args_string":"(path : String)","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr#L29","def":{"name":"new","args":[{"name":"path","doc":null,"default_value":"","external_name":"path","restriction":"String"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"_ = allocate\n_.initialize(path)\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"id":"process(mdbook:MDBook)-instance-method","html_id":"process(mdbook:MDBook)-instance-method","name":"process","doc":"will find all links and see if they are pointing to existing doc or image","summary":"<p>will find all links and see if they are pointing to existing doc or image</p>","abstract":false,"args":[{"name":"mdbook","doc":null,"default_value":"","external_name":"mdbook","restriction":"MDBook"}],"args_string":"(mdbook : MDBook)","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr#L33","def":{"name":"process","args":[{"name":"mdbook","doc":null,"default_value":"","external_name":"mdbook","restriction":"MDBook"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"@mdbook = mdbook\n(File.read_lines(@path)).each do |line|\n  R.each do |regex|\n    m = line.match(regex)\n    if m\n      if !@path_printed\n        puts(\" - link(s) found in: #{@path}\")\n        @path_printed = true\n      end\n      puts(\"   - link: #{m[0]}\")\n    end\n  end\nend\n"}},{"id":"processlink(link:LinkObj)-instance-method","html_id":"processlink(link:LinkObj)-instance-method","name":"processlink","doc":null,"summary":null,"abstract":false,"args":[{"name":"link","doc":null,"default_value":"","external_name":"link","restriction":"LinkObj"}],"args_string":"(link : LinkObj)","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr#L48","def":{"name":"processlink","args":[{"name":"link","doc":null,"default_value":"","external_name":"link","restriction":"LinkObj"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":""}}],"macros":[],"types":[]},{"html_id":"github.com/threefoldtech/builders/ImageObj","path":"ImageObj.html","kind":"class","full_name":"ImageObj","name":"ImageObj","abstract":false,"superclass":{"html_id":"github.com/threefoldtech/builders/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"github.com/threefoldtech/builders/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"github.com/threefoldtech/builders/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"mdbookobj.cr","line_number":55,"url":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr"}],"repository_name":"github.com/threefoldtech/builders","program":false,"enum":false,"alias":false,"aliased":"","const":false,"constants":[],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":null,"summary":null,"class_methods":[],"constructors":[{"id":"new(path:String)-class-method","html_id":"new(path:String)-class-method","name":"new","doc":null,"summary":null,"abstract":false,"args":[{"name":"path","doc":null,"default_value":"","external_name":"path","restriction":"String"}],"args_string":"(path : String)","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr#L58","def":{"name":"new","args":[{"name":"path","doc":null,"default_value":"","external_name":"path","restriction":"String"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"_ = allocate\n_.initialize(path)\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"id":"process(mdbook:MDBook)-instance-method","html_id":"process(mdbook:MDBook)-instance-method","name":"process","doc":null,"summary":null,"abstract":false,"args":[{"name":"mdbook","doc":null,"default_value":"","external_name":"mdbook","restriction":"MDBook"}],"args_string":"(mdbook : MDBook)","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr#L61","def":{"name":"process","args":[{"name":"mdbook","doc":null,"default_value":"","external_name":"mdbook","restriction":"MDBook"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"@mdbook = mdbook"}},{"id":"resize-instance-method","html_id":"resize-instance-method","name":"resize","doc":"will resize image to reasonable size\nthe original image will be kept but will become $name.original.$ext (moved)\nthe new image will be in line with size as requested but no more than 1200x1200\nkeep aspect ratio","summary":"<p>will resize image to reasonable size the original image will be kept but will become $name.original.$ext (moved) the new image will be in line with size as requested but no more than 1200x1200 keep aspect ratio</p>","abstract":false,"args":[],"args_string":"","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr#L68","def":{"name":"resize","args":[],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":""}}],"macros":[],"types":[]},{"html_id":"github.com/threefoldtech/builders/LinkObj","path":"LinkObj.html","kind":"class","full_name":"LinkObj","name":"LinkObj","abstract":false,"superclass":{"html_id":"github.com/threefoldtech/builders/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"github.com/threefoldtech/builders/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"github.com/threefoldtech/builders/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"mdbookobj.cr","line_number":14,"url":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr"}],"repository_name":"github.com/threefoldtech/builders","program":false,"enum":false,"alias":false,"aliased":"","const":false,"constants":[],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":null,"summary":null,"class_methods":[],"constructors":[{"id":"new(path:String)-class-method","html_id":"new(path:String)-class-method","name":"new","doc":null,"summary":null,"abstract":false,"args":[{"name":"path","doc":null,"default_value":"","external_name":"path","restriction":"String"}],"args_string":"(path : String)","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr#L16","def":{"name":"new","args":[{"name":"path","doc":null,"default_value":"","external_name":"path","restriction":"String"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"_ = allocate\n_.initialize(path)\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"id":"process(mdbook:MDBook)-instance-method","html_id":"process(mdbook:MDBook)-instance-method","name":"process","doc":null,"summary":null,"abstract":false,"args":[{"name":"mdbook","doc":null,"default_value":"","external_name":"mdbook","restriction":"MDBook"}],"args_string":"(mdbook : MDBook)","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr#L20","def":{"name":"process","args":[{"name":"mdbook","doc":null,"default_value":"","external_name":"mdbook","restriction":"MDBook"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"@mdbook = mdbook"}}],"macros":[],"types":[]},{"html_id":"github.com/threefoldtech/builders/MDBook","path":"MDBook.html","kind":"class","full_name":"MDBook","name":"MDBook","abstract":false,"superclass":{"html_id":"github.com/threefoldtech/builders/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"github.com/threefoldtech/builders/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"github.com/threefoldtech/builders/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"mdbook.cr","line_number":5,"url":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbook.cr"}],"repository_name":"github.com/threefoldtech/builders","program":false,"enum":false,"alias":false,"aliased":"","const":false,"constants":[],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":"MDBook fixer starting obj","summary":"<p>MDBook fixer starting obj</p>","class_methods":[],"constructors":[{"id":"new(path:String)-class-method","html_id":"new(path:String)-class-method","name":"new","doc":null,"summary":null,"abstract":false,"args":[{"name":"path","doc":null,"default_value":"","external_name":"path","restriction":"String"}],"args_string":"(path : String)","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbook.cr#L11","def":{"name":"new","args":[{"name":"path","doc":null,"default_value":"","external_name":"path","restriction":"String"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"_ = allocate\n_.initialize(path)\nif _.responds_to?(:finalize)\n  ::GC.add_finalizer(_)\nend\n_\n"}}],"instance_methods":[{"id":"_docs_process-instance-method","html_id":"_docs_process-instance-method","name":"_docs_process","doc":"find all links in the doc\nfind all images in the doc, see they exist","summary":"<p>find all links in the doc find all images in the doc, see they exist</p>","abstract":false,"args":[],"args_string":"","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbook.cr#L51","def":{"name":"_docs_process","args":[],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"puts(\" - process docs\")\n@docs.each do |name, doc|\n  doc.process(self)\nend\n"}},{"id":"_errors_add-instance-method","html_id":"_errors_add-instance-method","name":"_errors_add","doc":"return markdown doc which lists all the errors nicely formatted\nthis errors doc will be added to the summary.md if exists at end !","summary":"<p>return markdown doc which lists all the errors nicely formatted this errors doc will be added to the summary.md if exists at end !</p>","abstract":false,"args":[],"args_string":"","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbook.cr#L67","def":{"name":"_errors_add","args":[],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":""}},{"id":"_images_process-instance-method","html_id":"_images_process-instance-method","name":"_images_process","doc":null,"summary":null,"abstract":false,"args":[],"args_string":"","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbook.cr#L58","def":{"name":"_images_process","args":[],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"puts(\" - process images\")\n@images.each do |name, image|\n  image.process(self)\nend\n"}},{"id":"_walk(path:String)-instance-method","html_id":"_walk(path:String)-instance-method","name":"_walk","doc":"walk over the paths recursive, find the markdown docs & images\nwill execute on the #TODO: name requirements (lower case, no spaces)\nwill make sure the name's are unique (per doc, or per image category)\nall errors will be captured","summary":"<p>walk over the paths recursive, find the markdown docs & images will execute on the #TODO: name requirements (lower case, no spaces) will make sure the name's are unique (per doc, or per image category) all errors will be captured</p>","abstract":false,"args":[{"name":"path","doc":null,"default_value":"","external_name":"path","restriction":"String"}],"args_string":"(path : String)","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbook.cr#L25","def":{"name":"_walk","args":[{"name":"path","doc":null,"default_value":"","external_name":"path","restriction":"String"}],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"d = Dir.open(path)\nd.each do |pathsub|\n  fullpath = File.join([path, pathsub])\n  m = pathsub.match(DOC_REGEX)\n  if m\n    puts(\" - doc: #{fullpath}\")\n    @docs[pathsub] = DocObj.new(fullpath)\n  end\n  m = pathsub.match(IMAGE_REGEX)\n  if m\n    @images[pathsub] = ImageObj.new(fullpath)\n    puts(\" - image: #{fullpath}\")\n  end\n  if File.directory?(fullpath)\n    if !(File.match?(\".*\", pathsub))\n      _walk(fullpath)\n    end\n  end\nend\n"}},{"id":"fix-instance-method","html_id":"fix-instance-method","name":"fix","doc":null,"summary":null,"abstract":false,"args":[],"args_string":"","source_link":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbook.cr#L14","def":{"name":"fix","args":[],"double_splat":null,"splat_index":null,"yields":null,"block_arg":null,"return_type":"","visibility":"Public","body":"_walk(@path)\n_docs_process()\n_images_process()\n_errors_add()\n"}}],"macros":[],"types":[]},{"html_id":"github.com/threefoldtech/builders/MDBookError","path":"MDBookError.html","kind":"class","full_name":"MDBookError","name":"MDBookError","abstract":false,"superclass":{"html_id":"github.com/threefoldtech/builders/Reference","kind":"class","full_name":"Reference","name":"Reference"},"ancestors":[{"html_id":"github.com/threefoldtech/builders/Reference","kind":"class","full_name":"Reference","name":"Reference"},{"html_id":"github.com/threefoldtech/builders/Object","kind":"class","full_name":"Object","name":"Object"}],"locations":[{"filename":"mdbookobj.cr","line_number":8,"url":"https://github.com/threefoldtech/builders/blob/eab0c665705d97e0f2a35920afc24de4bfa9cb5a/src/mdbookobj.cr"}],"repository_name":"github.com/threefoldtech/builders","program":false,"enum":false,"alias":false,"aliased":"","const":false,"constants":[],"included_modules":[],"extended_modules":[],"subclasses":[],"including_types":[],"namespace":null,"doc":null,"summary":null,"class_methods":[],"constructors":[],"instance_methods":[],"macros":[],"types":[]}]}})