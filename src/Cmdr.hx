import cmdr.input.SysInput;
import cmdr.output.SysOutput;
import cmdr.*;
import cmdr.style.DefaultStyles.*;

using Std;
using cmdr.style.StyleTools;

function main() {
  var app = new Application([ new TestCommand() ]);
  app.execute(
    new SysInput(),
    new SysOutput()
  );
}

@:command(
  name = 'test',
  description = 'Just a test'
)
class TestCommand extends Command {
  @:argument var bar:String;
  @:argument var bin:String = 'ok';
  @:option('o', description = 'Set the off') var off:Bool = false;
  @:option('f', description = 'Set the foo') var foo:String;

  public function new() {}

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
