using Kit;
using kit.Cli;

function main() {
	var cli = Cli.fromSys();
	cli.execute(new Greeter());
}

/**
	A CLI app to say hello.
**/
class Greeter implements Command {
	/** Set the greeting. Defaults to "Hello" **/
	@:flag var greeting:String = 'Hello';

	/** Set the location. Defaults to "world" **/
	@:flag var location:String = 'world';

	public function new() {}

	/** Greet a person! **/
	@:command('greet-person')
	function greet(person:String):Task<Int> {
		output
			.write(greeting.color(Blue))
			.write(' ')
			.write(person.bold().backgroundColor(White))
			.write(' who is located in the ')
			.writeLn(location);
		return 0;
	}

	/** Get a list of commands. **/
	@:command
	function help():Task<Int> {
		output.write(getDocs());
		return 0;
	}

	/** Greet everyone! **/
	@:defaultCommand
	function defaultGreeting(person:String = null):Task<Int> {
		if (person != null) return greet(person);
		output.writeLn('$greeting $location');
		return 0;
	}
}
