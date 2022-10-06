package cmdr;

import haxe.ds.Option;

enum CommandValidation {
  Valid;
  Invalid(message:String);
}

@:autoBuild(cmdr.CommandBuilder.build())
abstract class Command {
  // abstract public function getName():String;
  
  abstract public function getDescription():Null<String>;

  abstract function bind(input:Input):Void;

  abstract function process(input:Input, output:Output):ExitCode;

  abstract function validate(input:Input):CommandValidation;

  abstract public function getArgumentsAndOptionSummery():String;
  
  abstract public function getArgumentsAndOptionHelp():Array<String>;

  abstract public function getArgumentOrOptionUsage(name:String):Option<String>;

  abstract public function getSubcommandUsage(name:String):Option<String>;

  abstract public function maybeExecuteSubcommand(input:Input, output:Output):Option<ExitCode>;

  abstract public function listSubcommands():Array<String>;
  
  public function getSummery():Array<String> {
    var parts:Array<String> = [''];
    var desc = getDescription();

    if (desc != null) {
      parts.push(desc);
    }

    return parts.concat([
      '',
      getUsageMessage(),
      ''
    ]).concat(getArgumentsAndOptionHelp());
  }

  function getUsageMessage() {
    return 'Usage: ' + getArgumentsAndOptionSummery();
  }

  public function toString() {
    return getSummery().join('\n');
  }

  function displayHelp(name:Null<String>, output:Output):ExitCode {
    if (name != null) {
      switch getSubcommandUsage(name) {
        case Some(help): 
          output.writeLn(help);
        case None: switch getArgumentOrOptionUsage(name) {
          case Some(help):
            output.writeLn(help);
          case None:
            output.writeLn('No subcommand, argument or option with the name $name exists');
            output.writeLn(...getSummery());
        }
      }
      return Success;
    }
    output.writeLn(...getSummery());
    return Success;
  }

  final public function execute(input:Input, output:Output):ExitCode {
    return try {
      switch maybeExecuteSubcommand(input, output) {
        case Some(exitCode):
          return exitCode;
        case None: switch (input.findOption('--help')) {
          case Some(value):
            displayHelp(value == 'true' ? null : value, output);
          case None: switch validate(input) {
            case Valid:
              bind(input);
              process(input, output);
            case Invalid(message):
              output.writeLn(message, '', getUsageMessage());
              Failure;
          }
        }
      }
    } catch (e) {
      output.writeLn('Error: ' + e.message, '', getUsageMessage());
      Failure;
    }
  }
}
