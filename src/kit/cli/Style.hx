package kit.cli;

interface Style {
  public final name:String;
  public function apply(value:StyledText):Void;
}
