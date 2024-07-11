
import  'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../user/users.dart';


Future<Users?> validate(
    BuildContext context,
    String? name,
    String? email,
    String? mobile,
    String? password,
    String? imagePath,
    ) async {
  try {
   // var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/validate.php');
    var uri = Uri.parse('https://schmidivan.com/Esakki/ChessGame/validate');
    var response = await http.post(uri, body: {
      "email": email,
    });

    if (response.statusCode == 200) {
      var userJson = json.decode(response.body);
      if (userJson['emailFound'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.deepOrange,
            content: Text('Email already exists'),
          ),
        );
        return null;
      } else {
        // Proceed with user registration
        var sessionToken = generateUniqueToken();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('sessionToken', sessionToken);
       // var signupUri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/signup.php');
        var signupUri = Uri.parse('https://schmidivan.com/Esakki/ChessGame/signup');
        var signupResponse = await http.post(signupUri, body: {
          "name": name,
          "email": email,
          "mobile": mobile,
          "password": password,
          "session_token": sessionToken,
          "image_path": imagePath
        });
        if (signupResponse.statusCode == 201) {
          var userJson = json.decode(signupResponse.body);
          var user = Users.fromJson(userJson);
          showRegistrationSuccessMessage(context);
          return user;
        } else {
          var errorJson = json.decode(signupResponse.body);
          var errorMessage = errorJson['error'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(errorMessage),
            ),
          );
          return null;
        }
      }
    } else if (response.statusCode == 404) {
      // Email not found in validation, proceed with registration
      var sessionToken = generateUniqueToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('sessionToken', sessionToken);
      //var signupUri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/signup.php');
      var signupUri = Uri.parse('https://schmidivan.com/Esakki/ChessGame/signup');
      var signupResponse = await http.post(signupUri, body: {
        "name": name,
        "email": email,
        "mobile": mobile,
        "password": password,
        "session_token": sessionToken,
        "image_path": imagePath
      });
      if (signupResponse.statusCode == 201) {
        var userJson = json.decode(signupResponse.body);
        var user = Users.fromJson(userJson);
        showRegistrationSuccessMessage(context);
        return user;
      } else {
        var errorJson = json.decode(signupResponse.body);
        var errorMessage = errorJson['error'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(errorMessage),
          ),
        );
        return null;
      }
    } else {
      throw Exception('Failed to validate email: ${response.statusCode}');
    }
  } catch (e) {
    // print('Error: $e');
    print('Error during registration: $e');
    showRegistrationMessage(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.deepOrange,
        content: Text('An error occurred. Please try again later.'),
      ),
    );
    return null;
  }
}

void showRegistrationSuccessMessage(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      backgroundColor: Colors.deepOrange,
      content: Text('Registration Successful'),
    ),
  );
}

String generateUniqueToken() {
  var uuid = const Uuid();
  return uuid.v4();
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showRegistrationMessage(BuildContext context){
  return ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      backgroundColor: Colors.deepOrange,
      content: Text('Registration Successful'),
    ),
  );
}

Future<Users?> addusers1(
    String name,
    String email,
    String mobile,
    String password,
    ) async {
 // var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/signup.php');
  var uri = Uri.parse('https://schmidivan.com/Esakki/ChessGame/signup');
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


//
// Future<Users?>validate(
//     BuildContext context,
//     String name,
//     String email,
//     String mobile,
//     String password,
//     ) async {
//   try {
//     var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/validate.php');
//     var response = await http.post(uri, body: {
//      // "name": name,
//       "email": email,
//       //"mobile": mobile,
//       //"password": password,
//     });
//
//     if (response.statusCode == 200) {
//       var userJson = json.decode(response.body);
//       if(userJson['emailFound'] == true){
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             backgroundColor: Colors.deepOrange,
//             content: Text('Email already exist'),
//           ),
//         );
//         return null;
//       }
//       else{
//         var sessionToken = generateUniqueToken();
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         prefs.setString('sessionToken', sessionToken);
//         var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/signup.php');
//         var response = await http.post(uri, body: {
//           "name": name,
//           "email": email,
//           "mobile": mobile,
//           "password": password,
//           "session_token": sessionToken,
//         });
//         print('esakki');
//         if (response.statusCode == 201) {
//           var userJson = json.decode(response.body);
//            print('error code');
//           try {
//             var user = Users.fromJson(userJson);
//             print(user);
//             showRegistrationSuccessMessage(context);
//             return user;
//           } catch (e) {
//             print(response.body);
//             print(response.statusCode);
//             throw Exception('Failed to add user');
//           }
//         }else{
//           throw Exception('Failed to add user');
//         }
//       }
//     }
//     else if (response.statusCode == 404) {
//       // Email not found in validation, proceed with registration
//       var sessionToken = generateUniqueToken();
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setString('sessionToken', sessionToken);
//       var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/signup.php');
//       var response = await http.post(uri, body: {
//         "name": name,
//         "email": email,
//         "mobile": mobile,
//         "password": password,
//         "session_token": sessionToken,
//       });
//       if (response.statusCode == 201) {
//         var userJson = json.decode(response.body);
//         try {
//           var user = Users.fromJson(userJson);
//           showRegistrationSuccessMessage(context);
//           return user;
//         } catch (e) {
//           print(response.body);
//           print(response.statusCode);
//           throw Exception('Failed to add user');
//         }
//       } else {
//         print('esakki');
//         throw Exception('Failed to add user');
//       }
//     }
//     else {
//       throw Exception('Failed to validate email');
//     }
//   } catch(e){
//     print(e);
//     print(e.toString());
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         backgroundColor: Colors.deepOrange,
//         content: Text('An error occurred. Please try again later.'),
//       ),
//     );
//     return null;
//   }
// }