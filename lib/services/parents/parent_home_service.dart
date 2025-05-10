import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snacktag/models/parents_models/add_children.dart';
import 'package:snacktag/models/parents_models/parent_add_wallet_model.dart';

class ParentHomeService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch all children for a specific parent ID
  Stream<List<ParentsAddChildren>> fetchChildrenByParentId(String parentId) {
    print("🔍 Fetching children for parent: $parentId");
    return firestore
        .collection("parentsChildren")
        .where("parentId", isEqualTo: parentId)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      List<ParentsAddChildren> children = snapshot.docs.map((doc) {
        var data = doc.data();
        // Ensure monthlyExpenditures is included
        if (!data.containsKey('monthlyExpenditures')) {
          print(
              "⚠️ Child ${doc.id} missing monthlyExpenditures field, defaulting to 0.0");
          data['monthlyExpenditures'] = 0.0;
        }
        print(
            "Child data: ${doc.id} - ${data['childName']} - Expenditures: ${data['monthlyExpenditures']}");
        return ParentsAddChildren.fromJson(data);
      }).toList();
      return children;
    });
  }

  // Fetch wallet data as a real-time stream
  Stream<ParentAddWalletModel?> fetchWalletStreamByParentId(String parentId) {
    print("🚀 Listening for wallet data changes for parentId: $parentId");

    return firestore
        .collection('users')
        .doc(parentId)
        .collection('ParentWalletAmount')
        .limit(1) // Fetch only one document
        .snapshots()
        .map((QuerySnapshot walletSnapshot) {
      if (walletSnapshot.docs.isEmpty) {
        print("🚀 No wallet data found for parentId: $parentId");
        return null;
      }

      DocumentSnapshot walletDoc = walletSnapshot.docs.first;
      String docId = walletDoc.id;
      Map<String, dynamic> data = walletDoc.data() as Map<String, dynamic>;

      ParentAddWalletModel wallet = ParentAddWalletModel.fromJson(data);
      wallet.id = docId;
      print("✅ Wallet Data Updated: ${wallet.toJson()}");

      return wallet;
    });
  }

  //FOR DELETING ALL CHILDREN ON THE BASE  ARE CHILDREN ARE IN SAME SCHOOL(OF YES OR NO)
  Future<bool> deleteChildByParentId(String parentId, String childId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // 🔍 Query the document to find the child
      QuerySnapshot querySnapshot = await firestore
          .collection('parentsChildren')
          .where('parentId', isEqualTo: parentId)
          .where('childId', isEqualTo: childId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("⚠️ No child found with ID: $childId under parent: $parentId");
        return false; // Child not found
      }

      // 🗑️ Delete the matched child document
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await firestore.collection('parentsChildren').doc(doc.id).delete();
      }

      print("✅ Successfully deleted child with ID: $childId");
      return true; // Success
    } catch (e) {
      print("❌ Error deleting child: $e");
      return false; // Failure
    }
  }
}
