class HttpException implements Exception {
  String massage;

  HttpException(this.massage);

  @override
  String toString() {
    return massage;
  }
}
