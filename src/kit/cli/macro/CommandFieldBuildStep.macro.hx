package kit.cli.macro;

import haxe.macro.Expr;
import kit.macro.*;

using kit.cli.macro.Tools;
using kit.macro.Tools;

class CommandFieldBuildStep implements BuildStep {
	public final priority:Priority = Normal;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		for (field in builder.findFieldsByMeta(':command')) {
			parseField(builder, field, field.getMetadata(':command'), false);
		}

		switch builder.findFieldsByMeta(':defaultCommand') {
			case [field]:
				parseField(builder, field, field.getMetadata(':defaultCommand'), true);
			case []:
				builder.getClass().pos.error('A :defaultCommand is required');
				null;
			case fields:
				fields[1].getMetadata(':defaultCommand').pos.error('Only one :defaultCommand is allowed per class');
				null;
		}
	}

	function parseField(builder:ClassBuilder, field:Field, meta:MetadataEntry, isDefault:Bool) {
		var name = field.name;
		var commandAlias = field.getAlias().unwrap();
		var commandName = switch meta.params {
			case null | []:
				field.name;
			case [expr]:
				expr.extractString();
			default:
				meta.pos.error('Too many arguments');
		}
		var commandNames = [commandName, commandAlias]
			.filter(n -> n != null)
			.map(n -> macro $v{n});

		var check:Expr = if (commandAlias != null) {
			macro __command == $v{commandName} || __command == $v{commandAlias};
		} else {
			macro __command == $v{commandName};
		}

		switch field.kind {
			case FVar(t, e):
				// @todo: check that t is a Command
				if (isDefault) {
					meta.pos.error('Subcommands cannot be default commands');
				}
				if (!field.access.contains(AFinal)) {
					field.pos.error(':command fields must be final');
				}
				if (field.access.contains(AStatic)) {
					field.pos.error(':command fields cannot be static');
				}

				builder.specHook().addExpr(macro kit.cli.Spec.SpecEntry.SpecSub(
					[$a{commandNames}],
					this.$name.getSpec(),
				));
				builder.routerHook().addExpr(macro {
					if (${check}) {
						return this.$name.process(new kit.cli.input.ArrayInput(
							input.getFlags(),
							input.getArguments().slice(1)
						), output);
					}
				});

			case FFun(f):
				var doc = field.doc;
				var argDocs:Array<Expr> = [];
				var parsers:Array<Expr> = [for (index => arg in f.args) {
					var defaultBranch = if (arg.value == null) {
						macro throw new kit.cli.parse.ParseException('The argument ' + $v{arg.name} + ' is required');
					} else {
						arg.value;
					}
					var parser = arg.type.createTypeParser(field.pos);
					argDocs.push(macro {
						name: $v{arg.name},
						isOptional: $v{arg.value != null}
					});

					macro switch __arguments[$v{index}] {
						case null: $defaultBranch;
						case value: $parser;
					}
				}];
				var validator = switch parsers.length {
					case 0:
						macro if (__arguments.length > 0) throw new kit.cli.parse.ParseException('Unexpected argument: ' + __arguments[0]);
					case len:
						macro if (__arguments.length > $v{len}) throw new kit.cli.parse.ParseException('Unexpected argument: ' + __arguments[$v{len}]);
				}

				builder.specHook().addExpr(macro kit.cli.Spec.SpecEntry.SpecCommand(
					[$a{commandNames}],
					[$a{argDocs}],
					$v{doc == null ? '(no documentation)' : doc},
					$v{isDefault}
				));

				if (parsers.length == 0) {
					builder.routerHook().addExpr(macro {
						if (${check}) {
							var __arguments = input.getArguments().slice(1);
							${validator};
							@:pos(field.pos) return this.$name();
						}
					});
					if (isDefault) {
						builder.defaultRouteHook().addExpr(macro {
							var __arguments = input.getArguments();
							${validator};
							@:pos(field.pos) return this.$name();
						});
					}
				} else {
					builder.routerHook().addExpr(macro {
						if (${check}) {
							var __arguments = input.getArguments().slice(1);
							${validator};
							@:pos(field.pos) return this.$name($a{parsers});
						}
					});
					if (isDefault) {
						builder.defaultRouteHook().addExpr(macro {
							var __arguments = input.getArguments();
							${validator};
							@:pos(field.pos) return this.$name($a{parsers});
						});
					}
				}
			default:
				field.pos.error('Expected a var or a method');
		}
	}
}
