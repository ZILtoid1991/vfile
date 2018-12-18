# vfile
Implements a virtual file, meaning a memory location can be read and written like if it were a file, reducing overloads through the use of templates. Created by László Szerémi (https://twitter.com/ziltoid1991 https://www.patreon.com/ShapeshiftingLizard https://ko-fi.com/shapeshiftinglizard laszloszeremi@outlook.com).

Mostly compatible with Phobos'es std.stdio's File structure.

## Possible applications
* Use for loading directly from archives
* Avoiding disk usage during unittests
* Using memory as a file buffer
* Etc.

## Usage
### Code example
`import std.stdio;
import vfile;

LoadedObject loadSomething(F = File)(F file){
	HeaderStruct[1] header;
	file.rawRead(header);
	[...]
}
`

### dub.sdl
`dependency "vfile" version="*"`

### dub.json
`dependencies{
	"vfile" : "*"
}`
