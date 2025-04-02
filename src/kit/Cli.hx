package kit;

@:noUsing typedef Command = kit.cli.Command;
@:noUsing typedef Console = kit.cli.Console;
typedef StyleTools = kit.cli.StyleTools;

class Cli {
	#if (sys || nodejs)
	public static function fromSys() {
		return new Cli(new kit.cli.sys.SysConsole());
	}
	#end

	final console:Console;

	public function new(console) {
		this.console = console;
	}

	public function execute(command:Command) {
		command.process(console.getArguments(), console).handle(result -> switch result {
			case Ok(0):
				console.exit(0);
			case Ok(code):
				console.exit(code);
			case Error(error):
				console.error(error.message);
				console.exit(1); // @todo: figure out the right error code
		});
	}
}
