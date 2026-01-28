import 'package:flutter/foundation.dart';

/// Service for biometric authentication
/// Web platform is not supported for biometric auth
class BiometricService {
  /// Check if biometric authentication is available
  Future<bool> isAvailable() async {
    // Web doesn't support biometric authentication
    if (kIsWeb) {
      return false;
    }
    
    try {
      // Dynamically import local_auth only for non-web platforms
      // For now, return false to allow web builds
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<String>> getAvailableBiometrics() async {
    if (kIsWeb) {
      return [];
    }
    
    try {
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Authenticate user
  Future<bool> authenticate({String reason = 'Authenticate to access app'}) async {
    if (kIsWeb) {
      return true; // Skip on web
    }
    
    try {
      // Return true for now - in production, use local_auth
      return true;
    } catch (e) {
      return false;
    }
  }
}
