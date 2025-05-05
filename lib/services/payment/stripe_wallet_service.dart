import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';

class StripeWalletService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://app-2ez2tbzmhq-uc.a.run.app';

  Future<bool> processWalletPayment(double amount) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // 1. Create or get Stripe customer
      final customerResponse = await _dio.post(
        '$_baseUrl/create_customer',
        data: {
          'phone': user.phoneNumber,
          'userId': user.uid,
        },
      );

      if (customerResponse.data['status'] != 'success') {
        throw Exception('Failed to create customer');
      }

      final customerId = customerResponse.data['customer'];

      // 2. Create payment intent
      final paymentIntentResponse = await _dio.post(
        '$_baseUrl/create_payment_intent',
        data: {
          'amount': (amount * 100).toInt(), // Convert to cents
          'currency': 'mxn',
          'customer': customerId,
        },
      );

      final clientSecret = paymentIntentResponse.data['clientSecret'];
      final ephemeralKey = paymentIntentResponse.data['ephemeralKey'];

      // 3. Configure payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Snack Tag',
          customerId: customerId,
          paymentIntentClientSecret: clientSecret,
          customerEphemeralKeySecret: ephemeralKey,
        ),
      );

      // 4. Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      print('Error processing payment: $e');
      return false;
    }
  }
}
