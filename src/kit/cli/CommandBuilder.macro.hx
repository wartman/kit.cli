package kit.cli;

import kit.cli.macro.*;
import kit.macro.*;

using kit.cli.macro.Tools;

function build() {
	return ClassBuilder.fromContext()
		.addBundle(new CommandBuilder())
		.export();
}

class CommandBuilder implements BuildBundle implements BuildStep {
	public final priority:Priority = Late;

	public function new() {}

	public function steps():Array<BuildStep> {
		return [
			new CommandFieldBuildStep(),
			new FlagFieldBuildStep(),
			this
		];
	}

	public function apply(builder:ClassBuilder) {
		var router = builder.routerHook().getExprs();
		var process = builder.processHook().getExprs();
		var spec = builder.specHook().getExprs();

		builder.add(macro class {
			@:noCompletion var backing_arguments:Null<kit.cli.Arguments> = null;

			public var arguments(get, never):kit.cli.Arguments;

			function get_arguments():kit.cli.Arguments {
				if (backing_arguments == null) {
					throw 'Attempted to access Arguments before the Command was ready.'
						+ ' Generally, you should only be using kit.cli.Command inside'
						+ ' a kit.cli.Cli, which will set things up for you.';
				}
				return backing_arguments;
			}

			@:noCompletion var backing_console:Null<kit.cli.Console> = null;

			public var console(get, never):kit.cli.Console;

			function get_console():kit.cli.Console {
				if (backing_console == null) {
					throw 'Attempted to access Console before the Command was ready.'
						+ ' Generally, you should only be using kit.cli.Command inside'
						+ ' a kit.cli.Cli, which will set things up for you.';
				}
				return backing_console;
			}

			public function process(arguments:kit.cli.Arguments, console:kit.cli.Console):kit.Task<Int> {
				backing_arguments = arguments;
				backing_console = console;

				try {
					@:mergeBlock $b{process};
					var __command = arguments.getArguments()[0];
					@:mergeBlock $b{router};
					@:mergeBlock $b{builder.defaultRouteHook().getExprs()};
				} catch (e) {
					console.error(e.message);
					console.writeLine(getDocs());
					return kit.Task.ok(1);
				}
			}

			public function getSpec():kit.cli.Spec {
				return [$a{spec}];
			}

			public function getDocs():String {
				return new kit.cli.format.DefaultFormatter().format(getSpec());
			}
		});
	}
}
