import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class CameraProcessor {
  Future<Uint8List> preprocessImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) throw Exception("Invalid image");

    // Resize for model input (e.g., 300x300)
    image = img.copyResize(image, width: 300, height: 300);
    
    // Convert back to bytes
    return img.encodeJpg(image);
  }
}