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
			@:noCompletion var backing_input:Null<kit.cli.Input> = null;

			public var input(get, never):kit.cli.Input;

			function get_input():kit.cli.Input {
				if (backing_input == null) {
					throw 'Attempted to access Input before the Command was ready.'
						+ ' Generally, you should only be using kit.cli.Command inside'
						+ ' a kit.cli.Cli, which will set things up for you.';
				}
				return backing_input;
			}

			@:noCompletion var backing_output:Null<kit.cli.Output> = null;

			public var output(get, never):kit.cli.Output;

			function get_output():kit.cli.Output {
				if (backing_output == null) {
					throw 'Attempted to access Output before the Command was ready.'
						+ ' Generally, you should only be using kit.cli.Command inside'
						+ ' a kit.cli.Cli, which will set things up for you.';
				}
				return backing_output;
			}

			public function process(input:kit.cli.Input, output:kit.cli.Output):kit.Task<Int> {
				backing_input = input;
				backing_output = output;

				try {
					@:mergeBlock $b{process};
					var __command = input.getArguments()[0];
					@:mergeBlock $b{router};
					@:mergeBlock $b{builder.defaultRouteHook().getExprs()};
				} catch (e:kit.cli.parse.ParseException) {
					output.error(e.message);
					output.writeLn(getDocs());
					return kit.Task.resolve(1);
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
