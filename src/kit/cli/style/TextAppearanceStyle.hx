package kit.cli.style;

enum abstract TextAppearanceStyleName(String) from String to String {
	final Bold = 'bold';
	final Underscore = 'underscore';
}

class TextAppearanceStyle implements Style {
	public final name:String;

	public function new(name:TextAppearanceStyleName) {
		this.name = name;
	}

	public function apply(value:StyledText):Void {
		switch (name : TextAppearanceStyleName) {
			case Bold: value.addOption({set: 1, unset: 22});
			case Underscore: value.addOption({set: 4, unset: 24});
		}
	}
}
