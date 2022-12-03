package cmdr;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
import cmdr.internal.MacroTools;

using StringTools;
using cmdr.internal.MacroTools;

private final FLAG = ':flag';
private final ALIAS = ':alias';
private final COMMAND = ':command';
private final DEFAULT_COMMAND = ':defaultCommand';

enum CmdrType {
  CmdrString;
  CmdrInt;
  CmdrFloat;
  CmdrBool;
}

typedef FlagInfo = {
  public final field:Field;
  public final name:String;
  public final alias:Null<String>;
  public final doc:Null<String>;
  public final def:Null<Expr>;
  public final type:CmdrType;
}

typedef CommandArg = {
  public final index:Int;
  public final name:String;
  public final doc:Null<String>;
  public final def:Null<Expr>;
  public final type:CmdrType;
} 

enum CommandKind {
  CmdFunction(params:Array<CommandArg>);
  CmdSubCommand;
}

typedef CommandInfo = {
  public final field:Field;
  public final name:String;
  public final alias:Null<String>;
  public final kind:CommandKind;
  public final isDefault:Bool;
  public final doc:Null<String>;
} 

function build() {
  var cls = Context.getLocalClass().get();
  var fields = getBuildFieldsSafe();
  var flags = fields.filterByMeta(FLAG).map(extractFlagInto);
  var commands = fields.filterByMeta(COMMAND).map(cmd -> extractCommandInfo(cmd));
  var defaultCommand = switch fields.filterByMeta(DEFAULT_COMMAND) {
    case [ field ]: extractCommandInfo(field, true);
    case []: 
      Context.error('A $DEFAULT_COMMAND is required', cls.pos);
      null;
    default:
      Context.error('Only one $DEFAULT_COMMAND is allowed per class', cls.pos);
      null;
  }
  var router = createRouter(commands, flags, defaultCommand);
  var spec = createDocSpec(cls, flags, commands.concat([ defaultCommand ]));

  validate(flags, commands);

  fields.add(macro class {
    @:noCompletion var backing_input:Null<cmdr.Input> = null;
    public var input(get, never):cmdr.Input;
    function get_input():cmdr.Input {
      if (backing_input == null) {
        throw 'Attempted to access Input before the Command was ready.'
          + ' Generally, you should only be using cmdr.Command inside'
          + ' a cmdr.Cli, which will set things up for you.';
      }
      return backing_input;
    } 

    @:noCompletion var backing_output:Null<cmdr.Output> = null;
    public var output(get, never):cmdr.Output;
    function get_output():cmdr.Output {
      if (backing_output == null) {
        throw 'Attempted to access Output before the Command was ready.'
          + ' Generally, you should only be using cmdr.Command inside'
          + ' a cmdr.Cli, which will set things up for you.';
      }
      return backing_output;
    } 
    
    public function process(input:cmdr.Input, output:cmdr.Output, finish:(result:cmdr.Result)->Void):Void {
      backing_input = input;
      backing_output = output;
      ${router};
    }

    public function getSpec():cmdr.DocSpec {
      return ${spec};
    }

    public function getDocs():String {
      return new cmdr.format.DefaultFormatter().format(getSpec());
    }
  });

  return fields;
}

private function validate(flags:Array<FlagInfo>, commands:Array<CommandInfo>) {
  var existingNames:Array<String> = [];

  for (flag in flags) {
    if (existingNames.contains(flag.name)) {
      Context.error('Name collision: ${flag.name} already exists', flag.field.pos);
    }
    if (flag.alias != null && existingNames.contains(flag.alias)) {
      Context.error('Name collision: ${flag.alias} already exists', flag.field.pos);
    }
    existingNames = existingNames.concat([ flag.name, flag.alias ].filter(n -> n != null));
  }

  for (command in commands) {
    if (existingNames.contains(command.name)) {
      Context.error('Name collision: ${command.name} already exists', command.field.pos);
    }
    if (command.alias != null && existingNames.contains(command.alias)) {
      Context.error('Name collision: ${command.alias} already exists', command.field.pos);
    }
    existingNames = existingNames.concat([ command.name, command.alias ].filter(n -> n != null));
  }
}

private function extractFlagInto(field:Field):FlagInfo {
  if (field.access.contains(AFinal)) {
    Context.error('$FLAG fields cannot be final', field.pos);
  }

  return switch field.kind {
    case FVar(t, e):
      var flagMeta = field.getMeta(FLAG);
      var name = flagMeta != null
        ? switch flagMeta.params {
          case [ name ]: name.extractString().toFlagName();
          case []: field.name.toFlagName();
          default: 
            Context.error('Expened 0-1 params', flagMeta.pos);
            '';
        }
        : field.name.toFlagName();
      var doc = field.doc;
      var alias = switch getAlias(field) {
        case null: field.name.charAt(0).toLowerCase().toShortName();
        case name: name.toShortName();
      }

      {
        field: field,
        name: name,
        alias: alias,
        doc: doc,
        def: e,
        type: extractCmdrType(t, field.pos)
      };
    default:
      Context.error('$FLAG must be a var', field.pos);
      null;
  }
}

private function createFlagParser(info:FlagInfo):Expr {
  var defaultBranch = info.def != null
    ? macro ${info.def}
    : switch info.type {
      case CmdrBool:
        macro false;
      default:
        macro throw new cmdr.internal.CmdrParseException('The flag ' + $v{info.name} + ' is required');
    }

  var parser = createCmdrTypeParser(info.type);
  var name = info.field.name;

  return macro this.$name = switch input.findFlag($v{info.name}, $v{info.alias}) {
    case Some(value): $parser;
    case None: $defaultBranch;
  }
}

private function extractCommandInfo(field:Field, isDefault:Bool = false):CommandInfo {
  var meta = field.getMeta(COMMAND);
  var name = meta == null
    ? field.name 
    : switch meta.params {
      case [ name ]: name.extractString();
      case []: field.name;
      default: 
        Context.error('Too many arguments', meta.pos);
        '';
    }

  return switch field.kind {
    case FVar(t, e):
      if (!field.access.contains(AFinal)) {
        Context.error('${COMMAND} fields must be final', field.pos);
      }
      if (field.access.contains(AStatic)) {
        Context.error('${COMMAND} fields cannot be static', field.pos);
      }

      {
        field: field,
        name: name,
        kind: CmdSubCommand,
        alias: getAlias(field),
        doc: field.doc,
        isDefault: isDefault
      };
    case FFun(f):
      var args:Array<CommandArg> = [ for (index => a in f.args) ({
        index: index,
        name: a.name,
        doc: null,
        def: a.value,
        type: extractCmdrType(a.type, field.pos)
      }:CommandArg) ];

      {
        field: field,
        name: name,
        kind: CmdFunction(args),
        alias: getAlias(field),
        doc: field.doc,
        isDefault: isDefault
      };
    default:
      Context.error('Invalid target for ${COMMAND} -- must be a method or a final variable', field.pos);
      null;
  }
}

private function createCommandParser(command:CommandInfo) {
  var name = command.field.name;
  var args:Expr = command.isDefault 
    ? macro input.getArguments() 
    : macro input.getArguments().slice(1);

  return switch command.kind {
    case CmdFunction([]):
      macro finish(@:pos(command.field.pos) this.$name());
    case CmdFunction(params):
      var callArgs = params.map(createArgumentParser);
      macro {
        var __arguments = $args;
        finish(@:pos(command.field.pos) this.$name($a{callArgs}));
      }
    case CmdSubCommand:
      macro {
        this.$name.process(
          new cmdr.input.ArrayInput(
            input.getFlags(),
            $args
          ),
          output,
          finish
        );
      };
  }
}

private function createArgumentParser(arg:CommandArg) {
  var defaultBranch = arg.def == null
    ? macro throw new cmdr.internal.CmdrParseException('The argument ' + $v{arg.name} + ' is required')
    : arg.def;
  var parser = createCmdrTypeParser(arg.type);
  return macro switch __arguments[$v{arg.index}] {
    case null: $defaultBranch;
    case value: $parser;
  }
}

private function createCmdrTypeParser(type:CmdrType) {
  var expr = switch type {
    case CmdrString: macro value;
    case CmdrInt: macro Std.parseInt(value);
    case CmdrFloat: macro Std.parseFloat(value);
    case CmdrBool: macro value == 'true';
  }
  return macro try $expr catch (e) throw new cmdr.internal.CmdrParseException(e.message);
}

private function createRouter(
  commands:Array<CommandInfo>,
  flags:Array<FlagInfo>,
  defaultCommand:CommandInfo
):Expr {
  var flags = flags.map(createFlagParser);
  var routes = commands.map(createCommandRoute);

  return macro @:mergeBlock {
    try {
      @:mergeBlock $b{flags};
      var __command = input.getArguments()[0];
      @:mergeBlock $b{routes};
      ${createCommandParser(defaultCommand)}
    } catch (e:cmdr.internal.CmdrParseException) {
      output.error(e.message);
      output.writeLn(getDocs());
      finish(Failure(1));
      return;
    }
  };
}

private function createCommandRoute(command:CommandInfo) {
  var name = command.name;
  var parser = createCommandParser(command);
  return macro if (__command == $v{name}) {
    ${parser};
    return;
  }
}

private function createDocSpec(cls:ClassType, flags:Array<FlagInfo>, commands:Array<CommandInfo>) {
  var docFlags = flags.map(createFlagDoc);
  var docCommands = commands.map(createCommandDoc);
  var doc = cls.doc != null 
    ? cls.doc.trim()
    : null;
  
  return macro ({
    doc: $v{doc},
    commands: [ $a{docCommands} ],
    flags: [ $a{docFlags} ]
  }:cmdr.DocSpec);
}

private function createFlagDoc(flag:FlagInfo):Expr {
  var names = [ flag.name, flag.alias ]
    .filter(f -> f != null)
    .map(s -> macro $v{s});
  var aliases = [ flag.alias ]
    .filter(f -> f != null)
    .map(s -> macro $v{s});

  return macro ({
    aliases: [ $a{aliases} ],
    names: [ $a{names} ],
    doc: $v{flag.doc == null ? '(no documentation)' : flag.doc.trim()}
  }:cmdr.DocSpec.DocFlag);
}

private function createCommandDoc(command:CommandInfo):Expr {
  var names = [ macro $v{command.name} ];
  var args:Array<Expr> = switch command.kind {
    case CmdFunction(params): params.map(param -> macro ({
      name: $v{param.name},
      isOptional: $v{param.def != null}
    }:cmdr.DocSpec.DocCommandArg));
    case CmdSubCommand: [];
  }

  if (command.alias != null) names.push(macro $v{command.alias});

  return macro ({
    names: [ $a{names} ],
    isDefault: $v{command.isDefault},
    isSub: $v{ command.kind == CmdSubCommand },
    args: [ $a{args} ],
    doc: $v{ command.doc == null ? '(no documentation)' : command.doc.trim() }
  }:cmdr.DocSpec.DocCommand);
}

private function getAlias(field:Field):Null<String> {
  var aliasMeta = field.getMeta(ALIAS);
  return aliasMeta == null 
    ? null
    : switch aliasMeta.params {
        case [ name ]: name.extractString();
        default: 
          Context.error('Expected 1 argument', aliasMeta.pos);
          '';
    }
}

private function extractCmdrType(t:ComplexType, pos:Position) {
  return switch t {
    case null:
      Context.error('Fields cannot infer their types -- you must provide one', pos);
      null;
    case macro:String:
      CmdrString;
    case macro:Int:
      CmdrInt;
    case macro:Float:
      CmdrFloat;
    case macro:Bool:
      CmdrBool;
    default:
      Context.error('Fields may only be Strings, Ints, Floats or Bools', pos);
      null;
  }
}
