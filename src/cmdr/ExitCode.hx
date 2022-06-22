package cmdr;

// https://tldp.org/LDP/abs/html/exitcodes.html
enum abstract ExitCode(Int) {
  final Success = 0;
  final Failure = 1;
  final Invalid = 2;
}
