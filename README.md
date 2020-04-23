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

To use for fixing the file structure:

```bash
./bin/tfwiki {docs directory}
```

This will perform the following:

- Makes sure that no duplicate names exists.Takes into consideration the new values for `readme` files
- Renames `images` dir to `img`
- Move images to `img` folder
- Clean names(Removes space and downcase)
- Change `readme` to parent directory name

## Development

- to add new processor for filesystem add your rocessor in `src/tfwiki/fs/processors`
- register your processor in `src/tfwiki/fs/walker.cr` in `initialize` method
- and in `fixer` method use your processor `match` method on the file name and then  call your `process` method

## Contributing

1. Fork it (<https://github.com/your-github-user/mdbookfixer/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [kristof](https://github.com/your-github-user) - creator and maintainer
