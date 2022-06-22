package cmdr;

@:autoBuild(cmdr.CommandBuilder.build())
abstract class Command {
  abstract public function getName():String;
  
  abstract public function getDescription():Null<String>;

  abstract function bind(input:Input):Void;

  abstract function process(input:Input, output:Output):ExitCode;
  
  public function getSummery():Array<String> {
    var parts:Array<String> = ['', 'Command: ' + getName(), ''];
    var desc = getDescription();

    if (desc != null) {
      parts.push(desc);
    }

    return parts.concat([
      '',
      'Usage:',
      '',
      '    ' + getName() + ' ' + getArgumentsAndOptionSummery() 
    ]);
  }

  abstract public function getArgumentsAndOptionSummery():String;
  // abstract function getHelp():String;

  public function toString() {
    return getSummery().join('\n');
  }

  function displayHelp(name:Null<String>, output:Output):ExitCode {
    output.writeLn(...getSummery());
    return Success;
  }

  final public function execute(input:Input, output:Output):ExitCode {
    return switch (input.findOption('--help')) {
      case Some(value):
        displayHelp(value, output);
      case None:  
        bind(input);
        process(input, output);
    }
  }
}
