import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealDetailsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    print("MealDetailsController initialized");
    fetchMealDetails();
  }

  Future<void> fetchMealDetails() async {
    try {
      isLoading.value = true;
      // Add your fetch logic here
      
    } catch (e) {
      errorMessage.value = 'Error fetching meal details: $e';
      print("❌ Error in fetchMealDetails: $e");
    } finally {
      isLoading.value = false;
      update(['mealDetailsId']);
    }
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
  }
}