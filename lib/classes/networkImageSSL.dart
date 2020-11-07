import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weiman/crawler/http.dart';

/// The dart:io implementation of [image_provider.NetworkImage].
class NetworkImageSSL extends ImageProvider<NetworkImage>
    implements NetworkImage {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const NetworkImageSSL(
    this.http,
    this.url, {
    this.scale = 1.0,
    this.headers,
    this.timeout = 8,
    this.reSort = false,
  })  : assert(url != null),
        assert(scale != null);

  final HttpBook http;

  final int timeout;
  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String> headers;

  final bool reSort;

  static void init(ByteData data) {}

  @override
  Future<NetworkImageSSL> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageSSL>(this);
  }

  @override
  ImageStreamCompleter load(NetworkImage key, DecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<NetworkImage>('Image key', key),
        ];
      },
    );
  }

  Future<Codec> _loadAsync(
    NetworkImageSSL key,
    StreamController<ImageChunkEvent> chunkEvents,
    DecoderCallback decode,
  ) async {
    try {
      assert(key == this);
      final Uint8List bytes = await http.getImage(url, reSort: reSort);
      if (bytes.lengthInBytes == 0)
        throw Exception('NetworkImage is an empty file: $url');
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
  int get hashCode => hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}
