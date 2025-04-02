package kit.cli.sys;

using kit.cli.StyleTools;

class SysConsole implements Console {
	public function new() {}

	public function write(value:String):Console {
		Sys.print(value);
		return this;
	}

	public function writeLine(value:String):Console {
		Sys.println(value);
		return this;
	}

	public function setCursorPosition(x:Int, ?y:Int):Console {
		// Zero idea if this is correct
		write('\033[${y ?? 0};${x}H');

		return this;
	}

	public function moveCursor(pos:Int):Console {
		if (pos > 0) {
			write('\033[${pos}C');
		} else {
			write('\033[${pos * -1}D');
		}

		return this;
	}

	public function error(message:String) {
		writeLine('')
			.write('    ')
			.write(' Error '.bold().backgroundColor(Red))
			.writeLine(' ${message}');
		return this;
	}

	public function exit(code:Int = 0) {
		Sys.exit(code);
	}

	public function clear() {
		write('\033[2K\033[200D');
		return this;
	}

	public function hideCursor() {
		write('\033[?25l');
		return this;
	}

	public function showCursor() {
		write('\033[?25h');
		return this;
	}

	public function read():String {
		return Sys.stdin().readString(1);
	}

	public function readLine():String {
		return Sys.stdin().readLine();
	}

	public function getArguments():Arguments {
		return Arguments.parse(Sys.args());
	}
}
