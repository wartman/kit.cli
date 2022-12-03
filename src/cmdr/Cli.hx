package cmdr;

class Cli {
  #if (sys || nodejs)
  public static function fromSys() {
    return new Cli(new cmdr.input.SysInput(), new cmdr.output.SysOutput());
  }
  #end

  final input:Input;
  final output:Output;

  public function new(input, output) {
    this.input = input;
    this.output = output;
  }

  public function execute(command:Command) {
    command.process(input, output, handleResult);
  }

  function handleResult(result:Result) {
    switch result {
      case Success: output.exit(0);
      case Failure(code): output.exit(code);
      case Async(handler): handler(handleResult);
    }
  }
}
