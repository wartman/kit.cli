package cmdr.output;

class FormattedOutput implements Output {
  final formatter:Formatter;
  final output:Output;

  public function new(formatter, output) {
    this.formatter = formatter;
    this.output = output;  
  }

  public function write(...value:String) {
    output.write(...value.toArray().map(formatter.format));
  }

  public function writeLn(...value:String) {
    output.writeLn(...value.toArray().map(formatter.format));
  }
}
