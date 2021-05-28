import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

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
      setAutoLogout(); //start calculating the time left for token expiration
      notifyListeners();

      //storing the data on the device
      var perfs = await SharedPreferences.getInstance();
      var userData = jsonEncode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      perfs.setString('userData', userData);
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

  Future<bool> tryAutoLogin() async {
    var perfs = await SharedPreferences.getInstance();
    if (!perfs.containsKey('userData')) {
      return false;
    }
    var extractedData =
        jsonDecode(perfs.getString('userData')) as Map<String, Object>;
    var expiryDate = DateTime.parse(extractedData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedData['token'];
    _userId = extractedData['userId'];
    print('userID is : ' + _userId);
    _expiryDate = expiryDate;
    notifyListeners();
    setAutoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (timerToLogout != null) {
      timerToLogout.cancel();
      timerToLogout = null;
    }
    notifyListeners();
    //without clearing the shared preferences data on the device the logout method won't work.
    var perfs = await SharedPreferences.getInstance();
    //perfs.remove('userData');//works fine if you just want to delete userData
    perfs.clear();
  }

  void setAutoLogout() {
    if (timerToLogout != null) {
      timerToLogout.cancel();
      return;
    }
    timerToLogout = Timer(
        Duration(seconds: _expiryDate.difference(DateTime.now()).inSeconds),
        logout);
  }
}
