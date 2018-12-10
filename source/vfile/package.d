module vfile;

import core.stdc.stdlib;
import core.stdc.string : memcpy;
import std.stdio;

/**
 * Implements the virtual file.
 */
public struct VFile{
	enum Orientation { unknown, narrow, wide }
	private void[] datastream;
	private size_t position;
	private string name;			///mostly a placeholder, but can be set if needed

	/**
	 * Creates a virtual file out from an array.
	 */
	public this(T)(ref T[] target, string name = null){
		datastream = cast(void[])target;
		this.name = name;
	}
	/**
	 * Creates a virtual file out from a pointer and a length indicator.
	 */
	public this(void* ptr, size_t length, string name = null){
		datastream = ptr[0..length];
		this.name = name;
	}
	/**
	 * Indicates if the virtual file is opened.
	 * If the datastream isn't null, it must be open.
	 */
	public @safe @property @nogc bool isOpen(){
		return datastream !is null;
	}
	/**
	 * Closes the datastream.
	 */
	public @safe void close(){
		datastream = null;
	}
	/**
	 * Copies the data into the buffer and moves the file forward the length of the buffer.
	 * Returns null if EOF is reached.
	 */
	public T[] rawRead(T)(T[] buffer){
		const size_t remaining = datastream.length - position;
		if(position + buffer.length <= datastream.length){
			memcpy(buffer.ptr, datastream.ptr + position, buffer.length * T.sizeof);
			position += buffer.length * T.sizeof;
			return buffer;
		}else{
			return null;
		}
	}
	/**
	 * Reads a single element from the stream.
	 * Throws Exception if EOF reached.
	 * Important: Does not provide any complex serialization method, so structs must avoid heap managed fields like dynamic
	 * arrays. They should implement a custom serializer.
	 */
	public T read(T)(){
		T buffer;
		if(remaining + T.sizeof <= datastream.length){
			memcpy(&buffer, datastream.ptr + position, T.sizeof);
			position += T.sizeof;
			return buffer;
		}else{
			throw new Exception("EOF has been reached");
		}
	}
	/**
	 * Writes data into the datastream.
	 * If the stream is shorter, then it'll be extended.
	 */
	public void rawWrite(T)(T[] buffer){
		if(position + buffer.length >= datastream.length){
			datastream.length = position;
			datastream.length += buffer.length;
		}
		memcpy(datastream.ptr + position, buffer.ptr, buffer.length * T.sizeof);
		position += buffer.length;
		assert(position <= datastream.length);
	}
	/**
	 * Writes a single element to the stream.
	 * Throws Exception if EOF reached.
	 * Important: Does not provide any complex serialization method, so structs must avoid heap managed fields like dynamic
	 * arrays. They should implement a custom serializer.
	 */
	public T write(T)(T buffer){
		if(remaining + T.sizeof <= datastream.length){
			memcpy(datastream.ptr + position, &buffer, T.sizeof);
			position += T.sizeof;
			return buffer;
		}else{
			throw new Exception("EOF has been reached");
		}
	}
	/**
	 * Jumps to the given location.
	 */
	@nogc @property public void seek(long offset, int origin = SEEK_SET) @trusted{
		final switch(origin){
			case SEEK_SET:
				position = cast(sizediff_t)offset;
				break;
			case SEEK_CUR:
				position += cast(sizediff_t)offset;
				break;
			case SEEK_END:
				position = datastream.length + cast(sizediff_t)offset;
				break;
		}
		position = position > datastream.length ? datastream.length : position;
	}
	/**
	 * Returns the current position.
	 */
	@nogc @property public size_t tell(){
		return position;
	}
	/**
	 * Returns the size of the datastream.
	 */
	@nogc @property public size_t size(){
		return datastream.length;
	}

}
unittest{
	immutable string a = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum et libero dignissim, porta odio id, 
			sollicitudin quam. Suspendisse ultrices quis erat nec elementum. Phasellus sollicitudin vehicula nunc, vel 
			laoreet magna dictum eget. Pellentesque sit amet tellus ac mauris elementum bibendum sed in eros. Nullam nec ligula 
			id ligula egestas malesuada. Etiam et nulla nec nibh faucibus suscipit non id felis. Integer vulputate lobortis 
			neque, ut congue nisl suscipit at. Nullam ac ante eu orci viverra dapibus. \n";
	immutable string b = "Vivamus quis finibus mi. Proin lectus enim, convallis a libero a, condimentum eleifend nisl. Vestibulum 
			luctus malesuada orci a ornare. Curabitur orci dolor, ultricies ut malesuada nec, semper dictum justo. Ut vestibulum 
			nisl id velit congue, tristique porta sapien rutrum. Pellentesque ultricies id arcu non fermentum. Ut at est ex. Sed 
			elementum gravida risus, et cursus magna tincidunt nec. Morbi hendrerit efficitur neque, non ultricies quam maximus 
			in. Sed bibendum bibendum dui, egestas dignissim orci tincidunt porta. Sed nec aliquet leo, eu posuere massa. \n";
	string s;
	VFile file = VFile(s);
	file.rawWrite(a);
	file.rawWrite(b);
	assert(file.size == a.length + b.length);
	char[] c;
	c.length = a.length + b.length;
	file.seek(0);
	file.rawRead(c);
	assert(c == a ~ b);
	file.seek(0);
	c.length = 5;
	file.rawRead(c);
	assert(c == "Lorem");
}