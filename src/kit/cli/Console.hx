package kit.cli;

interface Console {
	public function write(value:String):Console;
	public function writeLine(value:String):Console;
	public function setCursorPosition(x:Int, ?y:Int):Console;
	public function error(message:String):Console;
	public function clear():Console;
	public function hideCursor():Console;
	public function showCursor():Console;
	// public function debug(message:String):Console;
	public function exit(code:Int = 0):Void;
	public function read():String;
	public function readLine():String;
	public function getArguments():Arguments;
}
