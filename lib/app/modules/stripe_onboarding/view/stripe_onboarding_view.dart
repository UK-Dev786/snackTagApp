import 'dart:developer' as developer;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snacktag/app/routes/app_pages.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class StripeOnboardingView extends StatefulWidget {
  final String url;
  final String? stripeAccountId; // Add parameter for Stripe account ID

  const StripeOnboardingView({
    super.key,
    required this.url,
    this.stripeAccountId, // Make it optional but pass it when available
  });

  @override
  State<StripeOnboardingView> createState() => _StripeOnboardingViewState();
}

class _StripeOnboardingViewState extends State<StripeOnboardingView> {
  late final WebViewController controller;
  bool isLoading = true;
  String currentUrl = '';

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Update Stripe onboarding status in Firestore
  Future<void> _updateStripeOnboardingStatus() async {
    try {
      final String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        // First check if the user document already has a stripeAccountId
        final userDoc = await _firestore.collection('users').doc(userId).get();

        // If the document exists and has data
        if (userDoc.exists && userDoc.data() != null) {
          final userData = userDoc.data()!;

          // Create update data map
          final Map<String, dynamic> updateData = {
            'stripeOnboardingComplete': true,
            'stripeOnboardingDate': FieldValue.serverTimestamp(),
          };

          // First priority: Use the stripeAccountId passed to the widget if available
          if (widget.stripeAccountId != null &&
              widget.stripeAccountId!.isNotEmpty) {
            updateData['stripeAccountId'] = widget.stripeAccountId;
            developer.log(
                'Using Stripe account ID from parameter: ${widget.stripeAccountId}',
                name: 'StripeWebView');
          }
          // Second priority: If we don't have a stripeAccountId but have an account_id in the URL, use that
          else if (userData['stripeAccountId'] == null &&
              currentUrl.contains('account_id=')) {
            final accountIdRegex = RegExp(r'account_id=([^&]+)');
            final match = accountIdRegex.firstMatch(currentUrl);
            if (match != null && match.groupCount >= 1) {
              final accountId = match.group(1);
              if (accountId != null && accountId.isNotEmpty) {
                updateData['stripeAccountId'] = accountId;
                developer.log(
                    'Extracted Stripe account ID from URL: $accountId',
                    name: 'StripeWebView');
              }
            }
          }

          // Log warning if we still don't have a Stripe account ID
          if (!updateData.containsKey('stripeAccountId') &&
              userData['stripeAccountId'] == null) {
            developer.log(
                'WARNING: No Stripe account ID available for user. Future payouts may fail.',
                name: 'StripeWebView');
          }

          // Update the document
          await _firestore.collection('users').doc(userId).update(updateData);
          developer.log(
              'Stripe onboarding status updated successfully with data: $updateData',
              name: 'StripeWebView');
        } else {
          // If document doesn't exist, create it
          final Map<String, dynamic> newUserData = {
            'stripeOnboardingComplete': true,
            'stripeOnboardingDate': FieldValue.serverTimestamp(),
            'userId': userId, // Include user ID for reference
          };

          // Add Stripe account ID if available
          if (widget.stripeAccountId != null &&
              widget.stripeAccountId!.isNotEmpty) {
            newUserData['stripeAccountId'] = widget.stripeAccountId;
            developer.log(
                'Adding Stripe account ID to new user document: ${widget.stripeAccountId}',
                name: 'StripeWebView');
          } else {
            // Try to extract from URL if available
            if (currentUrl.contains('account_id=')) {
              final accountIdRegex = RegExp(r'account_id=([^&]+)');
              final match = accountIdRegex.firstMatch(currentUrl);
              if (match != null && match.groupCount >= 1) {
                final accountId = match.group(1);
                if (accountId != null && accountId.isNotEmpty) {
                  newUserData['stripeAccountId'] = accountId;
                  developer.log(
                      'Extracted Stripe account ID from URL for new user: $accountId',
                      name: 'StripeWebView');
                }
              }
            }
          }

          await _firestore
              .collection('users')
              .doc(userId)
              .set(newUserData, SetOptions(merge: true));

          developer.log(
              'Created new user document with Stripe data: $newUserData',
              name: 'StripeWebView');
        }
      } else {
        developer.log('Cannot update Stripe status: User not logged in',
            name: 'StripeWebView');
      }
    } catch (e) {
      developer.log('Error updating Stripe onboarding status: $e',
          name: 'StripeWebView');
      // Rethrow to handle in the calling method
      rethrow;
    }
  }

  // Navigate to meal details page safely
  void _navigateToMealDetails() {
    try {
      developer.log('Starting navigation to meal details',
          name: 'StripeWebView');

      // First check if we need to close any dialogs
      if (Get.isDialogOpen == true) {
        Get.back();
        developer.log('Closed dialog', name: 'StripeWebView');
      }

      // Show success message
      Get.snackbar(
        'Success',
        'Your Stripe account has been set up successfully!',
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Color(0xFFCCFD00),
        colorText: Colors.green[800],
      );
      developer.log('Showed success snackbar', name: 'StripeWebView');

      // IMMEDIATELY close the WebView and navigate
      if (Get.currentRoute.contains('stripe')) {
        // Pop the WebView
        Get.back();
        developer.log('Closed WebView', name: 'StripeWebView');
      }

      // Navigate immediately to the meal details page
      Navigator.pop(context);
      developer.log('Navigated to meal details page', name: 'StripeWebView');
    } catch (e) {
      developer.log('Error navigating to meal details: $e',
          name: 'StripeWebView');

      // Try a fallback navigation approach
      try {
        // Close any open dialogs
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        // Try to close the WebView
        try {
          if (Get.currentRoute.contains('stripe')) {
            Get.back();
          }
        } catch (_) {}

        // Try direct navigation as a last resort
        Navigator.pop(context);
      } catch (e2) {
        developer.log('Fallback navigation also failed: $e2',
            name: 'StripeWebView');

        // Last resort - try to navigate with a new route
        try {
          // Navigator.pop(context);
          Navigator.pop(context);
        } catch (_) {}
      }
    }
  }

  // Check if URL indicates success
  bool _isSuccessUrl(String url) {
    // Direct check for the specific success URL
    if (url.contains('snacktag.com/success')) {
      return true;
    }

    // Check for other success indicators
    final successIndicators = [
      'success=true',
      'account_onboarding_complete',
      'success',
      'completed=true',
      'onboarding_complete',
      'status=complete',
    ];

    return successIndicators
        .any((indicator) => url.toLowerCase().contains(indicator));
  }

  // Check if URL indicates cancellation or error
  bool _isErrorOrCancelUrl(String url) {
    final errorIndicators = [
      'cancel=true',
      'error',
      'failed',
      'cancelled',
      'canceled',
      'status=incomplete',
    ];

    return errorIndicators
        .any((indicator) => url.toLowerCase().contains(indicator));
  }

  @override
  void initState() {
    super.initState();

    // Initialize platform-specific features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller = WebViewController.fromPlatformCreationParams(params);

    // Apply platform-specific settings
    if (controller.platform is AndroidWebViewController) {
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    // Configure the controller with all necessary settings
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            developer.log('Navigation request to: ${request.url}',
                name: 'StripeWebView');
            currentUrl = request.url;

            // Check if this is the success URL (snacktag.com/success)
            if (request.url.contains('snacktag.com/success')) {
              developer.log(
                  'Success URL detected in navigation request: ${request.url}',
                  name: 'StripeWebView');

              // Extract account_id from URL if present
              String? extractedAccountId;
              if (request.url.contains('account_id=')) {
                final accountIdRegex = RegExp(r'account_id=([^&]+)');
                final match = accountIdRegex.firstMatch(request.url);
                if (match != null && match.groupCount >= 1) {
                  extractedAccountId = match.group(1);
                  developer.log(
                      'Extracted account_id from success URL: $extractedAccountId',
                      name: 'StripeWebView');
                }
              }

              // Handle success immediately
              Future.microtask(() async {
                try {
                  // If we extracted an account ID and don't have one from the widget, use it
                  if (extractedAccountId != null &&
                      extractedAccountId.isNotEmpty &&
                      (widget.stripeAccountId == null ||
                          widget.stripeAccountId!.isEmpty)) {
                    // Update user document with the extracted account ID
                    final userId = _auth.currentUser?.uid;
                    if (userId != null) {
                      await _firestore.collection('users').doc(userId).update({
                        'stripeAccountId': extractedAccountId,
                      });
                      developer.log(
                          'Updated user document with extracted account ID: $extractedAccountId',
                          name: 'StripeWebView');
                    }
                  }

                  // Update Firestore with all onboarding data
                  await _updateStripeOnboardingStatus();

                  // Verify that we have a stripeAccountId before navigating
                  final userId = _auth.currentUser?.uid;
                  if (userId != null) {
                    final userDoc =
                        await _firestore.collection('users').doc(userId).get();
                    if (userDoc.exists &&
                        userDoc.data() != null &&
                        userDoc.data()!['stripeAccountId'] != null) {
                      // We have the account ID, safe to navigate
                      _navigateToMealDetails();
                    } else {
                      // No account ID, show error and don't navigate
                      Get.back(); // Close WebView
                      Get.snackbar(
                        'Setup Incomplete',
                        'Your Stripe account setup is incomplete. Please try again.',
                        duration: const Duration(seconds: 5),
                        backgroundColor: Colors.red[100],
                        colorText: Colors.red[800],
                      );
                      developer.log(
                          'Cannot navigate: No Stripe account ID found after onboarding',
                          name: 'StripeWebView');
                    }
                  } else {
                    // No user ID, can't verify
                    _navigateToMealDetails();
                  }
                } catch (e) {
                  developer.log('Error handling success URL: $e',
                      name: 'StripeWebView');
                  Get.back(); // Close WebView on error
                  Get.snackbar(
                    'Error',
                    'There was a problem completing your setup: ${e.toString()}',
                    duration: const Duration(seconds: 5),
                    backgroundColor: Colors.red[100],
                    colorText: Colors.red[800],
                  );
                }
              });

              // Still allow the navigation to proceed
              return NavigationDecision.navigate;
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            developer.log('Page started loading: $url', name: 'StripeWebView');
            setState(() {
              isLoading = true;
              currentUrl = url;
            });
          },
          onPageFinished: (String url) async {
            developer.log('Page finished loading: $url', name: 'StripeWebView');
            setState(() {
              isLoading = false;
              currentUrl = url;
            });

            // Check if the URL indicates success or error
            if (_isSuccessUrl(url)) {
              developer.log('Stripe onboarding success detected in URL: $url',
                  name: 'StripeWebView');

              // Show loading indicator while we update the database
              Get.dialog(
                const Center(
                  child: CircularProgressIndicator(),
                ),
                barrierDismissible: false,
              );

              try {
                // Update Firestore to mark onboarding as complete
                await _updateStripeOnboardingStatus();

                // Use our navigation helper to safely navigate to meal details
                _navigateToMealDetails();
              } catch (e) {
                developer.log('Error during success handling: $e',
                    name: 'StripeWebView');
                if (Get.isDialogOpen == true) {
                  Get.back();
                }
                Get.snackbar(
                  'Error',
                  'There was an issue completing your setup: ${e.toString()}',
                  duration: const Duration(seconds: 3),
                  snackPosition: SnackPosition.TOP,
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[800],
                );
              }
            } else if (_isErrorOrCancelUrl(url)) {
              developer.log(
                  'Stripe onboarding cancellation detected in URL: $url',
                  name: 'StripeWebView');
              // Close the WebView
              Get.back();
              Get.snackbar(
                'Cancelled',
                'Stripe account setup was cancelled.',
                duration: const Duration(seconds: 3),
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.orange[100],
                colorText: Colors.orange[800],
              );
            }
          },
          onWebResourceError: (WebResourceError error) {
            developer.log('Web resource error: ${error.description}',
                error: error.description, name: 'StripeWebView');

            // Only show snackbar for main frame errors
            if (error.isForMainFrame == true) {
              // Get.snackbar(
              //   'Error',
              //   'Failed to load page: ${error.description}',
              //   duration: const Duration(seconds: 3),
              // );
            }
          },
          onUrlChange: (UrlChange change) {
            final url = change.url ?? '';
            developer.log('URL changed to: $url', name: 'StripeWebView');
            currentUrl = url;

            // Check if this is the success URL (snacktag.com/success)
            if (url.contains('snacktag.com/success')) {
              developer.log('Success URL detected in URL change: $url',
                  name: 'StripeWebView');

              // Extract account_id from URL if present
              String? extractedAccountId;
              if (url.contains('account_id=')) {
                final accountIdRegex = RegExp(r'account_id=([^&]+)');
                final match = accountIdRegex.firstMatch(url);
                if (match != null && match.groupCount >= 1) {
                  extractedAccountId = match.group(1);
                  developer.log(
                      'Extracted account_id from URL change: $extractedAccountId',
                      name: 'StripeWebView');
                }
              }

              // Handle success immediately
              Future.microtask(() async {
                try {
                  // If we extracted an account ID and don't have one from the widget, use it
                  if (extractedAccountId != null &&
                      extractedAccountId.isNotEmpty &&
                      (widget.stripeAccountId == null ||
                          widget.stripeAccountId!.isEmpty)) {
                    // Update user document with the extracted account ID
                    final userId = _auth.currentUser?.uid;
                    if (userId != null) {
                      await _firestore.collection('users').doc(userId).update({
                        'stripeAccountId': extractedAccountId,
                      });
                      developer.log(
                          'Updated user document with extracted account ID from URL change: $extractedAccountId',
                          name: 'StripeWebView');
                    }
                  }

                  // Update Firestore with all onboarding data
                  await _updateStripeOnboardingStatus();

                  // Verify that we have a stripeAccountId before navigating
                  final userId = _auth.currentUser?.uid;
                  if (userId != null) {
                    final userDoc =
                        await _firestore.collection('users').doc(userId).get();
                    if (userDoc.exists &&
                        userDoc.data() != null &&
                        userDoc.data()!['stripeAccountId'] != null) {
                      // We have the account ID, safe to navigate
                      _navigateToMealDetails();
                    } else {
                      // No account ID, show error and don't navigate
                      Get.back(); // Close WebView
                      Get.snackbar(
                        'Setup Incomplete',
                        'Your Stripe account setup is incomplete. Please try again.',
                        duration: const Duration(seconds: 5),
                        backgroundColor: Colors.red[100],
                        colorText: Colors.red[800],
                      );
                      developer.log(
                          'Cannot navigate: No Stripe account ID found after onboarding (URL change)',
                          name: 'StripeWebView');
                    }
                  } else {
                    // No user ID, can't verify
                    _navigateToMealDetails();
                  }
                } catch (e) {
                  developer.log('Error handling success URL change: $e',
                      name: 'StripeWebView');
                }
              });
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          developer.log('JavaScript message: ${message.message}',
              name: 'StripeWebView');

          // Check if this is a success detection message from our JavaScript
          if (message.message.startsWith('SUCCESS_DETECTED:')) {
            developer.log('Success detected by JavaScript: ${message.message}',
                name: 'StripeWebView');

            // Handle the success case
            try {
              // Update Firestore and navigate
              _updateStripeOnboardingStatus().then((_) {
                _navigateToMealDetails();
              }).catchError((e) {
                developer.log('Error handling JavaScript success: $e',
                    name: 'StripeWebView');
              });
            } catch (e) {
              developer.log('Error processing JavaScript success: $e',
                  name: 'StripeWebView');
            }
          }
        },
      )
      ..setUserAgent(
          'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1')
      ..enableZoom(true);

    // Enable local storage and cookies
    final WebViewCookieManager cookieManager = WebViewCookieManager();
    cookieManager.clearCookies();

    // Enable debugging
    if (Platform.isAndroid) {
      AndroidWebViewController.enableDebugging(true);
    }

    // Load the URL with headers to help with CORS
    controller.loadRequest(
      Uri.parse(widget.url),
      headers: {
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
        'User-Agent':
            'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1',
      },
    );

    // Inject JavaScript to help debug issues and detect success
    Future.delayed(const Duration(seconds: 2), () {
      controller.runJavaScript('''
        // Redirect console logs to Flutter
        console.log = function(message) {
          Flutter.postMessage('CONSOLE: ' + message);
        };
        console.error = function(message) {
          Flutter.postMessage('CONSOLE ERROR: ' + message);
        };

        // Listen for errors
        window.addEventListener('error', function(event) {
          Flutter.postMessage('JS ERROR: ' + event.message);
        });

        // Check for success indicators in the page content
        function checkForSuccess() {
          var pageContent = document.body.innerText || '';
          var successIndicators = [
            'successfully completed',
            'account is ready',
            'account is now active',
            'setup complete',
            'onboarding complete',
            'verification successful'
          ];

          for (var i = 0; i < successIndicators.length; i++) {
            if (pageContent.toLowerCase().includes(successIndicators[i])) {
              Flutter.postMessage('SUCCESS_DETECTED: ' + successIndicators[i]);
              return true;
            }
          }
          return false;
        }

        // Run the check periodically
        setInterval(checkForSuccess, 1000);

        // Also check when DOM changes
        var observer = new MutationObserver(function(mutations) {
          checkForSuccess();
        });

        // Start observing the document body for DOM changes
        observer.observe(document.body, {
          childList: true,
          subtree: true,
          characterData: true
        });
      ''');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Account Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
            Get.snackbar(
              'Cancelled',
              'Stripe account setup was cancelled.',
              duration: const Duration(seconds: 3),
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.orange[100],
              colorText: Colors.orange[800],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Get.snackbar(
                'Current URL',
                currentUrl,
                duration: const Duration(seconds: 5),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
