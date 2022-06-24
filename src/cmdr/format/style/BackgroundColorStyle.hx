package cmdr.format.style;

class BackgroundColorStyle implements Style {
  public final name:String;
  final color:Color;

  public function new(name, color) {
    this.name = name;
    this.color = color;
  }

  public function apply(value:Fragment):Fragment {
    value.setBackground('4' + color);
    return value;
  }
}
