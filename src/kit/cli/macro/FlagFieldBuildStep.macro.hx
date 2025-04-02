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
				var flagName = toFlagName(field.name);
				var flagShortName = switch meta.params {
					case [name]: toShortName(name.extractString(), name.pos);
					case []: null;
					case other:
						other[1].pos.error('Too many arguments');
						'';
				}
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
				var specNames = [macro $v{flagName}];
				var specShortNames = flagShortName != null ? [macro $v{flagShortName}] : [];

				switch field.getAlias().map(toFlagName) {
					case Some(alias):
						var storedDefaultBranch = defaultBranch;
						specNames.push(macro $v{alias});

						defaultBranch = macro {
							this.$name = switch arguments.findFlag($v{alias}) {
								case Some(value): $parser;
								case None: $storedDefaultBranch;
							}
						};
					case None:
				}

				builder.processHook().addExpr(macro {
					this.$name = switch arguments.findFlag($v{flagName}, $v{flagShortName}) {
						case Some(value): $parser;
						case None: $defaultBranch;
					}
				});

				builder.specHook().addExpr(macro kit.cli.Spec.SpecEntry.SpecFlag(
					[$a{specNames}],
					[$a{specShortNames}],
					$v{doc}
				));

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

	function toShortName(name:Null<String>, pos:Position) {
		if (name.startsWith('-')) return name;
		name = name.trim();
		if (name.length > 1) {
			pos.error('Expected a single character');
		}
		return '-$name';
	}
}
