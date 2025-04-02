package kit.cli.display;

import haxe.Timer;

class Spinner {
	final console:Console;
	final frames:Array<String>;
	var currentFrame = 0;
	var timer:Null<Timer> = null;

	public function new(console, ?frames) {
		this.console = console;
		this.frames = frames ?? ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
	}

	public function start() {
		if (timer != null) stop();
		console.hideCursor();
		timer = new Timer(80);
		timer.run = render;
	}

	public function render() {
		currentFrame++;
		if (currentFrame > frames.length - 1) {
			currentFrame = 0;
		}
		var frame = frames[currentFrame];
		console.setCursorPosition(frame.length * -1).write(frame);
	}

	public function stop() {
		if (timer == null) return;
		console.clear().showCursor();
		currentFrame = 0;
		timer.stop();
		timer = null;
	}

	public function isRunning() {
		return timer != null;
	}
}
