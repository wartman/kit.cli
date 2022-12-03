package cmdr;

enum Result {
  Success;
  Failure(code:Int);
  Async(handler:(done:(result:Result)->Void)->Void);
}
