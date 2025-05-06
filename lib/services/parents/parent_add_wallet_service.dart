import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/parent_add_wallet_model.dart';
import 'package:snacktag/services/base_service.dart';

class ParentAddWalletService extends BaseService {
  Future<void> addOrUpdateWalletAmount(ParentAddWalletModel model) async {
    try {
      // Reference to the user's wallet document
      DocumentReference userWalletRef = FirebaseFirestore.instance
          .collection("users")
          .doc(model.parrentId) // Unique wallet per user
          .collection("ParentWalletAmount")
          .doc(model
              .parrentId); // Use userId as document ID to make it unique per user

      DocumentSnapshot walletSnapshot = await userWalletRef.get();

      if (walletSnapshot.exists) {
        // Wallet exists, update the amount
        double existingAmount =
            (walletSnapshot.data() as Map<String, dynamic>)['amount'] ?? 0.0;
        double newTotalAmount = existingAmount + model.amount;

        await userWalletRef.update({
          'amount': newTotalAmount,
          'enableMonthlyReload': model.enableMonthlyReload, // Update boolean
          'updatedAt': FieldValue.serverTimestamp(), // Store last update time
          'monthlyExpenditures':
              model.monthlyExpenditures, // Update monthly expenditures
        });

        print(
            "✅ Wallet amount updated successfully for user: ${model.parrentId}");
      } else {
        // Wallet doesn't exist, create a new one for the user
        model.id = userWalletRef.id;
        await userWalletRef.set({
          'id': model.id,
          'userId': model.parrentId,
          'amount': model.amount, // Set initial amount
          'enableMonthlyReload': model.enableMonthlyReload,
          'monthlyExpenditures': 0.0, // Initialize monthly expenditures
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print("✅ New wallet created for user: ${model.parrentId}");
      }
    } catch (e) {
      print("❌ Error updating wallet amount for user ${model.parrentId}: $e");
    }
  }

  // Deduct payment from parent wallet
  Future<bool> deductPaymentFromWallet(String parentId, double amount) async {
    try {
      // Reference to the user's wallet document
      DocumentReference userWalletRef = FirebaseFirestore.instance
          .collection("users")
          .doc(parentId)
          .collection("ParentWalletAmount")
          .doc(parentId);

      // Get current wallet data
      DocumentSnapshot walletSnapshot = await userWalletRef.get();

      if (!walletSnapshot.exists) {
        print("❌ Wallet not found for parent: $parentId");
        return false;
      }

      // Get current amount
      double currentAmount =
          (walletSnapshot.data() as Map<String, dynamic>)['amount'] ?? 0.0;
      double currentMonthlyExpenditures = (walletSnapshot.data()
              as Map<String, dynamic>)['monthlyExpenditures'] ??
          0.0;

      // Check if there's enough balance
      if (currentAmount < amount) {
        print(
            "⚠️ Insufficient funds in parent wallet: $parentId. Available: $currentAmount, Required: $amount");
        return false;
      }

      // Calculate new amount and update monthly expenditures
      double newAmount = currentAmount - amount;
      double newMonthlyExpenditures = currentMonthlyExpenditures + amount;

      // Update wallet with deducted amount and increased expenditures
      await userWalletRef.update({
        'amount': newAmount,
        'monthlyExpenditures': newMonthlyExpenditures,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print(
          "✅ Payment of $amount deducted from parent wallet: $parentId. New balance: $newAmount, Monthly expenditures: $newMonthlyExpenditures");
      return true;
    } catch (e) {
      print("❌ Error deducting payment from parent wallet: $e");
      return false;
    }
  }
}
