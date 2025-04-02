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

		// Ensure we don't eat the previous character:
		console.write(getCurrentFrame());

		timer = new Timer(80);
		timer.run = render;
	}

	public function render() {
		var frame = getCurrentFrame();
		console.moveCursor(frame.length * -1).write(frame);
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

	function getCurrentFrame() {
		currentFrame++;
		if (currentFrame > frames.length - 1) {
			currentFrame = 0;
		}
		var frame = frames[currentFrame];
		return frame;
	}
}
