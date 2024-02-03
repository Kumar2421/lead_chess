import 'dart:convert';

import 'package:chess_game/login/sign_up.dart';
import 'package:chess_game/screen/home_screen.dart';
import 'package:chess_game/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:chess_game/colors.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user/user_preference.dart';
import '../user/users.dart';
import 'forget_password.dart';
import 'package:http/http.dart' as http;


class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var _isObscured;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isObscured = true;
  }
  Map userData = {};
  final _formkey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();



  Future<Map<String, dynamic>?> loginUser(String email,String password) async {

    final url = Uri.parse("https://leadproduct.000webhostapp.com/chessApi/login.php");
    try {
      final response = await http.post(
        url,
        body: {
          "email": email,
          "password": password,
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
          // Future.delayed(Duration(milliseconds: 2000), (){
          // Get.to(SettingPage());
          // });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.deepOrange,
                content: Text('login successful'),
              ),
            );
            Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
          // Now you can use 'userData' in your Flutter app
          print('User Data: $userData');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.deepOrange,
              content: Text("you don't have a account"),
            ),
          );
          print('User not found.');
        }
      } else {
        // If the server did not return a 200 OK response,
        // throw an exception or handle the error as needed.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.deepOrange,
            content: Text("you don't have a account"),
          ),
        );
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      // Handle any exceptions or errors that occur during the HTTP request.
      print('Error: Email Error : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;
    return  Scaffold(
      body: SingleChildScrollView(
        child:  Center(
          child: Container(
            height: screenHeight/1,
            width: screenWidth/1,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.navy,Colors.black],
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  // stops: [0.0,1.0],
                  // tileMode: TileMode.repeated,
                )
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: screenHeight/20,),
                Align(
                    alignment: Alignment.topLeft,
                    child: BackButton(color: Colors.white,)),
                Padding(
                  padding:  EdgeInsets.only(top: screenHeight/20),
                        child: Image(image: AssetImage('assets/LC-logo1.png'),height: screenHeight/15,width: screenWidth/8,),
                    ),
                Text('LOGIN',style: GoogleFonts.oswald(color: Colors.white,fontSize: screenWidth/40,fontWeight: FontWeight.bold),),
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
                                  padding: const EdgeInsets.all(12.0),
                                  child: TextFormField(
                                    controller: emailController,
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
                                        //  hintText: 'Email',
                                          labelText: 'Email',
                                          prefixIcon: Icon(
                                            Icons.email,
                                            color: Colors.grey,
                                          ), labelStyle: TextStyle(
                                          color: color.beige
                                      ),
                                          // hintStyle: TextStyle(
                                          //   color: Colors.white
                                          // ),
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
                                padding: const EdgeInsets.all(12.0),
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: _isObscured,
                                  // validator: (PassCurrentValue){
                                  //   RegExp regex=RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                                  //   var passNonNullValue=PassCurrentValue??"";
                                  //   if(passNonNullValue.isEmpty){
                                  //     return ("Password is required");
                                  //   }
                                  //   else if(passNonNullValue.length<6){
                                  //     return ("Password Must be more than 5 characters");
                                  //   }
                                  //   else if(!regex.hasMatch(passNonNullValue)){
                                  //     return ("Password should contain upper,lower,digit and Special character ");
                                  //   }
                                  //   return null;
                                  // },
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
                                    //hintText: 'Password',
                                    labelText: 'Password',
                                    prefixIcon: Icon(
                                      Icons.lock,
                                       color: Colors.grey,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: _isObscured ? const Icon(Icons.visibility_off,color: Colors.grey,) : const Icon(Icons.visibility),
                                      onPressed: () {
                                        setState(() {
                                          _isObscured =! _isObscured;
                                        });
                                      },
                                    ),
                                    labelStyle: TextStyle(
                                        color: color.beige
                                    ),
                                    // hintStyle: TextStyle(
                                    //   color: Colors.white
                                    // ),
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
                              Container(
                                margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetPassword()));
                                    },
                                    child: Text('Forget Password!',style: TextStyle(color: Colors.blue),)),
                              ),
                              Padding(
                                padding:  EdgeInsets.only(top: screenHeight/30),
                                  child: MaterialButton(
                                    color: Colors.blue,
                                    height: screenHeight/20,
                                    minWidth: screenWidth/2,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10), // Set the radius
                                    ),
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 22),
                                    ),
                                    onPressed: () async {
                                      if (_formkey.currentState!.validate()) {
                                       // final email = emailController;
                                        //final password = passwordController;
                                        await loginUser(emailController.text,passwordController.text);
                                        print('form submitted');
                                      }
                                    },
                                  ),
                                ),
                              SizedBox(height: screenHeight/20,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("New user ? ",style: TextStyle(color: Colors.white),),
                                  GestureDetector(
                                      onTap: (){
                                         Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUp()));
                                      },
                                      child: Text('Create Account     ',
                                        style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),
                                      ))
                                ],
                              ),
                            ]),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}