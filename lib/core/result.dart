sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Ok<T>;

  T? get valueOrNull => this is Ok<T> ? (this as Ok<T>).value : null;
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.message, {this.cause});

  final String message;

  final Object? cause;
}
