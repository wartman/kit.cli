package kit.cli.macro;

import haxe.macro.Expr;
import kit.macro.*;

using kit.macro.Tools;

function routerHook(builder:ClassBuilder) {
	return builder.hook('kit.cli:router');
}

function defaultRouteHook(builder:ClassBuilder) {
	return builder.hook('kit.cli:router');
}

function processHook(builder:ClassBuilder) {
	return builder.hook('kit.cli:process');
}

function specHook(builder:ClassBuilder) {
	return builder.hook('kit.cli:spec');
}

function createTypeParser(t:ComplexType, pos:Position) {
	return switch t {
		case null:
			pos.error('Fields cannot infer their types -- you must provide one');
			null;
		case macro :String:
			macro value;
		case macro :Int:
			macro Std.parseInt(value);
		case macro :Float:
			macro Std.parseFloat(value);
		case macro :Bool:
			macro value == 'true';
		default:
			pos.error('Fields may only be Strings, Ints, Floats or Bools');
			null;
	}
}

function getAlias(field:Field):Maybe<String> {
	var aliasMeta = field.getMetadata(':alias');
	return aliasMeta == null ? None : Some(switch aliasMeta.params {
		case [name]: name.extractString();
		default:
			aliasMeta.pos.error('Expected 1 argument');
			'';
	});
}
