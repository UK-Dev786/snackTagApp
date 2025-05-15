import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/parent_add_wallet_model.dart';
import 'package:snacktag/services/base_service.dart';

class ParentAddWalletService extends BaseService {
  Future<void> addOrUpdateWalletAmount(ParentAddWalletModel model) async {
    try {
      // Reference to the user's wallet document
      DocumentReference userWalletRef = FirebaseFirestore.instance
          .collection("users")
          .doc(model.parrentId)
          .collection("ParentWalletAmount")
          .doc(model.parrentId);

      DocumentSnapshot walletSnapshot = await userWalletRef.get();

      if (walletSnapshot.exists) {
        // Wallet exists, update the amount
        // Convert to double to ensure type safety
        double existingAmount = 0.0;
        var rawAmount =
            (walletSnapshot.data() as Map<String, dynamic>)['amount'];
        if (rawAmount is int) {
          existingAmount = rawAmount.toDouble();
        } else if (rawAmount is double) {
          existingAmount = rawAmount;
        } else if (rawAmount != null) {
          existingAmount = double.tryParse(rawAmount.toString()) ?? 0.0;
        }

        double newTotalAmount = existingAmount + model.amount;

        await userWalletRef.update({
          'amount': newTotalAmount,
          'enableMonthlyReload': model.enableMonthlyReload,
          'parentId': model.parrentId,
          'updatedAt': FieldValue.serverTimestamp(),
          'monthlyExpenditures': model.monthlyExpenditures ?? 0.0,
        });

        print(
            "✅ Wallet amount updated successfully for user: ${model.parrentId}");
      } else {
        // Wallet doesn't exist, create a new one for the user
        model.id = userWalletRef.id;
        await userWalletRef.set({
          'id': model.id,
          'parentId': model.parrentId,
          'amount': model.amount,
          'enableMonthlyReload': model.enableMonthlyReload,
          'monthlyExpenditures': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        print("✅ New wallet created for user: ${model.parrentId}");
      }
    } catch (e) {
      print("❌ Error updating wallet amount for user ${model.parrentId}: $e");
      // Re-throw the error to be caught by the calling function
      rethrow;
    }
  }

  // Deduct payment from parent wallet
  Future<bool> deductPaymentFromWallet(String parentId, double amount,
      {bool updateMonthlyExpenditures = true}) async {
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

      // Calculate new amount
      double newAmount = currentAmount - amount;

      // Calculate new monthly expenditures if needed
      double newMonthlyExpenditures = currentMonthlyExpenditures;
      if (updateMonthlyExpenditures) {
        newMonthlyExpenditures = currentMonthlyExpenditures + amount;
      }

      // Update wallet with deducted amount and optionally increased expenditures
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
