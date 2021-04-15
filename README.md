# MdTiny Blog Script

A very tiny blog script :
- source articles in [Markdown](https://commonmark.org/) format
- blog script written in [Perl](https://www.perl.org/) 
- library [CMark](https://github.com/commonmark/cmark) to translate Markdown to HTML
- library [Source-Highlight](https://www.gnu.org/software/src-highlite/) to highlight `<code>` in the HTML

## Basic usage

- You write your article using a Markdown editor
- You save your article as an `.md` file in the `source/` directory.
- You run the blog script `script_export.pl`
- You get your article as `.html` in the `export/` directory !

## Basic Info

### Requirements

The Perl Script calls `cmark` and `source-highlight` so you must have them in your path. Normally when you install these two packages they will be known by these names.

The minimal blog structure is the two directories `source/` and `source/data/` and two possibly empty files `source/top.html` and `source/bot.html`.

The Perl script uses Perl libraries `File::Basename`, `HTML::Entities` and `IPC::Open3`.

### "top.html" and "bot.html"

These are the two .html files automatically included at the beginning and the end of every article. \
`top.html` contains for example the `<head>`, with a link to an eventual css file.\
The `<title>` is automatically filled with the content of the first `<h1>` found in the article.\
`bot.html` contains for example the `<footer>`.

### Images, CSS, javascripts and other data

These must all go into the `source/data/` directory. \
The blog script creates a symlink of `source/data/` in `export/data`.\
So both `source/` and `export/` points to `source/data/` directory.\
You can create sub-directories inside `source/data/`.

Modifying a data (a `css` file or an image) does not imply to re-export, since `export/data` is linked to `source/data/`.

### Deleting the "export/" directory 

Careful ! `export/data` is a symlink to `source/data` !\
So `rm -r export/data/` (with the `/` at the end) will delete `source/data/` !

Just use `rm -r export/` and it will not follow the symlink.

The blog script will create `export/` and `export/data` if they do not exist. So as long as you are careful it is fine to delete `export/`.

### Example

This github repository contains itself a little example. You will find two articles in `source/` with a `css` file in `source/data/css`. The result of `script_export.pl` is in the `export/` directory. 

## Todo and ideas

- an automatic summary generated at the beginning of each article

- an automatic list of articles for the index page

- categories/tags for organizing articles

  