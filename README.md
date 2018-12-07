# vfile
Reads and writes a memory location as if it were a file.

Mostly compatible with Phobos'es std.stdio's File structure.

## Possible applications
* Use for loading directly from archives
* Avoiding disk usage during unittests
* Using memory as a file buffer
* Etc.

## Usage
### dub.sdl
`dependency "vfile" version="*"`

### dub.json
`dependencies{
	"vfile" : "*"
}`