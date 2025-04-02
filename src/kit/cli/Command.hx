package kit.cli;

@:autoBuild(kit.cli.CommandBuilder.build())
interface Command {
	public var arguments(get, never):Arguments;
	public var console(get, never):Console;
	public function process(arguments:Arguments, console:Console):Task<Int>;
	public function getSpec():Spec;
	public function getDocs():String;
}
