package kit.cli.input;

class ArrayInput implements Input {
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
