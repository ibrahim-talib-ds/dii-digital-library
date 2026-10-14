/// Tiny Result type used by every repository.
/// Either Ok(data) or Err(exception).
sealed class Result<T> {
  const Result();
}

class Ok<T> extends Result<T> {
  final T data;
  const Ok(this.data);
}

class Err<T> extends Result<T> {
  final Object error;
  const Err(this.error);
}

extension ResultX<T> on Result<T> {
  bool get isOk  => this is Ok<T>;
  bool get isErr => this is Err<T>;
  T? get valueOrNull => this is Ok<T> ? (this as Ok<T>).data : null;
  Object? get errorOrNull => this is Err<T> ? (this as Err<T>).error : null;
}
