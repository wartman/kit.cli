package kit.cli;

interface Input {
	public function findFlag(name:String, ?shortName:String):Maybe<String>;
	public function getFlags():Map<String, String>;
	public function getArguments():Array<String>;
}
