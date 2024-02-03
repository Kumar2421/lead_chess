
import 'dart:async';
import 'dart:convert';
import 'package:chess_game/login/phone_number_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:chess_game/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user/user_preference.dart';
import 'package:http/http.dart' as http;
class OTPPage extends StatefulWidget {
  //final EmailOTP myauth;
  const OTPPage({Key? key,
    //required this.myauth,
  }) : super(key: key);

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  TextEditingController otpController = TextEditingController();
  var code = "";
  final FirebaseAuth auth = FirebaseAuth.instance;

  late DateTime otpGenerationTime;
  int otpExpirationDurationInSeconds = 60; // Set your desired expiration duration (e.g., 5 minutes).
  late Timer _otpTimer;
  int _remainingTime = 60; // Initial timer value in seconds
  bool _isTimerRunning = false;

  // Function to start the OTP timer
  void startOTPTimer() {
    _isTimerRunning = true;
    _otpTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isTimerRunning = false;
          timer.cancel(); // Stop the timer when it reaches 0
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    startOTPTimer();
    // Record the OTP generation time when this page is first loaded.
    otpGenerationTime = DateTime.now();
  }
  //
  //
  // Future<void> verifyOTP() async {
  //   final String enteredOTP = otpController.text;
  //
  //   DateTime currentTime = DateTime.now();
  //   Duration difference = currentTime.difference(otpGenerationTime);
  //
  //   if (difference.inSeconds <= otpExpirationDurationInSeconds) {
  //     // OTP is valid within the specified duration
  //     if (await widget.myauth.verifyOTP(otp: enteredOTP)) {
  //       // OTP is correct
  //       Fluttertoast.showToast(
  //         msg: "OTP is verified",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.CENTER,
  //         timeInSecForIosWeb: 1,
  //         backgroundColor: Colors.deepOrange,
  //         textColor: Colors.white,
  //         fontSize: 16.0,
  //       );
  //       // final prefs = await SharedPreferences.getInstance();
  //       //prefs.setBool('userLoggedIn', true);
  //       //   Future.delayed(Duration(milliseconds: 2000), (){
  //       Get.to(Sheet());
  //       //  });
  //       // Proceed with your desired action
  //     } else {
  //       // Invalid OTP
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           backgroundColor: Colors.deepOrange,
  //           content: Text("Invalid OTP"),
  //         ),
  //       );
  //       // Fluttertoast.showToast(
  //       //   msg: "Invalid OTP",
  //       //   toastLength: Toast.LENGTH_SHORT,
  //       //   gravity: ToastGravity.CENTER,
  //       //   timeInSecForIosWeb: 1,
  //       //   backgroundColor: Colors.deepOrange,
  //       //   textColor: Colors.white,
  //       //   fontSize: 16.0,
  //       // );
  //     }
  //   } else {
  //     // OTP has expired
  //     Fluttertoast.showToast(
  //       msg: "OTP has expired",
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.deepOrange,
  //       textColor: Colors.white,
  //       fontSize: 16.0,
  //     );
  //   }
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    _otpTimer.cancel();
    otpController.dispose();
    focusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Retrieve the myauth object passed from Myapp

   // final EmailOTP? myauth = ModalRoute.of(context)?.settings.arguments as EmailOTP?;

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    const focusedBorderColor = Color.fromRGBO(114, 178, 238, 1);
    final defaultPinTheme = PinTheme(
      width: screenWidth/9,
      height: screenHeight/18,
      textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(15),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Color.fromRGBO(234, 239, 243, 1),
      ),
    );
    final  errorPinTheme = defaultPinTheme.copyBorderWith(
      border: Border.all(color: Colors.redAccent),
    );
    return  Scaffold(
      backgroundColor: Colors.white,
      //extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined,color: Colors.black,),
        ),

      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding:  EdgeInsets.only(top: screenHeight/30),
            child: Text('Verification',style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold),),
          ),
          Padding(
            padding: EdgeInsets.only(left: screenWidth/10,top: screenHeight/30,bottom: screenHeight/30),
            child: Container(
              alignment: Alignment.topLeft,
              child: Text('Enter your OTP number'),
            ),
          ),
          Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    errorPinTheme: errorPinTheme,
                    controller: otpController,
                    focusNode: focusNode,
                    androidSmsAutofillMethod:
                    AndroidSmsAutofillMethod.smsUserConsentApi,
                    listenForMultipleSmsOnAndroid: true,
                    separatorBuilder: (index) => SizedBox(width: screenWidth/50),
                    validator: (s) {
                      return s == otpController.text ? null : 'Pin is incorrect';
                    },
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (pin) {
                      debugPrint('onCompleted: $pin');
                    },
                    onChanged: (value) {
                      debugPrint('onChanged: $value');
                    },
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin:  EdgeInsets.only(bottom: screenHeight/50),
                          width: screenWidth/15,
                          height: screenHeight/400,
                          color: focusedBorderColor,
                        ),
                      ],
                    ),
                    //   pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    // showCursor: true,
                    // onCompleted: (pin) => print(pin),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight/50,),
          Text(
            _isTimerRunning
                ? "Time remaining: $_remainingTime seconds"
                : "Timer expired",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: screenHeight/20,),
          Container(
            height: screenHeight/20,
            width: screenWidth/1.2,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential
                    (verificationId: PhoneLoginPage.verify, smsCode: code);

                  // Sign the user in (or link) with the credential
                  await auth.signInWithCredential(credential);
                  // if (await widget.myauth.verifyOTP(otp: enteredOTP)){
                  // if (myauth != null && await myauth.verifyOTP(otp: otpController.text)) {
                  //   await verifyOTP();
                  // }
                }catch (e){
                  print('worng otp');
                }
                // if (await widget.myauth.verifyOTP(otp: enteredOTP)){
                // if (myauth != null && await myauth.verifyOTP(otp: otpController.text)) {
                //   await verifyOTP();
                // }
              },
              //   onPressed: () {
              //   focusNode.unfocus();
              //   formKey.currentState!.validate();
              // },
              child: Text('Verify'),
              style: ElevatedButton.styleFrom(
                  primary: color.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }
}