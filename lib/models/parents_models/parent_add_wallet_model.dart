import 'package:cloud_firestore/cloud_firestore.dart';

class ParentAddWalletModel {
  String? id;
  String parrentId;
  double amount;
  bool enableMonthlyReload;
  double? monthlyExpenditures;
  DateTime? createdAt;
  DateTime? updatedAt;

  ParentAddWalletModel({
    this.id,
    required this.parrentId,
    required this.amount,
    this.enableMonthlyReload = false,
    this.monthlyExpenditures = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor to create a model from a map (e.g., from Firestore)
  factory ParentAddWalletModel.fromJson(Map<String, dynamic> json) {
    // Handle type conversion for amount
    double amount = 0.0;
    if (json['amount'] is int) {
      amount = (json['amount'] as int).toDouble();
    } else if (json['amount'] is double) {
      amount = json['amount'];
    } else if (json['amount'] != null) {
      amount = double.tryParse(json['amount'].toString()) ?? 0.0;
    }

    // Handle type conversion for monthlyExpenditures
    double monthlyExpenditures = 0.0;
    if (json['monthlyExpenditures'] is int) {
      monthlyExpenditures = (json['monthlyExpenditures'] as int).toDouble();
    } else if (json['monthlyExpenditures'] is double) {
      monthlyExpenditures = json['monthlyExpenditures'];
    } else if (json['monthlyExpenditures'] != null) {
      monthlyExpenditures =
          double.tryParse(json['monthlyExpenditures'].toString()) ?? 0.0;
    }

    // Handle timestamps with proper null checking and type conversion
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      if (json['createdAt'] is Timestamp) {
        createdAt = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is DateTime) {
        createdAt = json['createdAt'] as DateTime;
      }
    }

    DateTime? updatedAt;
    if (json['updatedAt'] != null) {
      if (json['updatedAt'] is Timestamp) {
        updatedAt = (json['updatedAt'] as Timestamp).toDate();
      } else if (json['updatedAt'] is DateTime) {
        updatedAt = json['updatedAt'] as DateTime;
      }
    }

    return ParentAddWalletModel(
      id: json['id'],
      parrentId: json['parentId'] ?? json['parrentId'] ?? '',
      amount: amount,
      enableMonthlyReload: json['enableMonthlyReload'] ?? false,
      monthlyExpenditures: monthlyExpenditures,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parrentId': parrentId,
      'amount': amount,
      'enableMonthlyReload': enableMonthlyReload,
      'monthlyExpenditures': monthlyExpenditures ?? 0.0,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
