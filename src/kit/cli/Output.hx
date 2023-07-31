package kit.cli;

interface Output {
  public function write(...value:String):Output;
  public function writeLn(...value:String):Output;
  public function error(message:String):Output;
  public function exit(code:Int = 0):Void;
}
