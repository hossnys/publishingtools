# blog 

has a complete [description](./blog.md)


# wiki
should be in a specific layout

```➜
mywiki git:(master) tree -L 1
.
├── LICENSE
├── README.md
├── src

```
- src dir contains all of your wiki content (used in configurations as a default, but can be overriden)
```
➜  src git:(master) tree -L 1
.
├── index.html
├── _navbar.md
├── _sidebar.md
├── src.md

```
- `_navbar.md`, `_sidebar.md`, `index.html` are docsify related files docsify.now.sh/configuration
- publishingtools generates index.html (from a docsify template to set the wiki title and the github URL banner and enabling some macros), it won't generate it if it exists

## links
- normal markdown linking
- link to a wiki page `[grid](wiki2:grid.md)` is equivalent to `[grid](/wiki2/#/grid.md)`
- link to a website page `[threefold team](threefold:public/#/team)` is equivalent to `[threefold team](https://threefold.io:public/#/team)`
- link to a blog page `[blog post](xmonblog:posts/nim-community-survey-2018-results)` is equivalnet to`[blog post](/blog/xmonblog/posts/nim-community-survey-2018-results)`
- also if you link by name in the wiki it will resolve to the first item if finds with that name
- if you link to an image by name it will resolve to the first one it finds

## includes

### Includes
You can include any markdown document from any wiki in other wikis, websites, or blogs.

#### Syntax:

```
!!!include:<wiki name>:<document name>
```
Also, inside current wiki, can be used as:
```
!!!include:<document name>
```

#### Examples

In wikis or blogs:

```
!!!include:crystaltwin:news.md
```




# website
Any static website in a git repo, publishingtools

```
~> ls mywebsite
src

~> ls src
index.html

```

- src dir is important and configurable in the publishingtools config


## include a markdown page in a static website

In websites, markdown need to be rendered as HTML, for example, markdown-element can be used:

### First, Include the script:


```
<script src="https://cdn.jsdelivr.net/npm/markdown-element/dist/markdown-element.min.js"></script>
```
### include the page
Then use it with include as the following in any part of the page:

<mark-down>
!!!include:crystaltwin:funding
</mark-down>
```
