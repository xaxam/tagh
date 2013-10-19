##### Attention: tagh.rb is hardlinked to /usr/local/bin/tagh ######

# Read Me

*tagh* is a commandline tool to handle tags in plain text files. There are two formats tagh  processes: #hashtags and tags in YAML meta data headers.

## Installation


### Dependencies


## Commands

### tagh list [arguments]
List tags.

*Arguments:*
- source, -s:     The source folder. By default, the current directory is used.
- sublime, -u:    Write a json file for sublime auto-completion.
- file, -f:       Write output to file.
- min:            Only list tags that occur min. times.
- max:            Only list tags that occur max. times.

### tagh find TAG [arguments]
Find items tagged TAG.

*Arguments:*
source, -s:     The source folder. By default, the current directory is used.
file, -f:       Write output to file.
open, -o:       Open matched files in new Sublime Text window

### tagh merge TAGS [arguments]
Merge a list of TAGS into the last one specified. If only two TAGS are given, merge renames TAG1 as TAG2.

*Arguments:*
source, -s:     The source folder. By default, the current directory is used.

### tagh delete TAG [arguments]
Deletes TAGS from all files in the given directory.

*Arguments:*
source, -s:     The source folder. By default, the current directory is used.