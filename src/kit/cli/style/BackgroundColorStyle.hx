package kit.cli.style;

class BackgroundColorStyle implements Style {
  public final name:String;
  final color:Color;

  public function new(name, color) {
    this.name = name;
    this.color = color;
  }

  public function apply(value:StyledText):Void {
    value.setBackground('4' + color);
  }
}
