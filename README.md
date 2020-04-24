# mdbookfixerr

works together with mdbook tool written in rust

aim is that it will work as pre-processor and fix the mdbook items and also execute macro's

## first functionality is

 - fix links to docs & images
 - rename paths of each doc/image to lowercase, _ (no spaces, or uppercases or other special chars)
 - make sure all images are in subfolder /img of where the image has been found first
 - each doc/image has a unique name (lower case) and can be referenced like that
 - when readme.md (make sure to lowercase found file) found in a dir
     - replace name to $dirname.lowercase() and check is unique !

## why

the aim is more easy of use for users

- that users only refereces images and other docs by name only.
- they see list of errors e.g. broken links to docs inside the repo or images
- file names become consistent (lower case, no spaces) : easier to reference
- keep it super fast
- provide some userfriendly macros: e.g. include file from other repo

## how to use

- standallone, means from directory run the tool
- as mdbook preprocessor (md links are changed to full paths in mem only not on disk)
- the markdown docs are changed & files renamed

## Installation

TODO: Write installation instructions here

## Usage

To use the cli, first build using `build.sh` script.

```bash
bash build.sh
```

A binary `tfwiki` will be created in repo root.

To use for fixing/serving:

```bash
➜  publishingtools git:(development) ✗ ./bin/tfwiki --help
Usage: tfwiki [arguments]
    -d WIKIPATH, --dir=WIKIPATH      Wiki dir root
    -f, --fix                        fix a dir
    -s, --server                     starts server
    -h, --help                       Show this help
```


This will perform the following:

- Makes sure that no duplicate names exists.Takes into consideration the new values for `readme` files
- Renames `images` dir to `img`
- Move images to `img` folder
- Clean names(Removes space and downcase)
- Change `readme` to parent directory name
- Convert images and links to basename if they don't start with `http` as indicator they are on the filesystem

## Development

- to add new processor for filesystem add your rocessor in `src/tfwiki/fs/processors`
- register your processor in `src/tfwiki/fs/walker.cr` in `initialize` method
- and in `fixer` method use your processor `match` method on the file name and then  call your `process` method
- the `TfWiki::Walker` in `walker.cr` has dirsfilesinfo hash that in the form of `{filename -> {count: number, paths=[]}}`. keeps track of every file occurrence in the repo, and also used to report errors in errors.md file.

## Docsify

index.html file in your wiki directory

```html
<!-- index.html -->

<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta charset="UTF-8">
  
  <link rel="stylesheet" href="//cdn.jsdelivr.net/npm/docsify/themes/vue.css">
</head>
<body>
  <div id="app"></div>
  <script>
    window.$docsify = {
        name: 'js-ng',
        loadSidebar: true,
        auto2top: true,

        search: 'auto', // default

        // complete configuration parameters
        search: {
            maxAge: 86400000, // Expiration time, the default one day
            paths: 'auto',
            placeholder: 'Type to search',
            noData: 'No Results!',
            // Headline depth, 1 - 6
            depth: 6,
            hideOtherSidebarContent: false, // whether or not to hide other sidebar content
        },
        
      //...
    }
  </script>
  <script src="//cdn.jsdelivr.net/npm/docsify/lib/docsify.min.js"></script> 
  <script src="//cdn.jsdelivr.net/npm/prismjs/components/prism-bash.min.js"></script>
  <script src="//cdn.jsdelivr.net/npm/prismjs/components/prism-python.min.js"></script>
  <script src="//unpkg.com/docsify/lib/plugins/search.min.js"></script>

</body>
</html>
```
here we activate search plugin, python, and bash highlighting 

## includes
you can use docsify includes like the following in your md files
```
 [nginx_ssl](nginx_ssl.md ':include')  
```
this will include `nginx_ssl.md` content in that file

### webix/iframes

webixexample.html

```
<!DOCTYPE HTML>
<html>
    <head>
    <link rel="stylesheet" href="//cdn.webix.com/edge/webix.cs
s" type="text/css"> 
    <script src="//cdn.webix.com/edge/webix.js" type="text/jav
ascript"></script>  
    </head>
    <body>
        <script type="text/javascript" charset="utf-8">
            
webix.ui({
  rows:[
      { view:"template", 
        type:"header", template:"My App!" },
      { view:"datatable", 
        autoConfig:true, 
        data:{
          title:"My Fair Lady", year:1964, votes:533848, rating:8.9, rank:5
        }
      }
  ]
});



        </script>
    </body>
</html>
```


and to include that in a markdown file `webix.md` just use the following snippet
```

[webixexample](webixexample.html ':include :type=iframe')
```

### wikiserver

`wikiserver.cr` has a kemal module to serve wiki files/images based on the filename only. so you can reference the filename from anywhere and it'll just work.

## Contributing

1. Fork it (<https://github.com/your-github-user/mdbookfixer/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [kristof](https://github.com/your-github-user) - creator and maintainer
