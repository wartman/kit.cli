package cmdr;

interface Style {
  public final name:String;
  public function apply(value:Fragment):Fragment;
}
