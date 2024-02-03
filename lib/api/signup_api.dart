
import  'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../user/users.dart';


Future<Users?>validate(
    BuildContext context,
    String name,
    String email,
    String mobile,
    String password,
    ) async {
  try {
    var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/validate.php');
    var response = await http.post(uri, body: {
      "email": email,
    });
    if (response.statusCode == 200) {
      var userJson = json.decode(response.body);
      if(userJson['emailFound'] == true){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.deepOrange,
            content: Text('Email already exist'),
          ),
        );
        /* Fluttertoast.showToast(
            msg: 'Email already exist',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.deepOrange,
            textColor: Colors.white,
            fontSize: 16.0
        );*/
      }else{
        var sessionToken = generateUniqueToken();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('sessionToken', sessionToken);
        var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/signup.php');
        var response = await http.post(uri, body: {
          "name": name,
          "email": email,
          "mobile": mobile,
          "password": password,
          "session_token": sessionToken,
        });

        if (response.statusCode == 201) {
          var userJson = json.decode(response.body);
          print('error code');
          try {
            var user = Users.fromJson(userJson);
            print(user);
            showRegistrationSuccessMessage(context);
            return user;
          } catch (e) {
            print(response.body);
            print(response.statusCode);
            throw Exception('Failed to add user');
          }
        }else{
          showRegistrationSuccessMessage(context);
        }
      }
    } else{
      var sessionToken = generateUniqueToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('sessionToken', sessionToken);
      var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/signup.php');
      var response = await http.post(uri, body: {
        "name": name,
        "email": email,
        "mobile": mobile,
        "password": password,
        "session_token": sessionToken,
      });

      if (response.statusCode == 201) {
        var userJson = json.decode(response.body);
        print('error code');
        try {
          var user = Users.fromJson(userJson);
          print(user);
          showRegistrationSuccessMessage(context);
          return user;
        } catch (e) {
          print(response.body);
          print(response.statusCode);
          throw Exception('Failed to add user');
        }
      }else{
        showRegistrationSuccessMessage(context);
      }
    }

  }catch(e){
    print(e);
    print(e.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.deepOrange,
        content: Text('An error occurred. Please try again later.'),
      ),
    );
    // Fluttertoast.showToast(
    //   msg: 'An error occurred. Please try again later.',
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.BOTTOM,
    //   backgroundColor: Colors.red,
    //   textColor: Colors.white,
    // );
  }
}
void showRegistrationSuccessMessage(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.deepOrange,
      content: Text('Registration Successful'),
    ),
  );
  // Fluttertoast.showToast(
  //   msg: 'Registration Successful',
  //   toastLength: Toast.LENGTH_SHORT,
  //   gravity: ToastGravity.BOTTOM,
  //   backgroundColor: Colors.green,
  //   textColor: Colors.white,
  // );
// Navigator.push(context, MaterialPageRoute(builder: (context) => EmailPage()));
}

String generateUniqueToken() {
  var uuid = Uuid();
  return uuid.v4();
}

Future<Users?> addusers1(
    String name,
    String email,
    String mobile,
    String password,
    ) async {
  var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/signup.php');
  var response = await http.post(uri, body: {
    "name": name,
    "email": email,
    "mobile": mobile,
    "password": password,
  });

  if (response.statusCode == 201) {
    var userJson = json.decode(response.body);
    try {
      var user = Users.fromJson(userJson);
      print(user);
      return user;
    } catch (e) {
      print('Failed to parse user data: $e');
      throw Exception('Failed to parse user data');
    }
  } else if (response.statusCode == 400) {
    print('Bad Request: ${response.body}');
    throw Exception('Bad Request: Failed to add user');
  } else if (response.statusCode == 500) {
    print('Internal Server Error: ${response.body}');
    throw Exception('Internal Server Error: Failed to add user');
  } else {
    print('Unknown Error: ${response.body}');

    throw Exception('Unknown Error: Failed to add user');
  }
}