// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';

import '../data/local_db.dart';
import '../models/user_profile.dart';
import '../models/recipe.dart';

class UserProvider extends ChangeNotifier {
  final LocalDB _db = LocalDB();
  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get hasCompletedOnboarding => _userProfile != null;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    _userProfile = await _db.getUserProfile();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveUser(UserProfile profile) async {
    await _db.saveUserProfile(profile);
    _userProfile = profile;
    notifyListeners();
  }

  Future<void> updateUser(UserProfile profile) async {
    await _db.updateUserProfile(profile);
    _userProfile = profile;
    notifyListeners();
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    return await _db.getFavoriteRecipes();
  }
}
