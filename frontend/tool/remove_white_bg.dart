// one-off: 흰색/밝은 배경을 투명하게 만듦
// dart run tool/remove_white_bg.dart
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final projectRoot = Directory.current.path
      .replaceAll(r'\tool', '')
      .replaceAll('/tool', '');
  final srcPath = '$projectRoot/assets/images/knot_logo.png';
  final file = File(srcPath);
  if (!file.existsSync()) {
    print('Not found: $srcPath');
    exit(1);
  }
  final bytes = file.readAsBytesSync();
  img.Image? image = img.decodeImage(bytes);
  if (image == null) {
    print('Failed to decode image');
    exit(1);
  }
  // 알파 채널 있도록 변환 (PNG가 RGB만 있으면 투명 저장 안 됨)
  image = image.convert(numChannels: 4);

  // 밝은 픽셀(배경)을 투명하게 - 기준 완화해서 더 많은 하얀/연한색 제거
  const threshold = 228; // R,G,B 모두 이보다 크면 배경으로 간주
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      if (r >= threshold && g >= threshold && b >= threshold) {
        image.setPixelRgba(x, y, r, g, b, 0);
      }
    }
  }

  final outPath = '$projectRoot/assets/images/knot_logo.png';
  File(outPath).writeAsBytesSync(img.encodePng(image));
  print('Done: $outPath');
}
