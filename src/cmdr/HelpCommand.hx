package cmdr;

@:command(
  name = 'help',
  description = 'Get help for each command'
)
class HelpCommand extends Command {
  @:arg(0) var command:String = null;

  final app:Application;

  public function new(app) {
    this.app = app;
  }

  function process(input:Input, output:Output):ExitCode {
    var invalidCommand = switch input.findOption('--invalidCommand') {
      case Some(v): v;
      case None: null;
    }

    if (invalidCommand != null) {
      invalidCommandName(invalidCommand, output);
      return Failure;
    }

    if (command != null) {
      var c = app.getCommand(command);
      if (c == null) {
        invalidCommandName(command, output);
        return Failure;
      }
      c.displayHelp(null, output);
      return Success;
    }

    var summeries = app.getCommands().map(c -> '    ' + c.getName() + ': ' + c.getDescription());
    output.writeLn(...[
      '',
      'Available commands:',
      ''
    ].concat(summeries));

    return Success;
  }

  function invalidCommandName(name:String, output:Output) {
    var names = app.getCommands().map(c -> c.getName());
    var toTry = names.length > 0 
      ? [ 'Did you mean one of these commands?', names.join(', ')]
      : [];
    output.writeLn(...[
      '',
      'The command $name does not exist.',
      ''
    ].concat(toTry));
  }
}
