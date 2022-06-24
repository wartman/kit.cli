import cmdr.format.DefaultFormatter;
import cmdr.output.FormattedOutput;
import cmdr.input.SysInput;
import cmdr.output.SysOutput;
import cmdr.*;

function main() {
  var app = new Application([ new TestCommand() ]);
  app.execute(
    new SysInput(),
    new FormattedOutput(new DefaultFormatter(), new SysOutput())
  );
}

@:command(
  name = 'test',
  description = 'Just a test'
)
class TestCommand extends Command {
  @:argument(1) var bin:String = 'ok';
  @:argument(0) var bar:String;
  @:option('o') var off:Bool = false;
  @:option('f', description = 'Set the foo') var foo:String;

  public function new() {}

  public function process(input:Input, output:Output):ExitCode {
    output.writeLn(
      bar, 
      '<bold:bg-white:black>$bin</bold:bg-white:black>',
      '<underscore:red>${off}</underscore:red>',
      foo
    );
    return Success;
  }
}
