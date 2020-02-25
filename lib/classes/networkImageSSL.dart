part of '../main.dart';

/// The dart:io implementation of [image_provider.NetworkImage].
class NetworkImageSSL
    extends image_provider.ImageProvider<image_provider.NetworkImage>
    implements image_provider.NetworkImage {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const NetworkImageSSL(
    this.url, {
    this.scale = 1.0,
    this.headers,
    this.timeout = 8,
  })  : assert(url != null),
        assert(scale != null);

  final int timeout;
  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String> headers;

  static void init(ByteData data) {}

  @override
  Future<NetworkImageSSL> obtainKey(
      image_provider.ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageSSL>(this);
  }

  @override
  image_provider.ImageStreamCompleter load(
      image_provider.NetworkImage key, image_provider.DecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<image_provider.ImageChunkEvent> chunkEvents =
        StreamController<image_provider.ImageChunkEvent>();

    return image_provider.MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<image_provider.ImageProvider>(
              'Image provider', this),
          DiagnosticsProperty<image_provider.NetworkImage>('Image key', key),
        ];
      },
    );
  }

  // Do not access this field directly; use [_httpClient] instead.
  // We set `autoUncompress` to false to ensure that we can trust the value of
  // the `Content-Length` HTTP header. We automatically uncompress the content
  // in our call to [consolidateHttpClientResponseBytes].
  static HttpClient _sharedHttpClient = HttpClient()
    ..autoUncompress = false
    ..badCertificateCallback = (_, __, ___) => true;

  static HttpClient get _httpClient {
    return _sharedHttpClient;
  }

  Future<ui.Codec> _loadAsync(
    NetworkImageSSL key,
    StreamController<image_provider.ImageChunkEvent> chunkEvents,
    image_provider.DecoderCallback decode,
  ) async {
    try {
      assert(key == this);

      final Uri resolved = Uri.base.resolve(key.url);
      final HttpClientRequest request = await _httpClient
          .getUrl(resolved)
          .timeout(Duration(seconds: timeout));
      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok)
        throw image_provider.NetworkImageLoadException(
            statusCode: response.statusCode, uri: resolved);

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int total) {
          chunkEvents.add(image_provider.ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );
      if (bytes.lengthInBytes == 0)
        throw Exception('NetworkImage is an empty file: $resolved');

      return decode(bytes);
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final NetworkImageSSL typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => ui.hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}
