import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentService {
  static const String _baseUrl = 'https://app-2ez2tbzmhq-uc.a.run.app';
  final Dio _dio = Dio();

  // Simple logging method to avoid using print directly
  void _log(String message) {
    // In a production app, you would use a proper logging framework here
    debugPrint(message);
  }

  Future<void> initializeStripe() async {
    Stripe.publishableKey =
        'pk_test_51Qz5ao08zT37J1Lvgay2AfgAVN3ANqMnvc2MSsXKepaLSVF8EpV4iUwRkJVF06FsEYXOnQNnjg83NOfkVLTSv0Mv00kDI0wRJw';
    // Set default currency to MXN (Mexican Peso) in the API calls
    await Stripe.instance.applySettings();
  }

  Future<String> createCustomer(String userId) async {
    try {
      // Get user phone from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Use phone number if available, otherwise use a placeholder email with userId
      String phoneNumber = user.phoneNumber ?? '';
      String customerEmail =
          '$userId@snacktag.app'; // Create a placeholder email using userId

      _log('Creating customer with userId: $userId and phone: $phoneNumber');

      // First try with the standard format
      try {
        final response = await _dio.post(
          '$_baseUrl/create_customer',
          data: {
            'email': customerEmail,
            'metadata': {'userId': userId, 'phoneNumber': phoneNumber}
          },
        );

        _log('Create customer response: ${response.data}');

        if (response.data['status'] == 'success') {
          return response.data['customer'];
        }
      } catch (firstAttemptError) {
        _log(
            'First attempt failed: $firstAttemptError, trying alternative format');
      }

      // If the first attempt fails, try with just the email parameter
      final fallbackResponse = await _dio.post(
        '$_baseUrl/create_customer',
        data: {'email': customerEmail},
      );

      _log('Fallback create customer response: ${fallbackResponse.data}');

      if (fallbackResponse.data['status'] != 'success') {
        throw Exception(
            'Failed to create customer: ${fallbackResponse.data['msg']}');
      }

      return fallbackResponse.data['customer'];
    } catch (e) {
      _log('Error creating customer: $e');
      throw Exception('Failed to create customer: $e');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      int amount, String customerId) async {
    try {
      // Use the correct endpoint from cloud functions
      final response = await _dio.post(
        '$_baseUrl/createPaymentIntent',
        data: {
          'amount': amount,
          'customer_id': customerId,
        },
      );

      _log('Create payment intent response: ${response.data}');

      if (response.data['data'] == null) {
        throw Exception('Invalid payment intent data');
      }

      return response.data['data'];
    } catch (e) {
      _log('Error creating payment intent: $e');
      throw Exception('Failed to create payment intent: $e');
    }
  }

  Future<Map<String, dynamic>> createEphemeralKey(String customerId) async {
    try {
      // Use the correct endpoint from cloud functions
      final response = await _dio.post(
        '$_baseUrl/ephemeralKey',
        data: {
          'customer_id': customerId,
          'api_version': '2024-04-10', // Use the latest Stripe API version
        },
      );

      _log('Create ephemeral key response: ${response.data}');

      if (response.data['data'] == null) {
        throw Exception('Invalid ephemeral key data');
      }

      return response.data['data'];
    } catch (e) {
      _log('Error creating ephemeral key: $e');
      throw Exception('Failed to create ephemeral key: $e');
    }
  }

  // Create a setup intent for adding a payment method
  Future<String?> createSetupIntent(String userId) async {
    try {
      // Create or get customer
      final customerId = await createCustomer(userId);
      _log('Customer ID for setup intent: $customerId');

      // Create setup intent
      final response = await _dio.post(
        '$_baseUrl/createSetupIntent',
        data: {
          'customer_id': customerId,
        },
      );

      _log('Create setup intent response: ${response.data}');

      if (response.data['status'] != 'success' ||
          response.data['data'] == null) {
        throw Exception('Invalid setup intent data');
      }

      // Extract client secret
      final setupIntent = response.data['data'];
      return setupIntent['client_secret'];
    } catch (e) {
      _log('Error creating setup intent: $e');
      throw Exception('Failed to create setup intent: $e');
    }
  }

  // Add a payment method to a customer
  Future<Map<String, dynamic>> addPaymentMethod(
      String paymentMethodId, String userId) async {
    try {
      // Create or get customer
      final customerId = await createCustomer(userId);
      _log('Customer ID for adding payment method: $customerId');

      // Add payment method
      final response = await _dio.post(
        '$_baseUrl/addPaymentMethod',
        data: {
          'payment_method_id': paymentMethodId,
          'customer_id': customerId,
        },
      );

      _log('Add payment method response: ${response.data}');

      if (response.data['status'] != 'success' ||
          response.data['data'] == null) {
        throw Exception('Failed to add payment method');
      }

      return response.data['data'];
    } catch (e) {
      _log('Error adding payment method: $e');
      throw Exception('Failed to add payment method: $e');
    }
  }

  // List payment methods for a customer
  Future<List<Map<String, dynamic>>> listPaymentMethods(String userId,
      {String type = 'card'}) async {
    try {
      // Create or get customer
      final customerId = await createCustomer(userId);
      _log('Customer ID for listing payment methods: $customerId');

      // List payment methods
      final response = await _dio.post(
        '$_baseUrl/listPaymentMethods',
        data: {
          'customer_id': customerId,
          'type': type,
        },
      );

      _log('List payment methods response: ${response.data}');

      if (response.data['status'] != 'success' ||
          response.data['data'] == null) {
        throw Exception('Failed to list payment methods');
      }

      final paymentMethods = response.data['data']['data'] as List;
      return paymentMethods
          .map((method) => method as Map<String, dynamic>)
          .toList();
    } catch (e) {
      _log('Error listing payment methods: $e');
      throw Exception('Failed to list payment methods: $e');
    }
  }

  // Delete a payment method
  Future<Map<String, dynamic>> deletePaymentMethod(
      String paymentMethodId) async {
    try {
      // Delete payment method
      final response = await _dio.post(
        '$_baseUrl/deletePaymentMethod',
        data: {
          'payment_method_id': paymentMethodId,
        },
      );

      _log('Delete payment method response: ${response.data}');

      if (response.data['status'] != 'success' ||
          response.data['data'] == null) {
        throw Exception('Failed to delete payment method');
      }

      return response.data['data'];
    } catch (e) {
      _log('Error deleting payment method: $e');
      throw Exception('Failed to delete payment method: $e');
    }
  }

  // Add a new card using the Stripe SDK
  Future<Map<String, dynamic>> addNewCard(String userId) async {
    try {
      _log('Starting add new card process for userId: $userId');

      // Create setup intent
      final setupIntentClientSecret = await createSetupIntent(userId);
      if (setupIntentClientSecret == null) {
        throw Exception('Failed to create setup intent');
      }

      _log(
          'Setup intent created with client secret: ${setupIntentClientSecret.substring(0, 10)}...');

      // Present card form
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      _log('Payment method created: ${paymentMethod.id}');

      // Attach payment method to customer
      final result = await addPaymentMethod(paymentMethod.id, userId);
      _log('Payment method attached to customer');

      return result;
    } catch (e) {
      _log('ERROR adding new card: $e');
      throw Exception('Failed to add new card: $e');
    }
  }

  Future<bool> processWalletPayment({
    required int amount,
    required String userId,
  }) async {
    try {
      _log('Starting payment process for amount: $amount and userId: $userId');

      // Create or get customer
      final customerId = await createCustomer(userId);
      _log('Customer ID: $customerId');

      // Create payment intent
      final paymentIntentData = await createPaymentIntent(amount, customerId);
      _log('Payment intent created with data: $paymentIntentData');

      // Extract the client secret from the payment intent data
      String? clientSecret;
      if (paymentIntentData['clientSecret'] != null) {
        clientSecret = paymentIntentData['clientSecret'];
      } else if (paymentIntentData['paymentIntent'] != null &&
          paymentIntentData['paymentIntent']['client_secret'] != null) {
        clientSecret = paymentIntentData['paymentIntent']['client_secret'];
      }

      if (clientSecret == null) {
        _log('ERROR: Could not extract client secret from payment intent data');
        return false;
      }

      _log('Client secret extracted: ${clientSecret.substring(0, 10)}...');

      // Create ephemeral key
      final ephemeralKey = await createEphemeralKey(customerId);
      _log('Ephemeral key created with data: $ephemeralKey');

      // Extract the ephemeral key secret
      String? ephemeralKeySecret;
      if (ephemeralKey['secret'] != null) {
        ephemeralKeySecret = ephemeralKey['secret'];
      } else if (ephemeralKey['id'] != null) {
        // Some implementations might return the key differently
        ephemeralKeySecret = ephemeralKey['id'];
      }

      if (ephemeralKeySecret == null) {
        _log('ERROR: Could not extract secret from ephemeral key data');
        return false;
      }

      _log(
          'Ephemeral key secret extracted: ${ephemeralKeySecret.substring(0, 10)}...');

      // Initialize payment sheet with simpler parameters first
      try {
        _log('Initializing payment sheet with client secret and ephemeral key');

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'Snack Tag',
            customerId: customerId,
            customerEphemeralKeySecret: ephemeralKeySecret,
          ),
        );
        _log('Payment sheet initialized successfully');
      } catch (initError) {
        _log('ERROR initializing payment sheet: $initError');

        // Try a simpler initialization as fallback
        try {
          _log('Trying simpler payment sheet initialization');
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: clientSecret,
              merchantDisplayName: 'Snack Tag',
            ),
          );
          _log('Simpler payment sheet initialized successfully');
        } catch (fallbackError) {
          _log(
              'ERROR with simpler payment sheet initialization: $fallbackError');
          return false;
        }
      }

      // Present payment sheet
      try {
        _log('Presenting payment sheet');
        await Stripe.instance.presentPaymentSheet();
        _log('Payment sheet presented successfully');
        return true;
      } catch (presentError) {
        _log('ERROR presenting payment sheet: $presentError');

        // Try to present with confirmation
        try {
          _log('Trying to confirm payment intent directly');
          await Stripe.instance.confirmPayment(
            paymentIntentClientSecret: clientSecret,
          );
          _log('Payment confirmed successfully');
          return true;
        } catch (confirmError) {
          _log('ERROR confirming payment: $confirmError');
          return false;
        }
      }
    } catch (e) {
      _log('ERROR processing payment: $e');
      return false;
    }
  }
}
