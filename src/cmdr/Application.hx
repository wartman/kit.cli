package cmdr;

using Lambda;

class Application {
  final commands:Array<Command>;
  var input:Null<Input> = null;

  public function new(commands) {
    this.commands = commands;
    this.commands.push(new HelpCommand(this));
  }

  public function getCommands() {
    return commands;
  }

  public function getCommand(name:String) {
    return commands.find(c -> c.getName() == name);
  }

  public function execute(input:Input, output:Output):ExitCode {
    return switch input.currentCommand() {
      case Some(name):
        var command = getCommand(name);
        if (command == null) {
          input.setOption('--invalidCommand', '-i', name);
          return getCommand('help').execute(input, output);
        }
        command.execute(input, output);
      case None:
        return getCommand('help').execute(input, output);
        Failure;
    }
  }
}
