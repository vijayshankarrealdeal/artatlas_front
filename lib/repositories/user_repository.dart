// lib/repositories/user_repository.dart
import 'package:hack_front/services/api_service.dart';

class UserRepository {
  final ApiService _apiService;

  UserRepository(this._apiService);

  Future<void> activateSubscription() async {
    try {
      // The API docs require a 'subscription_provider_id', which is a string.
      // For this example, I'll use a placeholder. In a real app, this would
      // come from a payment provider like Stripe or RevenueCat.
      const String placeholderProviderId = "placeholder_sub_id_12345";
      
      await _apiService.updateUserSubscription(
        status: "active",
        providerId: placeholderProviderId,
      );
    } on ApiException {
      rethrow; // Re-throw to be handled by the UI layer
    } catch (e) {
      throw Exception('An unexpected error occurred during subscription activation.');
    }
  }
}