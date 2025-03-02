package kit.cli.output;

class NullOutput implements Output {
	public function new() {}

	public function write(...value:String) {
		return this;
	}

	public function writeLn(...value:String) {
		return this;
	}

	public function error(message) {
		throw message;
		return this;
	}

	public function exit(code:Int = 0) {}
}
