package kit.cli;

typedef Spec = Array<SpecEntry>;

enum SpecEntry {
	SpecCommand(names:Array<String>, args:Array<CommandArg>, doc:String, isSub:Bool, isDefault:Bool);
	SpecFlag(names:Array<String>, aliases:Array<String>, doc:String);
}

typedef CommandArg = {
	public final name:String;
	public final isOptional:Bool;
}
