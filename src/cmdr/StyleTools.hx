package cmdr;

import cmdr.style.*;

function useStyle(value:String, ...styles:Style):String {
  return new StyledText(value)
    .useStyle(...styles)
    .toString();
}

function bold(value:String) {
  return useStyle(value, new TextAppearanceStyle(Bold));
}

function underscore(value:String) {
  return useStyle(value, new TextAppearanceStyle(Underscore));
}

function backgroundColor(value:String, color:Color) {
  return useStyle(value, new BackgroundColorStyle('bg-custom', color));
}

function color(value:String, color:Color) {
  return useStyle(value, new ForegroundColorStyle('fg-custom', color));
}
