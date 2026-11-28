import 'dart:async';

/// The data layer's memory of finished answers (family plan, data
/// contract). Every cached call is passed through [remember]; any screen
/// then reads a finished answer on its first frame ([knownOf]) instead of
/// waiting one frame and flashing a placeholder.
class Known {
  final Object? value;
  const Known(this.value);
}

final Expando<Known> _known = Expando<Known>();

/// Records [f]'s answer when it arrives, and returns [f].
Future<T> remember<T>(Future<T> f) {
  f.then((v) => _known[f] = Known(v), onError: (Object _) {});
  return f;
}

/// The finished answer of [f], or null while it is loading or failed.
Known? knownOf(Future<Object?>? f) => f == null ? null : _known[f];
