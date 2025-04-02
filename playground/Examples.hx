using Lambda;
using Kit;
using kit.Cli;
using kit.cli.display.TaskTools;

function main() {
	var cli = Cli.fromSys();
	cli.execute(new App());
}

class App implements Command {
	/**
		This does nothing.
	**/
	@:flag var off:Bool = false;

	/**
		This does nothing.
	**/
	@:flag('f') @:alias('bip') var foo:String = null;

	/**
		Get help for a given command
	**/
	@:flag var help:Bool = false;

	@:command final sub = new SubCommand('pre');

	public function new() {}

	/**
		This command will print whatever you give it.

		That's all.
	**/
	@:command
	public function other(bar:String = ''):Task<Int> {
		if (help) {
			console.write('Enter a string!'.backgroundColor(White).color(Red));
			return 0;
		}

		console
			.writeLine('We can do fun stuff with styles: '.underscore())
			.write(' This has a background '.backgroundColor(White).color(Blue).bold())
			.writeLine(bar.color(Red).bold());

		return 0;
	}

	@:command
	public function task():Task<Int> {
		return console.runTask(console -> {
			console.write("Working...");
			new Task(activate -> {
				haxe.Timer.delay(() -> activate(Ok(0)), 2000);
			});
		}).then(code -> {
			console.writeLine('Done');
			code;
		});
	}

	/**
		This is a simple app to explain how things work.
	**/
	@:defaultCommand
	public function docs():Task<Int> {
		console.write(getDocs());
		return 0;
	}
}

class SubCommand implements Command {
	/**
		Set the suffix
	**/
	@:flag('s') var suffix:String = 'Ok!';

	final prefix:String;

	public function new(prefix) {
		this.prefix = prefix;
	}

	/**
		Get help.
	**/
	@:command
	function help() {
		console.write(getDocs());
		return 0;
	}

	/**
		This also just prints foo.
	**/
	@:defaultCommand
	function doesAThing(foo:String, bin:String = 'ok'):Task<Int> {
		console.writeLine(prefix + ' ' + foo + bin + ' ' + suffix);
		return 0;
	}
}
