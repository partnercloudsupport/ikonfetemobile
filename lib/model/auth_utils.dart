import 'package:firebase_auth/firebase_auth.dart';
import 'package:ikonfete/model/artist.dart';
import 'package:ikonfete/model/auth_type.dart';
import 'package:ikonfete/model/fan.dart';
import 'package:meta/meta.dart';

class AuthActionRequest {
  AuthUserType userType;
  AuthProvider provider;

  AuthActionRequest({
    @required this.userType,
    @required this.provider,
  });

  bool get isArtist => userType == AuthUserType.artist;

  bool get isFan => userType == AuthUserType.fan;

  bool get isEmailProvider => provider == AuthProvider.email;

  bool get isFacebookProvider => provider == AuthProvider.facebook;
}

class AuthResult {
  Artist _artist;
  Fan _fan;
  String _errorMessage;
  AuthActionRequest request;

  AuthResult({@required this.request});

  factory AuthResult.error(AuthActionRequest request, String message) {
    final res = AuthResult(request: request);
    res.errorMessage = message;
    return res;
  }

  set errorMessage(String val) {
    _errorMessage = val;
    _artist = null;
    _fan = null;
  }

  set fan(Fan val) {
    assert(val != null);
    _fan = val;
    _artist = null;
  }

  set artist(Artist val) {
    assert(val != null);
    _artist = val;
    _fan = null;
  }

  bool get success => !(_artist == null && _fan == null);

  String get errorMessage => _errorMessage;

  Artist get artist => _artist;

  Fan get fan => _fan;

  bool get isArtist => _artist != null;

  bool get isFan => _fan != null;
}

class LoginResult extends AuthResult {
  FirebaseUser firebaseUser;

  LoginResult(AuthActionRequest request) : super(request: request);
} 