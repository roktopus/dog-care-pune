import 'dart:io';

import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image/image.dart' as img;

class PhotoVerdict {
  const PhotoVerdict({required this.clear, required this.showsDog, required this.detail});

  final bool clear;
  final bool showsDog;
  final String detail;

  bool get accepted => clear && showsDog;

  static const pending = PhotoVerdict(clear: false, showsDog: false, detail: 'The photo has not been checked yet.');
}

class PhotoCheck {
  static Future<PhotoVerdict> inspect(String path) async {
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return const PhotoVerdict(clear: false, showsDog: false, detail: 'This file could not be read as a photo.');
    }
    if (decoded.width < 480 || decoded.height < 480) {
      return const PhotoVerdict(clear: false, showsDog: false, detail: 'The photo is too small. Move closer and take it again.');
    }
    final sharp = _sharpness(decoded);
    if (sharp < 18) {
      return PhotoVerdict(clear: false, showsDog: false, detail: 'The photo is blurry (sharpness ${sharp.toStringAsFixed(0)}). Hold the phone steady and retake it.');
    }
    final showsDog = await _labelsDog(path);
    if (!showsDog) {
      return const PhotoVerdict(clear: true, showsDog: false, detail: 'The photo is sharp, but no dog was detected. Take a photo where the dog is visible.');
    }
    return PhotoVerdict(clear: true, showsDog: true, detail: 'A dog is visible and the photo is sharp enough (sharpness ${sharp.toStringAsFixed(0)}).');
  }

  static double _sharpness(img.Image source) {
    final sample = img.copyResize(source, width: 160);
    final gray = img.grayscale(sample);
    var sum = 0.0;
    var sumSq = 0.0;
    var count = 0;
    for (var y = 1; y < gray.height - 1; y++) {
      for (var x = 1; x < gray.width - 1; x++) {
        final center = gray.getPixel(x, y).r.toDouble();
        final lap = gray.getPixel(x, y - 1).r + gray.getPixel(x, y + 1).r + gray.getPixel(x - 1, y).r + gray.getPixel(x + 1, y).r - 4 * center;
        sum += lap;
        sumSq += lap * lap;
        count++;
      }
    }
    if (count == 0) return 0;
    final mean = sum / count;
    return (sumSq / count) - (mean * mean);
  }

  static Future<bool> _labelsDog(String path) async {
    final labeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.45));
    try {
      final labels = await labeler.processImage(InputImage.fromFilePath(path));
      const dogs = ['dog', 'puppy', 'canine', 'hound'];
      return labels.any((label) => dogs.any(label.label.toLowerCase().contains));
    } finally {
      await labeler.close();
    }
  }
}
