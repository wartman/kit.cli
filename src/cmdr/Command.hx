package cmdr;

enum CommandValidation {
  Valid;
  Invalid(message:String);
}

@:autoBuild(cmdr.CommandBuilder.build())
abstract class Command {
  abstract public function getName():String;
  
  abstract public function getDescription():Null<String>;

  abstract function bind(input:Input):Void;

  abstract function process(input:Input, output:Output):ExitCode;

  abstract function validate(input:Input):CommandValidation;

  abstract public function getArgumentsAndOptionSummery():String;
  
  abstract public function getArgumentsAndOptionHelp():Array<String>;
  
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
    return 'Usage: ' + getName() + ' ' + getArgumentsAndOptionSummery();
  }

  public function toString() {
    return getSummery().join('\n');
  }

  function displayHelp(name:Null<String>, output:Output):ExitCode {
    output.writeLn(...getSummery());
    return Success;
  }

  final public function execute(input:Input, output:Output):ExitCode {
    return try switch (input.findOption('--help')) {
      case Some(value):
        displayHelp(value, output);
      case None: switch validate(input) {
        case Valid:
          bind(input);
          process(input, output);
        case Invalid(message):
          output.writeLn(message, '', getUsageMessage());
          Failure;
      }
    } catch (e) {
      output.writeLn('Error: ' + e.message, '', getUsageMessage());
      Failure;
    }
  }
}
