package cmdr;

typedef DocSpec = {
	public final doc:String;
	public final commands:Array<DocCommand>;
	public final flags:Array<DocFlag>;
}

typedef DocCommand = {
	public final isDefault:Bool;
	public final isSub:Bool;
	public final names:Array<String>;
	public final args:Array<DocCommandArg>;
	public final doc:String;
}

typedef DocCommandArg = {
	public final name:String;
	public final isOptional:Bool;	
}

typedef DocFlag = {
	public final aliases:Array<String>;
	public final names:Array<String>;
	public final doc:String;
}
