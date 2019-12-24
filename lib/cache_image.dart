library cache_image;

import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cache_image/resource.dart';

/*
 *  ImageCache for Flutter
 *
 *  Copyright (c) 2019 Oxequa - Alessio Pracchia
 *  Keep in touch https://www.linkedin.com/in/alessio-pracchia/
 *
 *  Released under MIT License.
 */

class CacheImage extends ImageProvider<CacheImage> {
  CacheImage(
    String url, {
    this.scale = 1.0,
    this.cache = true,
    this.duration = const Duration(seconds: 1),
    this.durationMultiplier = 1.5,
    this.durationExpiration = const Duration(seconds: 10),
  })  : assert(url != null),
        _resource = Resource(url, duration, durationMultiplier, durationExpiration);

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// Enable or disable image caching.
  final bool cache;

  /// Retry duration if download fails.
  final Duration duration;

  /// Retry duration multiplier.
  final double durationMultiplier;

  /// Retry duration expiration.
  final Duration durationExpiration;

  Resource _resource;

  Future<Codec> _fetchImage() async {
    Uint8List file;
    await _resource.init();
    final bool check = await _resource.checkFile();
    if (check) {
      file = await _resource.getFile();
    } else {
      file = await _resource.storeFile();
    }
    if(file.length > 0) {
      return PaintingBinding.instance.instantiateImageCodec(file);
    }
    return null;
  }

  @override
  Future<CacheImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CacheImage>(this);
  }

  @override
  ImageStreamCompleter load(CacheImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: key._fetchImage(),
      scale: key.scale,
      informationCollector: () sync* {
        yield DiagnosticsProperty<ImageProvider>(
          'Image provider: $this \n Image key: $key', this,
          style: DiagnosticsTreeStyle.errorProperty
        );
      }
    );
  }
}
