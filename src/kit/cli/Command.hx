package kit.cli;

@:autoBuild(kit.cli.CommandBuilder.build())
interface Command {
	public var input(get, never):Input;
	public var output(get, never):Output;
	public function process(input:Input, output:Output):Task<Int>;
	public function getSpec():Spec;
	public function getDocs():String;
}
