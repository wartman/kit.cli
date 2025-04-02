package kit.cli.display;

function runTask(console:Console, handler:(console:Console) -> Task<Int>):Task<Int> {
	var spinner = new Spinner(console);
	spinner.start();
	return handler(new TaskConsole(spinner, console)).always(() -> spinner.stop());
}

private class TaskConsole implements Console {
	final spinner:Spinner;
	final console:Console;

	public function new(spinner, console) {
		this.spinner = spinner;
		this.console = console;
	}

	public function write(value:String):Console {
		spinner.stop();
		console.write(value);
		spinner.start();
		return this;
	}

	public function writeLine(value:String):Console {
		spinner.stop();
		console.writeLine(value);
		spinner.start();
		return this;
	}

	public function setCursorPosition(x:Int, ?y:Int):Console {
		console.setCursorPosition(x, y);
		return this;
	}

	public function error(message:String):Console {
		spinner.stop();
		console.error(message);
		console.writeLine('');
		spinner.start();
		return this;
	}

	public function clear():Console {
		spinner.stop();
		console.clear();
		spinner.start();
		return this;
	}

	public function hideCursor():Console {
		// noop
		return this;
	}

	public function showCursor():Console {
		// noop
		return this;
	}

	public function exit(code:Int = 0) {
		spinner.stop();
		console.exit(code);
	}

	public function read():String {
		return console.read();
	}

	public function readLine():String {
		return console.readLine();
	}

	public function getArguments():Arguments {
		return console.getArguments();
	}
}
