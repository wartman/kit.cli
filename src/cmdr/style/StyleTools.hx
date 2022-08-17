package cmdr.style;

function useStyle(value:String, ...styles:Style):StyledText {
  return new StyledText(value).useStyle(...styles);
}
