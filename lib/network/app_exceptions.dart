class AppExceptions implements Exception {
  final message;
  final prefix;

  AppExceptions([this.message, this.prefix]);

  @override
  String toString() {
    return "$message $prefix";
  }
}

class ConnectionExceptions extends AppExceptions {
  ConnectionExceptions([String? message]) : super(message, 'No Internet');
}

class ConnectionTimeoutException extends AppExceptions {
  ConnectionTimeoutException([String? message])
      : super(message, 'Request Timeout');
}

class ServerException extends AppExceptions {
  ServerException([String? message]) : super(message, 'Internal Server Error');
}

class InvalidUrlException extends AppExceptions {
  InvalidUrlException([String? message]) : super(message, 'Url Not Found!!!');
}

class FetchDataException extends AppExceptions {
  FetchDataException([String? message])
      : super(message, 'Internal Server Error');
}

class BadResponseException extends AppExceptions {
  BadResponseException([String? message])
      : super(message,
            'Bad Response Error!!! Check Api URL or parameters are invalid');
}
