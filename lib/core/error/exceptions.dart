class ServerException  implements Exception { final String message; const ServerException(this.message);  @override String toString() => message; }
class CacheException   implements Exception { final String message; const CacheException(this.message);   @override String toString() => message; }
class NetworkException implements Exception { const NetworkException(); @override String toString() => 'No internet connection'; }
