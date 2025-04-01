package kit.cli.output;

using kit.cli.StyleTools;

class SysOutput implements Output {
	public function new() {}

	public function write(...value:String) {
		for (value in value) Sys.print(value);
		return this;
	}

	public function writeLn(...value:String) {
		for (value in value) Sys.println(value);
		return this;
	}

	public function error(message:String) {
		writeLn('')
			.write('    ')
			.write(' Error '.bold().backgroundColor(Red))
			.writeLn(' ${message}');
		return this;
	}

	public function exit(code:Int = 0) {
		Sys.exit(code);
	}

	public function clear(replaceWith:String = '') {
		// note: using ANSI CSI
		write('\033[2K\033[200D' + replaceWith);
	}

	public function hideCursor() {
		write('\033[?25l');
	}

	public function showCursor() {
		write('\033[?25h');
	}
}
