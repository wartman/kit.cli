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

		var flags = spec.filter(entry -> switch entry {
			case SpecFlag(_, _, _): true;
			default: false;
		});
		var defaultCommands = spec.filter(entry -> switch entry {
			case SpecCommand(_, _, _, _, true): true;
			default: false;
		});
		var commands = spec.filter(entry -> switch entry {
			case SpecCommand(_, _, _, _, _): true;
			default: false;
		});

		addLine('');

		switch defaultCommands {
			case [SpecCommand(_, _, doc, _, _)]:
				addLine(doc + '\n');
			default:
		}

		if (commands.length > 0) {
			var len = getEntryIndent(commands);

			addLine(indent('Subcommands:', 4).bold());

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

	function formatEntry(entry:SpecEntry, entryIndent:Int):String {
		var outName = formatEntryName(entry);
		return switch entry {
			case SpecCommand(_, args, doc, isSub, isDefault):
				var outDoc = cleanup(doc);
				indent(outName.lpad(' ', entryIndent) + ' : ' + indent(outDoc, entryIndent + 3).trim(), 6);

			case SpecFlag(_, aliases, doc):
				var outDoc = doc?.split('\n')?.map(s -> s.trim()).join('\n') ?? '';
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
			case SpecCommand(names, args, _, _, isDefault):
				var outArgs = formatArgs(args);
				var outNames = isDefault ? '*' : names.join(', ');

				if (outArgs.length > 0) return outNames + ' ' + outArgs;
				outNames;
			case SpecFlag(names, _, _):
				names.join(', ');
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
