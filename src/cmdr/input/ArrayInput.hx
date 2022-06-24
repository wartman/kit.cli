package cmdr.input;

import haxe.ds.Option;

using cmdr.input.InputParser;

class ArrayInput implements Input {
  final arguments:Array<String>;
  final options:Map<String, String>;
  final command:Null<String>;
  
  public function new(args:Array<String>) {
    this.command = args[0];
    var parsed = args.slice(1).parse();
    this.arguments = parsed.arguments;
    this.options = parsed.options;
  }

  public function setOption(name:String, shortName:String, value:String) {
    options.set(name, value);
    options.set(shortName, value);
  }

  public function findOption(name:String, ?shortName:String):Option<Dynamic> {
    var value = options.get(name);
    if (value == null && shortName != null) {
      value = options.get(shortName);
    }
    return value == null ? None : Some(value);
  }

  public function getArguments() {
    return arguments;
  }

  public function findArgument(index:Int):Option<Dynamic> {
    var value = arguments[index];
    return value == null ? None : Some(value);
  }

  public function currentCommand():Option<String> {
    return command == null ? None : Some(command);
  }
}
