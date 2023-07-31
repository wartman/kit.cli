package kit.cli.format;

import kit.cli.DocSpec;

using Lambda;
using StringTools;
using kit.cli.StyleTools;

class DefaultFormatter implements DocFormatter {
  public function new() {}

  public function format(spec:DocSpec):String {
    var out = new StringBuf();
    var commands = spec.commands.filter(c -> !c.isDefault);
    var defaultCommand = spec.commands.find(c -> c.isDefault);

    inline function addLine(v:String) out.add(v + '\n');

    addLine('');
    switch cleanup(spec.doc) {
      case null:
      case doc: addLine(doc + '\n');
    }

    if (defaultCommand != null) {
      var args = getCommandArgs(defaultCommand);
      if (args.length > 0) {
        addLine(indent(args + ' : ' + defaultCommand.doc, 4));
      } else {
        addLine(indent(defaultCommand.doc, 4));
      }
      addLine('');
    }

    if (commands.length > 0) {
      var len = getCommandIndent(commands);

      addLine(indent('Subcommands:', 4).bold());
      
      for (command in commands) {
        addLine(formatCommand(command, len));
      }
    }

    if (spec.flags.length > 0) {
      var len = getFlagIndent(spec.flags);
      
      addLine('');
      addLine(indent('Flags:', 4).bold());

      for (flag in spec.flags) {
        addLine(formatFlag(flag, len));
      }
    }

    return out.toString();
  }

  function getCommandIndent(commands:Array<DocCommand>) {
    return commands.fold((command, indent) -> {
      var len = getCommandName(command).length;
      if (len > indent) return len;
      return indent;
    }, 0);
  }

  function getCommandArgs(command:DocCommand) {
    return command.args.map(arg -> switch arg.isOptional {
      case true: '[${arg.name}]';
      case false: '<${arg.name}>';
    }).join(', ');
  }

  function getCommandName(command:DocCommand) {
    var args = getCommandArgs(command);
    var names = command.names.join(', ');
    
    if (args.length > 0) return names + ' ' + args;
    return names;
  }

  function formatCommand(command:DocCommand, commandIndent:Int) {
    var name = getCommandName(command);
    return indent(
      name.lpad(' ', commandIndent) + ' : '
        + indent(command.doc, commandIndent + 3).trim(),
      6
    );
  }

  function getFlagIndent(flags:Array<DocFlag>) {
    return flags.fold((flag, indent) -> {
      var len = getFlagName(flag).length;
      if (len > indent) return len;
      return indent;
    }, 0);
  }

  function getFlagName(flag:DocFlag) {
    return flag.names.join(', ');
  }

  function formatFlag(flag:DocFlag, flagIndent:Int) {
    var name = getFlagName(flag);
    return indent(
      name.lpad(' ', flagIndent) + ' : ' + indent(flag.doc, flagIndent + 3).trim(),
      6
    );
  }

  function indent(value:String, level:Int) {
    return value
      .split('\n')
      .map(part -> ''.lpad(' ', level) + part)
      .join('\n');
  }

  function cleanup(value:String) {
    if (value == null) return null;

    var lines = value.split('\n').map(StringTools.trim);

    while (lines[0] == '') lines.shift();
    while (lines[lines.length - 1] == '') lines.pop();

    return lines.join('\n');
  }
}
