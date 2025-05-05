import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static bool _appCheckVerified = false;

  // Ensure App Check is verified before any storage operation
  Future<void> _ensureAppCheck() async {
    if (!_appCheckVerified) {
      try {
        print("[addmeal] 🔄 FirebaseStorageService: Verifying App Check...");
        // Try to get a token to verify App Check is working
        final token = await FirebaseAppCheck.instance.getToken();
        print('[addmeal] ✅ FirebaseStorageService: App Check token verified: ${token != null}');
        _appCheckVerified = true;
      } catch (e) {
        print('[addmeal] ⚠️ FirebaseStorageService: App Check verification failed: $e');
        // Continue anyway, as Firebase will use a placeholder token
      }
    }
  }

  // Upload image with App Check verification
  Future<String> uploadImage(File imageFile, String folderName, String docId) async {
    print("[addmeal] 🔄 FirebaseStorageService: Starting image upload process...");
    await _ensureAppCheck();
    
    try {
      print("[addmeal] 📁 FirebaseStorageService: Image path: ${imageFile.path}");
      print("[addmeal] 📏 FirebaseStorageService: Image size: ${await imageFile.length()} bytes");
      print("[addmeal] 📂 FirebaseStorageService: Target folder: $folderName");
      print("[addmeal] 🆔 FirebaseStorageService: Document ID: $docId");
      
      Reference ref = _storage.ref().child('$folderName/$docId.jpg');
      print("[addmeal] 🔄 FirebaseStorageService: Created storage reference");
      
      UploadTask uploadTask = ref.putFile(imageFile);
      print("[addmeal] 🔄 FirebaseStorageService: Started upload task");
      
      // Add progress monitoring
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print("[addmeal] 📊 FirebaseStorageService: Upload progress: ${progress.toStringAsFixed(1)}%");
      });
      
      TaskSnapshot snapshot = await uploadTask;
      print("[addmeal] ✅ FirebaseStorageService: Upload completed successfully");
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("[addmeal] ✅ FirebaseStorageService: Download URL obtained: $downloadUrl");
      
      print("[addmeal] 🏁 FirebaseStorageService: Image upload process completed");
      return downloadUrl;
    } catch (e) {
      print('[addmeal] ❌ FirebaseStorageService: Error uploading image: $e');
      print('[addmeal] ❌ FirebaseStorageService: Stack trace: ${StackTrace.current}');
      throw Exception("Image upload failed: $e");
    }
  }

  // Delete image with App Check verification
  Future<void> deleteImage(String folderName, String docId) async {
    print("[addmeal] 🔄 FirebaseStorageService: Starting image deletion process...");
    await _ensureAppCheck();
    
    try {
      print("[addmeal] 📂 FirebaseStorageService: Target folder: $folderName");
      print("[addmeal] 🆔 FirebaseStorageService: Document ID: $docId");
      
      Reference ref = _storage.ref().child('$folderName/$docId.jpg');
      print("[addmeal] 🔄 FirebaseStorageService: Created storage reference");
      
      await ref.delete();
      print("[addmeal] ✅ FirebaseStorageService: Image deleted successfully");
    } catch (e) {
      print('[addmeal] ❌ FirebaseStorageService: Error deleting image: $e');
      print('[addmeal] ❌ FirebaseStorageService: Stack trace: ${StackTrace.current}');
      throw Exception("Image deletion failed: $e");
    }
  }

  // Get download URL with App Check verification
  Future<String> getDownloadURL(String folderName, String docId) async {
    await _ensureAppCheck();
    
    try {
      Reference ref = _storage.ref().child('$folderName/$docId.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      print('❌ Error getting download URL: $e');
      throw Exception("Failed to get download URL: $e");
    }
  }
}
