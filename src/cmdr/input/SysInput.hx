package cmdr.input;

class SysInput extends ParsedInput {
  public function new() {
    super(Sys.args());
  }
}
