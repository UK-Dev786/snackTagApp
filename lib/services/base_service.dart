import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:snacktag/services/firebase_storage_service.dart';

class BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseStorageService _storageService = FirebaseStorageService();

  Future<void> createDocument(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).doc(docId).set(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
      String collectionPath, String docId) {
    return _firestore.collection(collectionPath).doc(docId).get();
  }

  Future<void> updateDocument(
      String collectionPath, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collectionPath, String docId) async {
    await _firestore.collection(collectionPath).doc(docId).delete();
  }

  // Use the new storage service for image uploads
  Future<String> uploadImage(File imageFile, String folderName, String docId) async {
    print("[addmeal] 🔄 BaseService: Starting uploadImage process...");
    print("[addmeal] 📁 BaseService: Image path: ${imageFile.path}");
    print("[addmeal] 📏 BaseService: Image size: ${await imageFile.length()} bytes");
    print("[addmeal] 📂 BaseService: Target folder: $folderName");
    print("[addmeal] 🆔 BaseService: Document ID: $docId");
    
    try {
      print("[addmeal] 🔄 BaseService: Creating storage reference...");
      Reference ref = _storage.ref().child('$folderName/$docId.jpg');
      print("[addmeal] 🔄 BaseService: Starting upload task...");
      
      UploadTask uploadTask = ref.putFile(imageFile);
      print("[addmeal] 🔄 BaseService: Waiting for upload to complete...");
      
      // Add progress monitoring
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print("[addmeal] 📊 BaseService: Upload progress: ${progress.toStringAsFixed(1)}%");
      });
      
      TaskSnapshot snapshot = await uploadTask;
      print("[addmeal] ✅ BaseService: Upload completed successfully");
      
      print("[addmeal] 🔄 BaseService: Getting download URL...");
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("[addmeal] ✅ BaseService: Download URL obtained: $downloadUrl");
      
      print("[addmeal] 🏁 BaseService: uploadImage process completed successfully");
      return downloadUrl;
    } catch (e) {
      print('[addmeal] ❌ BaseService: Error uploading image: $e');
      print('[addmeal] ❌ BaseService: Stack trace: ${StackTrace.current}');
      throw Exception("Image upload failed: $e");
    }
  }

  // Use the new storage service for child image uploads
  Future<String> uploadChildImage(File imageFile, String folder, String docId) async {
    return await _storageService.uploadImage(imageFile, folder, docId);
  }

  // Use the new storage service for image deletion
  Future<void> deleteStorage(String folderName, String docId) async {
    await _storageService.deleteImage(folderName, docId);
  }

  Future<void> editDocuments(
      String collectionPath,
      String docId,
      String userId, // Add userId as a parameter
      Map<String, dynamic> data) async {

    try {
      // Fetch the document to ensure it belongs to the correct userId
      var docSnapshot = await _firestore.collection(collectionPath).doc(docId).get();

      // Check if the document exists and the userId matches
      if (docSnapshot.exists && docSnapshot.data()?['userId'] == userId) {
        // If userId matches, update the document with the provided data
        await _firestore.collection(collectionPath).doc(docId).update(data);
        print("Document updated successfully.");
      } else {
        print("Document not found or userId mismatch.");
      }
    } catch (e) {
      print("Error updating document: $e");
    }
  }
  /// ✅ Generic method to edit documents with user verification
  Future<void> editStaffDocuments(
      String collectionPath,
      String docId,
      String userId, // User ID to verify authorization
      Map<String, dynamic> data) async {
    try {
      // Fetch the document
      var docSnapshot = await _firestore.collection(collectionPath).doc(docId).get();

      // Ensure document exists and belongs to the correct user
      if (docSnapshot.exists && docSnapshot.data()?['userId'] == userId) {
        await _firestore.collection(collectionPath).doc(docId).update(data);
        print("✅ Document updated successfully.");
      } else {
        print("⚠️ Document not found.");
      }
    } catch (e) {
      print("❌ Error updating document: $e");
    }
  }
  // Check if a document with a specific field value exists
  Future<bool> isDocumentExists(String collectionPath, String field, String value) async {
    try {
      var querySnapshot = await _firestore
          .collection(collectionPath)
          .where(field, isEqualTo: value)
          .get();

      return querySnapshot.docs.isNotEmpty; // Returns true if document exists
    } catch (e) {
      print("Error checking document: $e");
      return false; // Assume not found in case of error
    }
  }

}
