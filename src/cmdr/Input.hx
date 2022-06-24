package cmdr;

import haxe.ds.Option;

interface Input {
  public function currentCommand():Option<String>;
  public function setOption(name:String, shortName:String, value:String):Void;
  public function findOption(name:String, ?shortName:String):Option<Dynamic>;
  public function getArguments():Array<String>;
  public function findArgument(index:Int):Option<Dynamic>;
}
