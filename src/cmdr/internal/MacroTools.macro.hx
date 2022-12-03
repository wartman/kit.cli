package cmdr.internal;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.ds.Option;

using Lambda;
using StringTools;

function add(fields:Array<Field>, td:TypeDefinition) {
  for (f in td.fields) fields.push(f);
}

function filterByMeta(fields:Array<Field>, ...names:String) {
  var names = names.toArray();
  return fields.filter(f -> f.meta != null && f.meta.exists(m -> names.contains(m.name)));
}

function getMeta(field:Field, ...names:String) {
  if (field.meta == null) return null;
  var names = names.toArray();
  return field.meta.find(m -> names.contains(m.name));
}

function extractString(expr:Expr) {
  return switch expr.expr {
    case EConst(CString(s, _)): 
      s;
    default:
      Context.error('Expected a string', expr.pos);
      '';
  }
}

function toFlagName(name:String) {
  name = name.trim();
  if (name.startsWith('--')) return name;
  return '--$name';
}

function toShortName(name:Null<String>) {
  if (name == null) return null;
  
  name = name.trim();

  if (name.startsWith('-')) return name;

  return '-$name';
}


function getBuildFieldsSafe():Array<Field> {
  return switch getCompletion() {
    case Some(v) if (v.content != null
      && (v.content.charAt(v.pos - 1) == '@' || (v.content.charAt(v.pos - 1) == ':' && v.content.charAt(v.pos - 2) == '@'))):
      Context.error('Impossible to get builds fields now. Possible cause: https://github.com/HaxeFoundation/haxe/issues/9853', Context.currentPos());
    default:
      Context.getBuildFields();
  }
}

// Workaround for https://github.com/HaxeFoundation/haxe/issues/9853
// Stolen from https://github.com/haxetink/tink_macro/blob/6f4e6b9227494caddebda5659e0a36d00da9ca52/src/tink/MacroApi.hx#L70
private function getCompletion() {
  var sysArgs = Sys.args();
  return switch sysArgs.indexOf('--display') {
    case -1: None;
    case sysArgs[_ + 1] => arg if (arg.startsWith('{"jsonrpc":')):
      var payload:{
        jsonrpc:String,
        method:String,
        params:{
          file:String,
          offset:Int,
          contents:String,
        }
      } = haxe.Json.parse(arg);
      switch payload {
        case {jsonrpc: '2.0', method: 'display/completion'}:
          Some({
            file: payload.params.file,
            content: payload.params.contents,
            pos: payload.params.offset,
          });
        default: None;
      }
    default: None;
  }
}
