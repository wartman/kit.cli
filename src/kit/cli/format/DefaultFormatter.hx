package kit.cli.format;

import kit.cli.SpecFormatter;
import kit.cli.Spec;

using Kit;
using Lambda;
using StringTools;
using kit.cli.StyleTools;

class DefaultFormatter implements SpecFormatter {
	public function new() {}

	public function format(spec:Spec):String {
		var out = new StringBuf();

		inline function addLine(v:String) out.add(v + '\n');

		var flags = getFlags(spec);
		var routes = getRoutes(spec);
		var commands = getCommands(spec);

		addLine('');

		switch getDefaultCommand(spec) {
			case Some(SpecCommand(_, args, doc, _)):
				switch args.length {
					case 0:
						addLine(doc.pipe(cleanup(_), indent(_, 4)));
					default:
						addLine(indent(formatArgs(args) + ' : ' + cleanup(doc), 4));
				}
				addLine('');
			default:
		}

		if (routes.length > 0) {
			addLine(indent('Subcommands:', 4).bold());

			for (route in routes) {
				addLine(formatEntry(route, 6));
			}
		}

		if (commands.length > 0) {
			var len = getEntryIndent(commands);

			addLine(indent('Commands:', 4).bold());

			for (command in commands) {
				addLine(formatEntry(command, len));
			}
		}

		if (flags.length > 0) {
			var len = getEntryIndent(flags);

			addLine('');
			addLine(indent('Flags:', 4).bold());

			for (flag in flags) {
				addLine(formatEntry(flag, len));
			}
		}

		return out.toString();
	}

	function getFlags(spec:Spec) {
		return spec.filter(entry -> switch entry {
			case SpecFlag(_, _, _): true;
			default: false;
		});
	}

	function getRoutes(spec:Spec) {
		return spec.filter(entry -> switch entry {
			case SpecSub(_, _): true;
			default: false;
		});
	}

	function getCommands(spec:Spec) {
		return spec.filter(entry -> switch entry {
			case SpecCommand(_, _, _, false): true;
			default: false;
		});
	}

	function getDefaultCommand(spec:Spec) {
		return spec.find(entry -> switch entry {
			case SpecCommand(_, _, _, true): true;
			default: false;
		}).toMaybe();
	}

	function formatEntry(entry:SpecEntry, entryIndent:Int):String {
		var outName = formatEntryName(entry);
		return switch entry {
			case SpecCommand(_, args, doc, _):
				var outDoc = cleanup(doc);
				indent(outName.lpad(' ', entryIndent) + ' : ' + indent(outDoc, entryIndent + 3).trim(), 6);
			case SpecSub(subNames, spec):
				var out = indent(subNames.join(', ').bold() + ': ', entryIndent);
				out += indent(format(spec), entryIndent);
				out;
			case SpecFlag(_, _, doc):
				var outDoc = cleanup(doc);
				indent(
					outName.lpad(' ', entryIndent) + ' : ' + indent(doc, entryIndent + 3).trim(),
					6
				);
		}
	}

	function formatArgs(args:Array<CommandArg>) {
		return args.map(arg -> switch arg.isOptional {
			case true: '[${arg.name}]';
			case false: '<${arg.name}>';
		}).join(', ');
	}

	function getEntryIndent(entries:Array<SpecEntry>) {
		return entries.fold((entry, indent) -> {
			var len = formatEntryName(entry).length;
			if (len > indent) return len;
			return indent;
		}, 0);
	}

	function formatEntryName(entry:SpecEntry) {
		return switch entry {
			case SpecCommand(names, args, _, _):
				var outArgs = formatArgs(args);
				var outNames = names.join(', ');

				if (outArgs.length > 0) return outNames + ' ' + outArgs;
				outNames;
			case SpecSub(names, spec):
				var outNames = names.join(', ');
				var outArgs = spec
					.find(entry -> switch entry {
						case SpecCommand(_, _, _, true): true;
						default: false;
					})
					.toMaybe()
					.map(entry -> {
						entry.extract(try SpecCommand(_, args, _, _));
						args;
					})
					.map(formatArgs)
					.or('');

				if (outArgs.length > 0) return outNames + ' ' + outArgs;

				outNames;
			case SpecFlag(names, shortNames, _):
				names.concat(shortNames ?? []).join(', ');
		}
	}

	function indent(value:String, level:Int) {
		if (value == null) return '';

		return value
			.split('\n')
			.map(part -> ''.lpad(' ', level) + part)
			.join('\n');
	}

	function cleanup(value:String) {
		if (value == null) return '';

		var lines = value.split('\n').map(StringTools.trim);

		while (lines[0] == '') lines.shift();
		while (lines[lines.length - 1] == '') lines.pop();

		return lines.join('\n');
	}
}
