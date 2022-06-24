package cmdr.output;

class SysOutput implements Output {
  public function new() {}

  public function write(value:String) {
    Sys.print(value);
  }

  public function writeLn(...value:String) {
    for (value in value) Sys.println(value);
  }
}
