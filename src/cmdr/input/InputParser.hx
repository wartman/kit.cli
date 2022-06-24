package cmdr.input;

using StringTools;

typedef InputParserResults = {
  arguments:Array<String>,
  options:Map<String, String>
}; 

function parse(tokens:Array<String>):InputParserResults {
  var tokens = expandAssignments(tokens);
  var optionsEnded = false;
  var pos = 0;
  var results:InputParserResults = {
    arguments: [],
    options: []
  };

  while (pos < tokens.length) {
    var token = tokens[pos];
    if (token == '--') {
      optionsEnded = true;
      pos++;
    } else if (!optionsEnded && token.charCodeAt(0) == '-'.code) {
      var next = tokens[pos + 1];
      if (next == null || next.charCodeAt(0) == '-'.code) {
        results.options.set(token, 'true');
        pos++;
      } else {
        results.options.set(token, next);
        pos++;
        pos++;
      }
    } else {
      results.arguments.push(token);
      pos++;
    }
  }

  return results;
}

private function expandAssignments(tokens:Array<String>) {
  var output = [];
  var inOptionsMode = true;
  for (token in tokens) {
    if (token == '--') inOptionsMode = false;
    if (!inOptionsMode) 
      output.push(token);
    else switch [token.charCodeAt(0), token.charCodeAt(1), token.indexOf('=')] {
      case ['-'.code, '-'.code, i] if (i != -1):
        output.push(token.substr(0, i));
        output.push(token.substr(i + 1));
      default:
        output.push(token);
    }
  }
  return output;
}
