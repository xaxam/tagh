# TAGH
Version 1.0.0

*Tagh* is a command-line tool to work with tags in plain text (markdown) files. There are two formats *tagh* can currently process: #hashtags and tags in YAML meta data headers.

## Installation
*Tagh* is a simple ruby script that depends on thor. Install the thor gem is you do not already have it:

    gem install thor

Put the *tagh*-folder anywhere, and create a symbolic link in /usr/local/bin: open the terminal, navigate to the *tagh*-folder, and run:

    ln -s tagh.rb /usr/local/bin/tagh

That’s it. Type `tagh` in your terminal and you should be presented with a summary of the commands. Tested under Mac OSX 10.7 and Ruby 1.9 and nowhere else...

## Usage
*Tagh* has four commands – tagh list, tagh find, tagh merge, and tagh delete:

### tagh list [arguments]
List tags.

*Arguments:* 

    - source, -s:   The source folder(s). Multiple sources are allowed and take the form 
                    -s /path/to/a-folder /path/to/b-folder. By default, the current 
                    directory is used. 
    - file, -f:     Write output to file: tagh list -f taglist.txt
    - flat:         prints a list of tags in single quotation marks delimited by spaces.
    - min:          Only list tags that occur min. times. 
    - max:          Only list tags that occur max. times.
    - sublime, -u:  Write a json file for sublime auto-completion. 

### tagh find TAG [arguments]
Find items tagged TAG.

*Arguments:*

    - source, -s: see above.
    - file, -f: Write output to file. 
    - open, -o: Open matched files in new Sublime Text window.

### tagh merge TAGS [arguments]
Merge a list of TAGS into the last one specified. If only two TAGS are given, merge renames TAG1 as TAG2. Examples:

`tagh merge one two three`: merges tags 'one' and 'two' into tag 'three'.

`tagh merge old new`: renames tag 'old' into 'new'.

*Arguments:*

    - source, -s: see above

### tagh delete TAG [arguments]
Deletes TAGS from all files in the given directory. Example:

`tagh delete one two three`: deletes all three tags in all files in the current directory

*Arguments:*

    - source, -s: see above.


## Purpose
Plain text documents written in markdown are at the core of my note-taking, research, writing, and publishing workflows. I use Twitter-style #hashtags to tag sections[^1] in longer markdown documents (transcripts, field notes, etc.) and YAML metadata headers for tags that refer to entire documents, for example blog posts or short notes. The purpose of *tagh* is to make it easier to handle and manipulate these tag sets in collections of documents.

---
[^1]: A section is defined as a text delimited by a heading, a horizontal rule, or the beginning/end of the document.