package cmdr;

import haxe.ds.Option;

interface Input {
  public function findFlag(name:String, ?shortName:String):Option<String>;
  public function getFlags():Map<String, String>;
  public function getArguments():Array<String>;
}
