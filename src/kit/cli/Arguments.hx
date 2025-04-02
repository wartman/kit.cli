package kit.cli;

class Arguments {
	public static function parse(tokens:Array<String>):Arguments {
		var tokens = expandAssignments(tokens);
		var optionsEnded = false;
		var pos = 0;
		var arguments:Array<String> = [];
		var flags:Map<String, String> = [];

		while (pos < tokens.length) {
			var token = tokens[pos];
			if (token == '--') {
				optionsEnded = true;
				pos++;
			} else if (!optionsEnded && token.charCodeAt(0) == '-'.code) {
				var next = tokens[pos + 1];
				if (next == null || next.charCodeAt(0) == '-'.code) {
					flags.set(token, 'true');
					pos++;
				} else {
					flags.set(token, next);
					pos++;
					pos++;
				}
			} else {
				arguments.push(token);
				pos++;
			}
		}

		return new Arguments(flags, arguments);
	}

	static function expandAssignments(tokens:Array<String>) {
		var output = [];
		var inOptionsMode = true;
		for (token in tokens) {
			if (token == '--') inOptionsMode = false;
			if (!inOptionsMode)
				output.push(token);
			else
				switch [token.charCodeAt(0), token.charCodeAt(1), token.indexOf('=')] {
					case ['-'.code, '-'.code, i] if (i != -1):
						output.push(token.substr(0, i));
						output.push(token.substr(i + 1));
					default:
						output.push(token);
				}
		}
		return output;
	}

	final arguments:Array<String>;
	final flags:Map<String, String>;

	public function new(flags, arguments) {
		this.flags = flags;
		this.arguments = arguments;
	}

	public function findFlag(name:String, ?shortName:String):Maybe<String> {
		var value = flags.get(name);
		if (value == null && shortName != null) {
			value = flags.get(shortName);
		}
		return value == null ? None : Some(value);
	}

	public function getFlags() {
		return flags;
	}

	public function getArguments() {
		return arguments;
	}
}
