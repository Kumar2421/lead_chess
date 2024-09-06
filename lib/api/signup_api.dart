import  'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../screen/home_screen.dart';
import '../user/user_preference.dart';
import '../user/users.dart';


Future<Users?> validate(
    BuildContext context,
    String? name,
    String? email,
    String? mobile,
    // String? password,
    String? imagePath,
    String? flag,
    //  String? betting_amount,
    ) async {
  try {
    // var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/validate.php');
    var uri = Uri.parse('https://schmidivan.com/Esakki/ChessGame/email_validate');
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
          // "password": password,
          "session_token": sessionToken,
          "image_path": imagePath,
          "country_flag":flag,
          //  "betting_amount":betting_amount,
        });
        if (signupResponse.statusCode == 201) {
          var userJson = json.decode(signupResponse.body);
          var user = Users.fromJson(userJson);

          final url = Uri.parse("https://schmidivan.com/Esakki/ChessGame/email_login");
          try {
            final response = await http.post(
              url,
              body: {
                "email": email,
                // You can add a flag to indicate login action
              },
            );
            if (response.statusCode == 200) {
              // If the server returns a 200 OK response, parse the JSON
              final Map<String, dynamic> responseData = json.decode(response.body);

              if (responseData['success'] == true) {
                // User data retrieval was successful
                final userData = responseData['userData'];
                Users userInfo = Users.fromJson(responseData["userData"]);
                await RememberUserPrefs.storeUserInfo(userInfo);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
              }
            } else {
              // If the server did not return a 200 OK response,
              // throw an exception or handle the error as needed.
              throw Exception('Failed to load user data');
            }
          } catch (e) {
            // Handle any exceptions or errors that occur during the HTTP request.
            print('Error: Email Error : $e');
          }
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
        // "password": password,
        "session_token": sessionToken,
        "image_path": imagePath,
        "country_flag":flag,
        // "betting_amount":betting_amount,
      });
      if (signupResponse.statusCode == 201) {
        var userJson = json.decode(signupResponse.body);
        var user = Users.fromJson(userJson);
        final url = Uri.parse("https://schmidivan.com/Esakki/ChessGame/email_login");
        try {
          final response = await http.post(
            url,
            body: {
              "email": email,
              // You can add a flag to indicate login action
            },
          );
          if (response.statusCode == 200) {
            // If the server returns a 200 OK response, parse the JSON
            final Map<String, dynamic> responseData = json.decode(response.body);

            if (responseData['success'] == true) {
              // User data retrieval was successful
              final userData = responseData['userData'];
              final sessionToken = responseData['sessionToken'];
              await saveUserDataLocally(userData);
              // Store the session token locally
              await saveSessionTokenLocally(sessionToken);
              Users userInfo = Users.fromJson(responseData["userData"]);
              await RememberUserPrefs.storeUserInfo(userInfo);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
            }
          } else {
            // If the server did not return a 200 OK response,
            // throw an exception or handle the error as needed.
            throw Exception('Failed to load user data');
          }
        } catch (e) {
          // Handle any exceptions or errors that occur during the HTTP request.
          print('Error: Email Error : $e');
        }
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
    // showRegistrationMessage(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.deepOrange,
        content: Text('An error occurred. Please try again later.'),
      ),
    );
    return null;
  }
}
Future<void> saveUserDataLocally(Map<String, dynamic> userData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userData', jsonEncode(userData));
}

Future<void> saveSessionTokenLocally(String sessionToken) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('sessionToken', sessionToken);
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