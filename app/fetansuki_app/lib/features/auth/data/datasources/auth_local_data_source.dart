import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fetansuki_app/core/utils/constants.dart';
import 'package:fetansuki_app/features/auth/data/models/user_model.dart';
import 'package:fetansuki_app/core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getLastUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUser(UserModel user) {
    return sharedPreferences.setString(
      AppConstants.userKey,
      json.encode(user.toJson()),
    );
  }

  @override
  Future<UserModel> getLastUser() {
    final jsonString = sharedPreferences.getString(AppConstants.userKey);
    if (jsonString != null) {
      return Future.value(UserModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException('No cached user found');
    }
  }

  @override
  Future<void> clearUser() {
    return sharedPreferences.remove(AppConstants.userKey);
  }
}
