package kit.cli;

typedef Spec = Array<SpecEntry>;

enum SpecEntry {
	SpecCommand(names:Array<String>, args:Array<CommandArg>, doc:String, isDefault:Bool);
	SpecSub(names:Array<String>, spec:Spec);
	SpecFlag(names:Array<String>, shortNames:Array<String>, doc:String);
}

typedef CommandArg = {
	public final name:String;
	public final isOptional:Bool;
}
