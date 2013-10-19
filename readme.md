tagh is a commandline tool (based on thor) to handle tags in plain text files. There are three formats that need to be taken into accout: #hashtags, system tags (OpenMeta, Maverick), tags in YAML headers. tagh handles and converts all three formats.

## Commands

### list [-s SOURCE] --occurrences >1
lists tags in SOURCE

### find TAG [-s SOURCE]


### merge TAG1 TAG2 NEWTAG [-s SOURCE]
also works as change. 



### strip TAG1 TAG2 [-s SOURCE]: Strips TAG1, TAG2 


### collect -t system [-s SOURCE]: collects #hashtags and add them to YAML, system


### move -f yaml -t system [-s SOURCE]: moves yaml tags to osx


### copy -f yaml -t system [-s SOURCE]: copies yaml tags to osx


### sync [-s SOURCE]: syncs yaml and osx system tags




* Can be file or folder. Current folder by default; multiple -s possible
