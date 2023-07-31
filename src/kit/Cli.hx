package kit;

@:noUsing typedef Command = kit.cli.Command;
@:noUsing typedef Input = kit.cli.Input;
@:noUsing typedef Output = kit.cli.Output;  
typedef StyleTools = kit.cli.StyleTools; 

class Cli {
  #if (sys || nodejs)
  public static function fromSys() {
    return new Cli(new kit.cli.input.SysInput(), new kit.cli.output.SysOutput());
  }
  #end

  final input:Input;
  final output:Output;

  public function new(input, output) {
    this.input = input;
    this.output = output;
  }

  public function execute(command:Command) {
    command.process(input, output).handle(result -> switch result {
      case Ok(0):
        output.exit(0);
      case Ok(code):
        output.exit(code);
      case Error(error):
        output.error(error.message); 
        output.exit(1); // @todo: figure out the right error code
    });
  }
}
