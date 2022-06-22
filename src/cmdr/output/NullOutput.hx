package cmdr.output;

import haxe.Rest;

class NullOutput implements Output {
  public function new() {}

  public function write(value:String) {}

  public function writeLn(...value:String) {}
}
