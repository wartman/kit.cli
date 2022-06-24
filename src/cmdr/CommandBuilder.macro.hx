package cmdr;

import haxe.macro.Context;
import haxe.macro.Type.ClassType;
import haxe.macro.Expr;

using Lambda;
using StringTools;
using cmdr.CommandBuilder;
using haxe.macro.Tools;

function build() {
  var fields = Context.getBuildFields();
  var cls = Context.getLocalClass().get();
  var info = cls.extractCommandInfo();
  var help:Array<Expr> = [];
  var validation:Array<Expr> = [];
  var argumentInfo:Array<ArgumentInfo> = [];
  var argumentSummery:Array<String> = [];
  var argumentParsers:Array<Expr> = [];
  var optionSummery:Array<String> = [];
  var optionParsers:Array<Expr> = [];

  fields.addFields(macro class {
    public function getName():String {
      return $v{info.name};
    }
  
    public function getDescription():Null<String> {
      return $v{info.description};
    }
  });

  for (field in fields.filterWithMeta(':argument', ':arg')) {
    argumentInfo.push(field.extractArgumentInfo());
  }

  argumentInfo.sort((a, b) -> {
    if (a.index == b.index) {
      Context.error('Arguments cannot have the same index', b.pos);
    }
    return a.index - b.index;
  });

  for (index => info in argumentInfo) {
    var prev = index > 0 ? argumentInfo[index - 1] : null;
    var name = info.name;
    var parser = info.createArgumentParser();
    
    if (prev != null && prev.defaultValue != null) {
      if (info.defaultValue == null) {
        Context.error('You cannot have a required argument after an optional one', info.pos);
      }
    }

    argumentSummery.push(info.createArgumentSummery());
    argumentParsers.push(macro this.$name = $parser);
  }

  for (field in fields.filterWithMeta(':option', ':opt')) {
    var name = field.name;
    var info = field.extractOptionInfo();
    var parser = info.createOptionParser();
    var optionHelp = '    ' 
      + [ info.shortName, info.name ].filter(n -> n != null).join(', ')
      + ': ' + info.description;
    
    optionSummery.push(info.validateOptionInfo().createOptionSummery());
    optionParsers.push(macro this.$name = $parser);
    help.push(macro $v{optionHelp});
  }

  var summery = optionSummery;
  if (summery.length > 0 && argumentSummery.length > 0) {
    summery.push('[--]');
  }
  summery = summery.concat(argumentSummery);

  var argLength = argumentInfo.length;
  var requiredArgLength = argumentInfo.filter(arg -> arg.defaultValue == null).length;
  if (argLength > 0) {
    validation.push(macro {
      var args = input.getArguments();
      if (args.length > $v{argLength}) {
        return Invalid('Too many arguments -- expected ' + $v{argLength} + ' but recieved ' + args.length);
      }
      if (args.length < $v{requiredArgLength}) {
        return Invalid('Expected at least ' + $v{requiredArgLength} + ' arguments');
      }
    });
  }

  fields.addFields(macro class {
    function validate(input:cmdr.Input):cmdr.Command.CommandValidation {
      $b{validation};
      return Valid;
    }

    function bind(input:cmdr.Input) {
      $b{argumentParsers};
      $b{optionParsers};
    }

    function getArgumentsAndOptionSummery():String {
      return $v{summery.join(' ')};
    }

    function getArgumentsAndOptionHelp():Array<String> {
      return [ $a{help} ];
    }
  });

  return fields;
}

private function addFields(fields:Array<Field>, td:TypeDefinition) {
  for (f in td.fields) fields.push(f);
}

private function filterWithMeta(fields:Array<Field>, ...names:String) {
  var names = names.toArray();
  return fields.filter(f -> f.meta != null && f.meta.exists(m -> names.contains(m.name)));
}

private function getMeta(field:Field, ...names:String) {
  if (field.meta == null) return null;
  var names = names.toArray();
  return field.meta.find(m -> names.contains(m.name));
}

typedef CommandInfo = {
  public var name:Null<String>;
  public var description:Null<String>;
};

private function extractCommandInfo(cls:ClassType):CommandInfo {
  var info:CommandInfo = {
    name: null,
    description: null
  };

  switch cls.meta.extract(':command') {
    case [ meta ]: 
      for (param in meta.params) switch param {
        case macro name = $name:
          if (info.name != null) {
            Context.error('Command name was already set', param.pos);
          }
          info.name = name.extractString();
        case macro description = $description:
          if (info.description != null) {
            Context.error('Command description was already set', param.pos);
          }
          info.description = description.extractString();
        default:
          Context.error('Invalid expression', param.pos);
      }

      if (info.name == null) {
        Context.error('A name is required for this Command', meta.pos);
      }
    case []:
      Context.error('@:command meta is required', cls.pos);
    default:
      Context.error('Only one @:command is allowed per Command', cls.pos);
  }

  return info;
}

enum CommandType {
  CmdString;
  CmdInt;
  CmdFloat;
  CmdBool;
}

private function typeToCommandType(ct:ComplexType, pos:Position):CommandType {
  var type = ct.toType();
  if (type.unify(Context.getType('String'))) {
    return CmdString;
  }
  if (type.unify(Context.getType('Int'))) {
    return CmdInt;
  }
  if (type.unify(Context.getType('Float'))) {
    return CmdFloat;
  }
  if (type.unify(Context.getType('Bool'))) {
    return CmdBool;
  }
  Context.error('Invalid type: must be a String, Int, Float or Bool', pos);
  return null;
}

typedef ArgumentInfo = {
  public final name:String;
  public final description:Null<String>;
  public final index:Int;
  public final type:CommandType;
  public final defaultValue:Null<Expr>;
  public final pos:Position;
}

private function extractArgumentInfo(field:Field):ArgumentInfo {
  if (field.access.contains(AFinal)) {
    Context.error('@:argument fields cannot be final', field.pos);
  }
  
  return switch field.kind {
    case FVar(t, e):
      var meta = field.getMeta(':argument', ':arg');
      var name = field.name;
      var description:Null<String> = null;
      var index:Int = switch meta.params {
        case [ macro description = $d ]:
          description = d.extractString();
          null;
        case [ e, macro description = $d ]:
          description = d.extractString();
          e.extractInt();
        case [ e ]: 
          e.extractInt();
        case []: 
          Context.error('Expected an index', meta.pos);
          null;
        default:
          Context.error('Too many arguments', meta.pos);
          null;
      }

      {
        name: name,
        index: index,
        description: description,
        defaultValue: e,
        type: t.typeToCommandType(field.pos),
        pos: field.pos
      };
    default:
      Context.error('@:argument must be a var', field.pos);
      null;
  }
}

private function createArgumentSummery(info:ArgumentInfo) {
  return info.defaultValue == null
    ? '<${info.name}>'
    : '[${info.name}]';
}

private function createArgumentParser(info:ArgumentInfo) {
  var defaultBranch = info.defaultValue != null
    ? macro ${info.defaultValue}
    : macro throw 'The argument ' + $v{info.name} + ' is required';

  var valueParser = switch info.type {
    case CmdString: macro value;
    case CmdInt: macro Std.parseInt(value);
    case CmdFloat: macro Std.parseFloat(value);
    case CmdBool: macro switch value {
      case 'true': true;
      case 'false': false;
      default: throw 'Expected `true` or `false';
    }
  }

  return macro switch input.findArgument($v{info.index}) {
    case Some(value): $valueParser;
    case None: $defaultBranch;
  }
}

typedef OptionInfo = {
  public final name:String;
  public final shortName:Null<String>;
  public final description:Null<String>;
  public final type:CommandType;
  public final defaultValue:Null<Expr>;
  public final pos:Position;
}

private function extractOptionInfo(field:Field):OptionInfo {
  if (field.access.contains(AFinal)) {
    Context.error('@:option fields cannot be final', field.pos);
  }
  
  return switch field.kind {
    case FVar(t, e):
      var meta = field.getMeta(':option', ':opt');
      var name = field.name.prepareName();
      var description:Null<String> = null;
      var shortName = prepareShortName(switch meta.params {
        case [ macro description = $d ]:
          description = d.extractString();
          null;
        case [ e, macro description = $d ]:
          description = d.extractString();
          e.extractString();
        case [ e ]: 
          e.extractString();
        case []: 
          null;
        default:
          Context.error('Too many arguments', meta.pos);
          null;
      });

      if (shortName != null && shortName.length > 2) {
        Context.error('Short name should only be one character long (not conting the `-`)', meta.params[0].pos);
      }

      {
        name: name, 
        shortName: shortName,
        description: description,
        type: t.typeToCommandType(field.pos),
        defaultValue: e,
        pos: field.pos
      };
    default:
      Context.error('@:option must be a var', field.pos);
      null;
  }
}

private function validateOptionInfo(info:OptionInfo) {
  if (info.type.equals(CmdBool)) {
    switch info.defaultValue {
      case null:
        Context.error('Boolean options require a default value of false', info.pos);
      case macro true: 
        Context.error('Default values for boolean values can only be false', info.pos);
      default:
    }
  }

  return info;
}

private function createOptionSummery(info:OptionInfo) {
  var output:Array<String> = [];
  var name = info.shortName != null ? '${info.shortName}|${info.name}' : info.name;
  var placeholderName = info.name.substr(2).toUpperCase();

  if (info.type.equals(CmdBool)) {
    return '[$name]';
  }
  
  return switch info.defaultValue {
    case null: '[$name <$placeholderName>]';
    case _: '[$name [$placeholderName]]';
  }
}

private function createOptionParser(info:OptionInfo) {
  var defaultBranch = info.defaultValue != null
    ? macro ${info.defaultValue}
    : switch info.type {
      case CmdBool:
        macro false;
      default:
        macro throw 'The option ' + $v{info.name} + ' is required';
    }

  var valueParser = switch info.type {
    case CmdString: macro value;
    case CmdInt: macro Std.parseInt(value);
    case CmdFloat: macro Std.parseFloat(value);
    case CmdBool: macro true;
  }

  return macro {
    switch input.findOption($v{info.name}, $v{info.shortName}) {
      case Some(value):
        $valueParser;
      case None: 
        $defaultBranch;
    }
  }
}

private function extractString(expr:Expr) {
  return switch expr.expr {
    case EConst(CString(s, _)): 
      s;
    default:
      Context.error('Expected a string', expr.pos);
      '';
  }
}

private function extractInt(expr:Expr) {
  return switch expr.expr {
    case EConst(CInt(v)): 
      Std.parseInt(v);
    default:
      Context.error('Expected an Int', expr.pos);
      0;
  }
}

private function prepareName(name:String) {
  name = name.trim();
  if (name.startsWith('--')) return name;
  return '--$name';
}

private function prepareShortName(name:Null<String>) {
  if (name == null) return null;
  
  name = name.trim();

  if (name.startsWith('-')) return name;

  return '-$name';
}
