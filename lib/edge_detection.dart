import 'dart:async';

import 'package:flutter/services.dart';

class EdgeDetection {
  static const MethodChannel _channel = const MethodChannel('edge_detection');

  /// Call this method to scan the object edge in live camera.
  static Future<bool> detectEdge(String saveTo,
      {
        bool canUseGallery: false,
        String androidScanTitle: "Scanning",
        String androidCropTitle: "Crop",
        String androidCropBlackWhiteTitle: "Black White",
        String androidCropReset: "Reset",
      }) async {
    return await _channel.invokeMethod('edge_detect', {
      'save_to': saveTo,
      'can_use_gallery': false,
      'scan_title': androidScanTitle,
      'crop_title': androidCropTitle,
      'crop_black_white_title': androidCropBlackWhiteTitle,
      'crop_reset_title': androidCropReset,
    });
  }

  /// Call this method to scan the object edge from a gallery image.
  static Future<bool> detectEdgeFromGallery(String saveTo,
      {
         bool canUseGallery: true,
        String androidCropTitle: "Crop",
        String androidCropBlackWhiteTitle: "Black White",
        String androidCropReset: "Reset",
      }) async {
    return await _channel.invokeMethod('edge_detect_gallery', {
      'save_to': saveTo,
      'crop_title': androidCropTitle,
      'crop_black_white_title': androidCropBlackWhiteTitle,
      'crop_reset_title': androidCropReset,
      'can_use_gallery': true,
    });
  }
}
