package cmdr;

@:forwardStatics
abstract Result(ResultImpl) from ResultImpl to ResultImpl {
  @:from public static function ofInt(int:Int):Result {
    return switch int {
      case 0: Success;
      case other: Failure(other);
    }
  }

  @:from public static function ofAsync(handler:AsyncResultHandler):Result {
    return Async(handler);
  }

  public inline static function failure(code:Int, ?message:String):Result {
    return Failure(code, message);
  }
  
  public inline function new(result) {
    this = result;   
  }

  public inline function unwrap():ResultImpl {
    return this;
  }

  #if tink_core
  @:from public static function ofPromise(promise:tink.core.Promise<tink.core.Noise>):Result {
    return Async(done -> promise.handle(outcome -> switch outcome {
      case Success(_): done(Success);
      case Failure(err): done(Failure(1, err.message));
    }));
  }
  #end
}

typedef AsyncResultHandler = (done:(result:Result)->Void)->Void; 

enum ResultImpl {
  Success;
  Failure(code:Int, ?message:String);
  Async(handler:AsyncResultHandler);
}
