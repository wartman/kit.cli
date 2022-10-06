import cmdr.input.SysInput;
import cmdr.output.SysOutput;
import cmdr.*;
import cmdr.style.DefaultStyles.*;

using Std;
using cmdr.style.StyleTools;

function main() {
  var app = new RootCommand();
  app.execute(
    new SysInput(),
    new SysOutput()
  );
}

class RootCommand extends Command {
  @:argument var bar:String;
  @:argument var bin:String = 'ok';
  
  @:option('o', description = 'Set the off') var off:Bool = false;
  @:option('f', description = 'Set the foo') var foo:String;

  @:command final other:OtherCommand = new OtherCommand();

  public function new() {}

  public function getDescription() {
    return 'Just a test';
  }

  public function process(input:Input, output:Output):ExitCode {
    output.writeLn(
      bar,
      bin.useStyle(bold, bgWhite, black),
      off.string().useStyle(underscore, blue),
      foo
    );
    return Success;
  }
}

class OtherCommand extends Command {
  @:argument var bar:String;

  @:command final thing:ValuePrinterCommand = new ValuePrinterCommand('thing');

  public function new() {}

  public function getDescription() {
    return 'Some other command';
  }

  public function process(input:Input, output:Output):ExitCode {
    output.write('yay' + bar);
    return Success;
  }
}

class ValuePrinterCommand extends Command {
  final value:String;

  public function new(value) {
    this.value = value;
  }

  public function getDescription():Null<String> {
    return 'Prints $value';
  }

  function process(input:Input, output:Output):ExitCode {
    output.writeLn(value);
    return Success;
  }
}
