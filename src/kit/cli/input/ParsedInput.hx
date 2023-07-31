package kit.cli.input;

using kit.cli.internal.InputParser;

class ParsedInput extends ArrayInput {
  final rawArgs:Array<String>;
  
  public function new(args:Array<String>) {
    this.rawArgs = args;
    var parsed = args.parse();
    super(parsed.flags, parsed.arguments);
  }
}
