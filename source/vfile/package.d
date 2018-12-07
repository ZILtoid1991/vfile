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
		if(remaining + buffer.length <= datastream.length){
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
	public T read(T){
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
		const size_t remaining = datastream.length - position;
		if(remaining + buffer.length <= datastream.length){
			memcpy(datastream.ptr + position, buffer.ptr, buffer.length * T.sizeof);
			position += buffer.length;
		}else{
			datastream.length = remaining;
			datastream ~= cast(void[])buffer;
		}
	}
	/**
	 * Writes a single element to the stream.
	 * Throws Exception if EOF reached.
	 * Important: Does not provide any complex serialization method, so structs must avoid heap managed fields like dynamic
	 * arrays. They should implement a custom serializer.
	 */
	public T write(T){
		T buffer;
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