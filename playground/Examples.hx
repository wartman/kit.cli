using Lambda;
using Kit;
using kit.Cli;

function main() {
  var cli = Cli.fromSys();
  cli.execute(new App());
}

class App implements Command {
  @:flag var off:Bool = false;
  @:flag('f') var foo:String = null;
  @:flag var help:Bool = false;

  @:command final sub = new SubCommand('pre');

  public function new() {}

  /**
    This command will print whatever you give it.
  **/
  @:command
  public function other(bar:String = ''):Task<Int> {
    if (help) {
      output.write(getDocs());
      return 0;
    }

    output
      .writeLn('We can do fun stuff with styles: '.underscore())
      .write(' This has a background '.backgroundColor(White).color(Blue).bold())
      .writeLn(bar.color(Red).bold());

    return 0;
  }

  /**
    This is a simple app to explain how things work.
  **/
  @:defaultCommand
  public function docs():Task<Int> {
    output.write(getDocs());
    return 0;
  }
}

class SubCommand implements Command {
  @:flag('f') var suffix:String = 'Ok!';

  final prefix:String;

  public function new(prefix) {
    this.prefix = prefix;
  }

  /**
    This also just prints foo.
  **/
  @:defaultCommand
  function doesAThing(foo:String, bin:String = 'ok'):Task<Int> {
    output.writeLn(prefix + ' ' + foo + bin + ' ' + suffix);
    return 0;
  }
}
