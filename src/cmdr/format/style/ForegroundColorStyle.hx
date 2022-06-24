package cmdr.format.style;

class ForegroundColorStyle implements Style {
  public final name:String;
  final color:Color;

  public function new(name, color) {
    this.name = name;
    this.color = color;
  }

  public function apply(value:Fragment):Fragment {
    value.setForeground('3' + color);
    return value;
  }
}
