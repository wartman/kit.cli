package cmdr.output;

class SysOutput implements Output {
  public function new() {}

  public function write(...value:String) {
    for (value in value) Sys.print(value);
    return this;
  }

  public function writeLn(...value:String) {
    for (value in value) Sys.println(value);
    return this;
  }

  public function error(message:String) {
    // todo: style this
    writeLn('Error: ' + message);
    return this;
  }

  public function exit(code:Int = 0) {
    Sys.exit(code);
  }
}
