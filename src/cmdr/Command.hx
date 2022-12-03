package cmdr;

@:autoBuild(cmdr.CommandBuilder.build())
interface Command {
  public var input(get, never):Input;
  public var output(get, never):Output;
  public function process(input:Input, output:Output, finish:(result:Result)->Void):Void;
  public function getSpec():DocSpec;
  public function getDocs():String;
}
