package cmdr;

using Lambda;

abstract StyleSheet(Array<Style>) {
  public function new(styles) {
    this = styles;
  }

  public function add(style:Style) {
    if (this.contains(style) || this.exists(s -> s.name == style.name)) {
      return;
    }
    this.push(style);
  }

  public function apply(value:Fragment, names:Array<String>) {
    return this.filter(s -> names.contains(s.name))
      .fold((style:Style, value) -> style.apply(value), value);
  }
}
