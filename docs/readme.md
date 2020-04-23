# Tfwiki

`tfwiki` is a tool to preprocess our wikis to make it easy to write links, includes...etc.

The tool does the following on book files before running `mdbook`:

- Report files with the same names, in that case, no further operation will be done, and the program will exit.
- Rename `README.md` to directory name
- Move every image file to `img` directory
- Rename files to a clean name by removing spaces and converting it to lower case.


Then it runs `mdbook` and set itself as a [preprocessor](https://rust-lang.github.io/mdBook/for_developers/preprocessors.html#preprocessors) for content, which will do the following:

- Update links as follows:
    * Use only file base name, remove spaces and make it lower case.
    * Update `README` to parent directory name.
    * Update image path to be in `img` sub-directory.

- Support `include` macro.


By default, it does all these steps, unless it's specified to run in `mdbook` [preprocessor](https://rust-lang.github.io/mdBook/for_developers/preprocessors.html#preprocessors) mode:

```
tfwiki -p
```

## Usage

## API
