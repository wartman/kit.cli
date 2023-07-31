package kit.cli;

import kit.cli.style.*;

class StyleTools {
  public static function useStyle(value:String, ...styles:Style):String {
    return new StyledText(value)
      .useStyle(...styles)
      .toString();
  }
  
  public static function bold(value:String) {
    return useStyle(value, new TextAppearanceStyle(Bold));
  }
  
  public static function underscore(value:String) {
    return useStyle(value, new TextAppearanceStyle(Underscore));
  }
  
  public static function backgroundColor(value:String, color:Color) {
    return useStyle(value, new BackgroundColorStyle('bg-custom', color));
  }
  
  public static function color(value:String, color:Color) {
    return useStyle(value, new ForegroundColorStyle('fg-custom', color));
  }
}
