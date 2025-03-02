package kit.cli.macro;

import kit.macro.*;
import haxe.macro.Expr;

using kit.macro.Tools;
using kit.cli.macro.Tools;
using StringTools;

class FlagFieldBuildStep implements BuildStep {
	public final priority:Priority = Normal;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		for (field in builder.findFieldsByMeta(':flag')) {
			parseField(builder, field, field.getMetadata(':flag'));
		}
	}

	function parseField(builder:ClassBuilder, field:Field, meta:MetadataEntry) {
		switch field.kind {
			case FVar(t, e):
				if (t == null) {
					field.pos.error('Type params cannot be inferred for :flags');
				}

				var name = field.name;
				var flagName = meta != null ? switch meta.params {
					case [name]: toFlagName(name.extractString());
					case []: toFlagName(field.name);
					default:
						meta.pos.error('Expected 0-1 params');
						'';
				} : toFlagName(field.name);
				var flagAlias = field.getAlias();
				var doc = field.doc == null ? '(no documentation)' : field.doc;
				var defaultBranch:Expr = if (e == null) switch t {
					case macro :Bool:
						macro false;
					default:
						macro throw new kit.cli.parse.ParseException('The flag ' + $v{flagName} + ' is required');
				} else {
					e;
				}
				var parser = t.createTypeParser(field.pos);
				// @todo
				// var alias = switch getAlias(field) {
				// 	case null: field.name.charAt(0).toLowerCase().toShortName();
				// 	case name: name.toShortName();
				// }
				var specNames = [flagName, flagAlias].filter(f -> f != null).map(s -> macro $v{s});
				var specAliases = [flagAlias].filter(f -> f != null).map(s -> macro $v{s});

				builder.specHook().addExpr(macro kit.cli.Spec.SpecEntry.SpecFlag(
					[$a{specNames}],
					[$a{specAliases}],
					$v{doc}
				));
				builder.processHook().addExpr(macro {
					this.$name = switch input.findFlag($v{flagName}, $v{flagAlias}) {
						case Some(value): $parser;
						case None: $defaultBranch;
					}
				});

			default:
				field.pos.error(':flag must be a var');
				null;
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
}
