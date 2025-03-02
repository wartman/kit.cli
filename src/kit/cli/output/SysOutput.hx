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
}
