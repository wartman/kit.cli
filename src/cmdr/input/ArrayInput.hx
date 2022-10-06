package cmdr.input;

import haxe.ds.Option;

using cmdr.input.InputParser;

class ArrayInput implements Input {
  final name:Null<String>;
  final rawArgs:Array<String>;
  final arguments:Array<String>;
  final options:Map<String, String>;
  
  public function new(?name, args:Array<String>) {
    this.name = name;
    this.rawArgs = args;
    var parsed = args.parse();
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

  public function getCommand():Option<String> {
    return name == null ? None : Some(name);
  }

  public function getSubcommand():Option<Input> {
    var name = rawArgs[0];
    if (name == null) return None;
    var nextArgs = rawArgs.slice(1);
    return Some(new ArrayInput(name, nextArgs));
  }
}
