class CropConfig {
  final bool isCircle;
  final double? maxWidth;
  final double? maxHeight;
  final int quality;

  CropConfig({
    this.isCircle = false,
    this.maxWidth = 1024,
    this.maxHeight = 1024,
    this.quality = 85,
  });
}
