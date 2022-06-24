package cmdr.format;

class XmlFormatter implements Formatter {
  final styles:StyleSheet;

  public function new(styles) {
    this.styles = styles;
  }

  public function format(value:Null<String>):Null<String> {
    if (value == null) return null;

    var node = Xml.parse(value);
    return formatNode(node);
  }

  function formatNode(node:Xml) {
    return switch node.nodeType {
      case CData | PCData: 
        node.nodeValue;
      case Document:
        [ for (node in node) formatNode(node) ]
          .filter(s -> s != null)
          .join('');
      case Element:
        var body = [ for (node in node) formatNode(node) ]
          .filter(s -> s != null)
          .join('');
        var fragment = new Fragment(body);
        styles.apply(fragment, node.nodeName.split(':'));
        return fragment.apply();
      default:
        null;
    }
  }
}
