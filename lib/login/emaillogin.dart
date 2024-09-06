

import 'dart:convert';
import 'package:chess_game/login/sign_up.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../colors.dart';
import '../user/user_preference.dart';
import '../user/users.dart';
import 'email_otpscreen.dart';
import 'package:get/get.dart';
class EmailPage extends StatefulWidget {
  const EmailPage({super.key});

  @override
  State<EmailPage> createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage> {
  TextEditingController emailController = new TextEditingController();
  TextEditingController otp = new TextEditingController();
  EmailOTP myauth = EmailOTP();
  final _formKey = GlobalKey<FormState>();

  late DateTime otpGenerationTime;
  int otpExpirationDurationInSeconds = 60;

  Future<Map<String, dynamic>?> loginUser(String email) async {

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
            myauth.setConfig(
              appEmail: 'esakkimuthu2369@gmail.com',
              //'your_app_email@example.com',
              appName: 'Chess Game OTP',
              userEmail: emailController.text,
              otpLength: 6,
              otpType: OTPType.digitsOnly,
            );
            myauth.setSMTP(
              host: "smtp.gmail.com",
              //host: 'mail.rohitchouhan.com',
              //auth: true,
              username: "esakkimuthu2369@gmail.com",
              password: "cjjv ibxm fdsb kwgu",
              //nevq djsk mkfz uaob3.
              secure: "TLS",
              port: 587,
              //576,
              // emailPort: EmailPort.port587,
              // secureType: SecureType.tls,
            );
            if (await myauth.sendOTP()) {
              otpGenerationTime = DateTime.now();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      OTPPage2(myauth: myauth,
                        emailController: emailController,

                        //  user: userInfo,
                      ),
                  settings: RouteSettings(
                    arguments: myauth,
                  ),
                ),
              );
            }

            else {
              Fluttertoast.showToast(
                  msg: "'Oops, OTP send failed'",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.deepOrange,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
            }
          }
        } else {
          Fluttertoast.showToast(
              msg: " Oops : email not found",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.deepOrange,
              textColor: Colors.white,
              fontSize: 16.0
          );
          // If the server did not return a 200 OK response,
          // throw an exception or handle the error as needed.
          throw Exception('Failed to load user data');
        }
      } catch (e) {
        // Handle any exceptions or errors that occur during the HTTP request.
        print('Error: Email Error : $e');
      }
      return null;
    }
  Future<void> saveUserDataLocally(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userData', jsonEncode(userData));
  }

  Future<void> saveSessionTokenLocally(String sessionToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('sessionToken', sessionToken);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.white,

        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding:  EdgeInsets.only(top:screenHeight/20),
                child: Container(
                  height: screenHeight/20,
                  width: screenWidth/4,
                  // color: Colors.pink,
                  child: Text('Login',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(left: screenWidth/15,top: screenHeight/40,bottom: screenHeight/50),
                child: Container(
                  alignment: Alignment.topLeft,
                  child: Text('Enter your Email-ID'),),),
              Form(
                key: _formKey,
                child: Padding(
                    padding: EdgeInsets.only(right: screenWidth/15,left: screenWidth/15),
                    child: TextFormField(
                        controller: emailController,
                        validator: MultiValidator([
                          RequiredValidator(
                              errorText: 'Enter email address'),
                          EmailValidator(
                              errorText:
                              'Please correct email filled'),
                        ]).call,
                        decoration: const InputDecoration(
                            hintText: 'Email',
                            labelText: 'Email',
                            labelStyle: TextStyle(
                                color: color.blue
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.grey,
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: color.blue)
                            ),
                            errorStyle: TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(9.0)))))),
              ),
              SizedBox(height: screenHeight/10,),
              Container(
                height: screenHeight/20,
                width: screenWidth/1.3,
                child: ElevatedButton(
                  onPressed: ()
                  async {
                    if (_formKey.currentState!.validate()) {
                      await loginUser(emailController.text);
                    }
                  },
                  child: Text('Continue'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: color.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ),
              SizedBox(height: screenHeight/20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("New user ? "),
                  GestureDetector(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUp()));
                      },
                      child: Text('Create Account',
                        style: TextStyle(color: color.blue,fontWeight: FontWeight.bold),
                      ))
                ],
              ),
            ])
    );
  }
}




class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _status = '';
  String _requestId = '';

  Future<void> _sendOTP() async {
    final response = await http.post(
      Uri.parse('https://schmidivan.com/Esakki/ChessGame/number'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': _phoneController.text}));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        _requestId = jsonResponse['request_id'] ?? '';
        _status = 'OTP Sent';
        print(jsonResponse);
      });
    } else {
      setState(() {
        _status = 'Failed to send OTP';
        print('${_status}');
      });
    }
  }

  Future<void> _verifyOTP() async {
    final response = await http.post(
      Uri.parse('https://schmidivan.com/Esakki/ChessGame/verify_otp'),
      body: {
        'request_id': _requestId,
        'code': _otpController.text,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        setState(() {
          _status = 'OTP Verified';
        });
      } else {
        setState(() {
          _status = 'Failed to verify OTP';
        });
      }
    } else {
      setState(() {
        _status = 'Failed to verify OTP';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login with Phone Number'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              style: TextStyle(color: Colors.red),
              decoration: InputDecoration(
                labelText: 'Phone Number',

              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendOTP,
              child: Text('Send OTP',style: TextStyle(color: Colors.red),),
            ),
            TextField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'OTP',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: Text('Verify OTP'),
            ),
            SizedBox(height: 20),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
