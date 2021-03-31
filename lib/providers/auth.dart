import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  String _userId;
  DateTime _expiryDate;
  Timer timerToLogout;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expiryDate != null &&
        _token != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }
    return null;
  }

  Future<void> authenticate(
      String email, String password, String typeSegment) async {
    const params = {'key': 'AIzaSyCF4hYFYKLTljXSui3XL7FUMShUmVjYrHc'};
    final url = Uri.https(
        'identitytoolkit.googleapis.com', '/v1/accounts:$typeSegment', params);

    print('auth occurd');
    try {
      final response = await http.post(url,
          body: jsonEncode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      var extractedData = jsonDecode(response.body);

      if (extractedData['error'] != null) {
        throw HttpException(extractedData['error']['message']);
      }
      _token = extractedData['idToken'];
      _userId = extractedData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(extractedData['expiresIn']),
        ),
      );
      autoLogout();
      notifyListeners(); //  do not forget it
    } catch (e) {
      throw e;
    }
  }

  Future<void> signUp(String email, String password) async {
    print('singup occurd');
    await authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return authenticate(email, password, 'signInWithPassword');
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    timerToLogout.cancel();
    notifyListeners();
  }

  void autoLogout() {
    if (timerToLogout != null) {
      timerToLogout.cancel();
      return;
    }
    timerToLogout = Timer(
        Duration(seconds: _expiryDate.difference(DateTime.now()).inSeconds),
        logout);
  }
}
