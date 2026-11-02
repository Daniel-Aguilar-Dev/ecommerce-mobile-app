const kMaxImageBytes = 2 * 1024 * 1024; // 2 MB

class ImageTooLargeException implements Exception {
  const ImageTooLargeException(this.message);
  final String message;

  @override
  String toString() => message;
}