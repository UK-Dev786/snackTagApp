class ParentAddWalletModel {
  String? id;
  double amount;
  bool enableMonthlyReload;
  String parrentId;
  double monthlyExpenditures;

  ParentAddWalletModel({
    this.id,
    required this.amount,
    required this.enableMonthlyReload,
    required this.parrentId,
    this.monthlyExpenditures = 0.0,
  });

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'enableMonthlyReload': enableMonthlyReload,
      'parentId': parrentId,
      'monthlyExpenditures': monthlyExpenditures
    };
  }

  // Factory method to create an instance from Firebase
  factory ParentAddWalletModel.fromJson(String? id, Map<String, dynamic> json) {
    return ParentAddWalletModel(
      id: id ?? json['userId'], // Use passed ID if available
      amount: (json['amount'] ?? 0).toDouble(), // Ensure double type
      enableMonthlyReload:
          json['enableMonthlyReload'] ?? false, // Default to false
      parrentId: json['parentId']?.toString() ?? '', // Ensure it's a string
      monthlyExpenditures:
          (json['monthlyExpenditures'] ?? 0).toDouble(), // Default to 0
    );
  }
}
