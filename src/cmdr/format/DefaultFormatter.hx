package cmdr.format;

import cmdr.format.style.*;

class DefaultFormatter extends XmlFormatter {
  public function new() {
    super(new StyleSheet([
      new TextAppearanceStyle(Bold),
      new TextAppearanceStyle(Underscore),
      new BackgroundColorStyle('bg-black', Black),
      new BackgroundColorStyle('bg-red', Red),
      new BackgroundColorStyle('bg-green', Green),
      new BackgroundColorStyle('bg-yellow', Yellow),
      new BackgroundColorStyle('bg-blue', Blue),
      new BackgroundColorStyle('bg-magenta', Magenta),
      new BackgroundColorStyle('bg-cyan', Cyan),
      new BackgroundColorStyle('bg-white', White),
      new ForegroundColorStyle('black', Black),
      new ForegroundColorStyle('red', Red),
      new ForegroundColorStyle('green', Green),
      new ForegroundColorStyle('yellow', Yellow),
      new ForegroundColorStyle('blue', Blue),
      new ForegroundColorStyle('magenta', Magenta),
      new ForegroundColorStyle('cyan', Cyan),
      new ForegroundColorStyle('white', White)
    ]));
  }
}
