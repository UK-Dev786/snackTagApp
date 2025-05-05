import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  // Variables to hold the selected image file and image URL (if needed)
  File? selectedImage;
  String imageUrl = '';

  // Method to pick an image from the gallery
  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
      imageUrl = ''; // Clear the old network image when new one is picked
    }
  }

  // Optionally, you can add a method to retrieve the selected image
  File? getSelectedImage() {
    return selectedImage;
  }

  // Optionally, add a method to retrieve the image URL (if used)
  String getImageUrl() {
    return imageUrl;
  }
}
