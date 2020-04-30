
# TFWebServer

## first functionality is

 - fix links to docs & images
 - rename paths of each doc/image to lowercase, _ (no spaces, or uppercases or other special chars)
 - make sure all images are in subfolder /img of where the image has been found first
 - each doc/image has a unique name (lower case) and can be referenced like that
     - other files will not be renamed, and to fetch them from webserver the full path is needed
     - for .md and .jpeg/... and other image files this means that http://$sitename/$filename.md is good enough to find the file back same for image (important all other files not like this)
     - the navigation markdown files can also be on different locations (don't have to be unique)
 - when readme.md (make sure to lowercase found file) found in a dir
     - replace name to $dirname.lowercase() and check is unique !

## why

the aim is more easy of use for users

- that users only reference images and other docs by name only.
- they see list of errors e.g. broken links to docs inside the repo or images
- file names become consistent (lower case, no spaces) : easier to reference
- keep it super fast
- provide some userfriendly macros: e.g. include file from other repo

## how to use

- standallone, means from directory run the tool
- the markdown docs are changed & files renamed
- the wiki & website is serverd

## Installation

TODO: Write installation instructions here
will be just downloading a binary or using brew on osx, to get the tfwiki tool
all will be embedded in the tfwiki tool !

## Usage

- #TODO: fix

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

## config file 

see [config_example.toml](config_example.toml)

allows you to specify the different wiki's & websites

## how do the different sites map?

http://$serverbaseurl:$port/$sitename/$path
for .md and html and images

the webserver will automatically based on $sitename (which is name in the config file) find the right index, md, img, file name

in production a e.g. caddy server is put in front which will do rewrite rules & proxy

e.g. https://www.threefold.io/$urlpart to http://localhost:3000/www_tf/$urlpart

## Docsify
the index.html is part of this tool and is automatically build depending your configuration file

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
