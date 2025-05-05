import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

abstract class BaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

  // New method to delete image from Firebase Storage
  Future<void> deleteStorage(String folderName, String docId) async {
    try {
      Reference ref = _storage.ref().child('$folderName/$docId.jpg');
      await ref.delete(); // Delete the image from Firebase Storage
    } catch (e) {
      throw Exception("Image deletion failed: $e");
    }
  }
  Future<String> uploadChildImage(File imageFile, String folder, String docId) async {
    try {
      // Create reference to Firebase Storage
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("$folder/$docId.jpg"); // Save with document ID as filename

      // Upload file
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image uploaded successfully: $downloadUrl");

      return downloadUrl; // Return the URL to store in Firestore
    } catch (e) {
      print("Error uploading image: $e");
      return ""; // Return empty string if upload fails
    }
  }

  Future<String> uploadImage(
      File imageFile, String folderName, String docId) async {
    try {
      Reference ref = _storage.ref().child('$folderName/$docId.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Image upload failed: $e");
    }
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
