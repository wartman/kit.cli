package cmdr.input;

class SysInput extends ArrayInput {
  public function new() {
    super(Sys.args());
  }
}
