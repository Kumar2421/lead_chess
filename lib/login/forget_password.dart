import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:chess_game/colors.dart';
import 'package:http/http.dart' as http;

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  Map userData = {};
  var emailController = TextEditingController();
  var newPasswordController = TextEditingController();
  var confirmPasswordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  Future<void> resetPassword(String email, String newPassword) async {
    final url = Uri.parse("https://leadproduct.000webhostapp.com/chessApi/forgetpassword.php");
    try {
      final response = await http.post(
        url,
        body: {
          "email": email,
          "new_password": newPassword,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Password reset successful
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(responseData['message']),
            ),
          );
        } else {
          // Password reset failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(responseData['message']),
            ),
          );
        }
      } else {
        // Error in HTTP request
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text("Failed to reset password"),
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text("Failed to reset password"),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight/1,
          width: screenWidth/1,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black,color.navy],
                begin: FractionalOffset(0.0,1.0),
                end: FractionalOffset(0.0,0.0),
                stops: [0.0,1.0],
                tileMode: TileMode.repeated,
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight/20,),
              BackButton(color: Colors.white,),
              Padding(
                padding:  EdgeInsets.only(top: screenHeight/20,left: screenWidth/4),
                child: Container(
                  height: screenHeight/10,
                  width: screenWidth/1,
                  child: Text('Forget Password',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25,color: Colors.white),),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Form(
                      key: _formkey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(left: screenWidth/12,right: screenWidth/12,bottom: screenHeight/35),
                                child: TextFormField(
                                    controller: emailController,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'Enter email address';
                                    //   } else if (!value.contains('@')) {
                                    //     return 'Please enter a valid email address';
                                    //   }
                                    //   return null;
                                    // },
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText: 'Enter email address'),
                                      EmailValidator(
                                          errorText:
                                          'Please correct email filled'),
                                    ]),
                                    style: TextStyle(color: Colors.white),
                                    cursorColor: Colors.white,
                                    decoration: InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(
                                          Icons.email,color: Colors.grey,
                                        ),
                                        labelStyle: TextStyle(
                                            color: color.beige
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: color.beige), // Change the color here
                                          borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: color.beige), // Change the color here
                                          borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                        ),
                                        fillColor: Colors.white,
                                        errorStyle: TextStyle(fontSize: 18.0),
                                        border: OutlineInputBorder(
                                            borderSide:
                                            BorderSide(color: Colors.red),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(9.0)))))),
                            Padding(
                              padding:EdgeInsets.only(left: screenWidth/12,right: screenWidth/12,bottom: screenHeight/35),
                              child: TextFormField(
                                controller: newPasswordController,
                                validator: MultiValidator([
                                  RequiredValidator(
                                      errorText: 'Please enter Password'),
                                  MinLengthValidator(8,
                                      errorText:
                                      'Password must be at least 8 digit'),
                                  PatternValidator(r'(?=.*?[#!@$%^&*-])',
                                      errorText:
                                      'Password must be at least one special character')
                                ]),
                                style: TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  hintText: 'New Password',
                                  labelText: 'New Password',
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Colors.grey,
                                  ),
                                  labelStyle: TextStyle(
                                      color: color.beige
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: color.beige), // Change the color here
                                    borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: color.beige), // Change the color here
                                    borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                  ),
                                  fillColor: Colors.white,
                                  errorStyle: TextStyle(fontSize: 18.0),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(9.0))),
                                ),
                              ),
                            ),
                            Padding(
                              padding:EdgeInsets.only(left: screenWidth/12,right: screenWidth/12,bottom: screenHeight/35),
                              child: TextFormField(
                                controller: confirmPasswordController,
                                validator: (value) {
                                  if (value != newPasswordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                                // validator: MultiValidator([
                                //   RequiredValidator(
                                //       errorText: 'Please enter Password'),
                                //   MinLengthValidator(8,
                                //       errorText:
                                //       'Password must be at least 8 digit'),
                                //   PatternValidator(r'(?=.*?[#!@$%^&*-])',
                                //       errorText:
                                //       'Password must be at least one special character')
                                // ]),
                                style: TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                 // hintText: 'Confirm Password',
                                  labelText: 'Comfirm Password',
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Colors.grey,
                                  ),
                                  labelStyle: TextStyle(
                                      color: color.beige
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: color.beige), // Change the color here
                                    borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: color.beige), // Change the color here
                                    borderRadius: BorderRadius.all(Radius.circular(9.0)),
                                  ),
                                  fillColor: Colors.white,
                                  errorStyle: TextStyle(fontSize: 18.0),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(9.0))),
                                ),
                              ),
                            ),
                            Padding(
                              padding:  EdgeInsets.only( left: screenWidth/10,top: screenHeight/30),
                                child: MaterialButton(
                                  color: Colors.blue,
                                  height: screenHeight/20,
                                  minWidth: screenWidth/1.5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10), // Set the radius
                                  ),
                                  child: Text(
                                    'Reset',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 22),
                                  ),
                                  onPressed: () {
                                    if (_formkey.currentState!.validate()) {
                                      resetPassword(emailController.text, newPasswordController.text);
                                      print('form submitted');
                                    }
                                  },
                                ),
                              ),
                          ]),
                    )),
              ),
            ],
          ),
        ),
      ) ,
    );
  }
}
