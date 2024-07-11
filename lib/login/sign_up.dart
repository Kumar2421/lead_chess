import 'package:chess_game/login/sign_in.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../api/signup_api.dart';



class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  Map userData = {};
  // GoogleSignInAccount? _currentUser;
  //
  // void iniState() {
  //   _googleSignIn.onCurrentUserChanged.listen((account) {
  //     setState(() {
  //       _currentUser = account;
  //     });
  //   });
  //   _googleSignIn.signInSilently();
  //   super.initState();
  // }

  var _isObscured;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isObscured = true;
  }

  final String _password = '';
  final _formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight / 1,
          width: screenWidth / 1,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, color.navy],
                begin: FractionalOffset(0.0, 1.0),
                end: FractionalOffset(0.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.repeated,
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight / 20,),
              const BackButton(color: Colors.white,),
              // IconButton(onPressed: (){
              //  Navigator.push(context, MaterialPageRoute(builder: (context)=>SettingPage()));
              //  }, icon: Icon(Icons.arrow_back,size: 40,color: Colors.white,)),
              Padding(
                padding: EdgeInsets.only(top: screenHeight / 50,),
                child: SizedBox(
                  height: screenHeight / 15,
                  width: screenWidth / 1,
                  //color: Colors.blue,
                  child: const Center(child: Text('Sign Up', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white),)),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(left: screenWidth / 12,
                              right: screenWidth / 12,
                              bottom: screenHeight / 35),
                          child: TextFormField(
                              controller: nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter Your Name';
                                }
                                return null;
                              },
                              // validator: MultiValidator([
                              //   RequiredValidator(
                              //       errorText: 'Enter Your Name'),
                              // ]),
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                // hintText: 'Name',
                                  labelText: 'Name',
                                  prefixIcon: Icon(
                                    Icons.person, color: Colors.grey,
                                    //color: Colors.green,
                                  ),
                                  labelStyle: TextStyle(
                                      color: color.beige
                                  ),
                                  // hintStyle: TextStyle(
                                  //   color: Colors.white
                                  // ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: color.beige),
                                    // Change the color here
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(9.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: color.beige),
                                    // Change the color here
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(9.0)),
                                  ),
                                  fillColor: Colors.white,
                                  errorStyle: TextStyle(fontSize: 18.0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(9.0)))))),
                      Padding(
                          padding: EdgeInsets.only(left: screenWidth / 12,
                              right: screenWidth / 12,
                              bottom: screenHeight / 35),
                          child: TextFormField(
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter email address';
                                } else if (!value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              // validator: MultiValidator([
                              //   RequiredValidator(
                              //       errorText: 'Enter email address'),
                              //   EmailValidator(
                              //       errorText:
                              //       'Please correct email filled'),
                              // ]),
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(
                                    Icons.email, color: Colors.grey,
                                  ),
                                  labelStyle: TextStyle(
                                      color: color.beige
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: color.beige),
                                    // Change the color here
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(9.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: color.beige),
                                    // Change the color here
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(9.0)),
                                  ),
                                  fillColor: Colors.white,
                                  errorStyle: TextStyle(fontSize: 18.0),
                                  border: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(9.0)))))),
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth / 12,
                            right: screenWidth / 12,
                            bottom: screenHeight / 35),
                        child: TextFormField(
                          controller: mobileController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter phone number';
                            } else if (!RegExp(
                                r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$')
                                .hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                          // validator: MultiValidator([
                          //   RequiredValidator(
                          //       errorText: 'Please enter phone number'),
                          //   // MinLengthValidator(8,
                          //   //     errorText:
                          //   //     'Password must be at least 8 digit'),
                          //   PatternValidator((r'^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$'),
                          //       errorText:
                          //       'Password must be at least one special character')
                          // ]),
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: const InputDecoration(
                            hintText: 'mobile',
                            labelText: 'mobile',
                            prefixIcon: Icon(
                              Icons.mobile_friendly,
                              color: Colors.grey,
                            ),
                            labelStyle: TextStyle(
                                color: color.beige
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: color.beige),
                              // Change the color here
                              borderRadius: BorderRadius.all(
                                  Radius.circular(9.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: color.beige),
                              // Change the color here
                              borderRadius: BorderRadius.all(
                                  Radius.circular(9.0)),
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
                        padding: EdgeInsets.only(left: screenWidth / 12,
                            right: screenWidth / 12,
                            bottom: screenHeight / 35),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: _isObscured,
                          // validator: (value) {
                          //   if (value == null || value.isEmpty) {
                          //     return 'Please enter a password';
                          //   } else if (value.length < 8) {
                          //     return 'Password must be at least 8 characters long';
                          //   }
                          //   // Add more password validation rules as needed
                          //   return null;
                          // },
                          // onChanged: (value) {
                          //   setState(() {
                          //     _password = value;
                          //   });
                          // },
                          validator: MultiValidator([

                            RequiredValidator(
                                errorText: 'Please enter Password'),
                            MinLengthValidator(8,
                                errorText:
                                'Password must be at least 8 digit'),
                            PatternValidator(r'(?=.*?[#!@$%^&*-])',
                                errorText:
                                'Password must be at least one special character'),

                          ]).call,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            // hintText: 'Password',
                            labelText: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.grey,
                            ),
                            suffixIcon: IconButton(
                              icon: _isObscured ?
                              const Icon(
                                Icons.visibility_off, color: Colors.grey,) :
                              const Icon(Icons.visibility, color: Colors.grey,),
                              onPressed: () {
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                            labelStyle: const TextStyle(
                                color: color.beige
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: color.beige),
                              // Change the color here
                              borderRadius: BorderRadius.all(
                                  Radius.circular(9.0)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: color.beige),
                              // Change the color here
                              borderRadius: BorderRadius.all(
                                  Radius.circular(9.0)),
                            ),
                            fillColor: Colors.white,
                            errorStyle: const TextStyle(fontSize: 12.0),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                BorderRadius.all(Radius.circular(9.0))),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth / 6, top: screenHeight/50),
                          child: MaterialButton(
                            color: Colors.blue,
                            height: screenHeight/20,
                            minWidth: screenWidth/1.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Set the radius
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 22),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final name = nameController.text;
                                final email = emailController.text;
                                final mobile = mobileController.text;
                                final password = passwordController.text;
                                String imagePath = '';
                                    //'assets/placeholder_image.png';
                                if (name.isNotEmpty && email.isNotEmpty && mobile.isNotEmpty && password.isNotEmpty) {
                                  try {
                                    await validate(context, name, email, mobile, password, imagePath);
                                    // Handle successful registration here
                                  } catch (e) {
                                    // Handle error (e.g., show an error message)
                                    print('Error during registration: $e');
                                  }
                                } else {
                                  // Handle empty input fields (e.g., show an error message)
                                  print('All fields are required');
                                }
                                //final result =
                                // await addusers1(name,email,mobile,password);
                                // if (result != null) {
                                //   // Registration was successful, show toast and navigate.
                                //   showRegistrationSuccessMessage(context);
                                // }
                                //nameController.text;emailController.text;mobileController.text;passwordController.text;
                              }
                            },
                          ),
                        ),
                      SizedBox(height: screenHeight / 50,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("you have a account ? ",
                            style: TextStyle(color: Colors.white),),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (context) => const SignIn()));
                              },
                              child: const Text('Login',
                                style: TextStyle(color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),

                    ]),
              ),
              SizedBox(height: screenHeight / 50,),
              const Align(
                  alignment: Alignment.center,
                  child: Text('OR', style: TextStyle(color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500))),
              SizedBox(height: screenHeight / 50,),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: screenHeight / 15,
                    width: screenWidth / 1.2,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15)
                    ),
                    child:
                    //_buildWidget(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image(image: const AssetImage('assets/google.png'),height: screenHeight/20,width: screenWidth/10,),
                        const Text('  Continue with Google',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight / 50,),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: screenHeight / 15,
                  width: screenWidth / 1.2,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image(image: const AssetImage('assets/facebook1.png'),
                        height: screenHeight / 20,
                        width: screenWidth / 10,),
                      const Text('  Continue with Facebook', style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),)
                    ],
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
//   Widget _buildWidget() {
//     GoogleSignInAccount? user = _currentUser;
//     if(user != null) {
//     return Padding (
//      padding: const EdgeInsets.all (12.0),
//      child: Column (
//       children: [
//        ListTile(
//         leading: GoogleUserCircleAvatar (identity: user),
//         title: Text (user.displayName?? ''),
//         subtitle: Text (user.email),
//        ), // ListTile
//       const SizedBox (height: 20,),
//       const Text('Signed in successfully',
//       style: TextStyle (fontSize: 20),
//       ), // Text
//       const SizedBox (height: 10,),
//       ElevatedButton(
//        onPressed: signOut,
//        child: const Text('Sign out')
//       ) // ElevatedButton
//      ],
//      ), // Column
//     ); // Padding
//     }else{
//     return Padding(
//       padding: const EdgeInsets.all (12.0),
//       child: Column (
//         children: [const SizedBox (height: 20,),
//           const Text('You are not signed in',
//             style: TextStyle (fontSize: 20),
//         ), // Text
//           // const SizedBox (height: 10,),
//         ElevatedButton(
//          onPressed: signIn,
//          child: const Text('Sign in')
//        ), // ElevatedButton
//        ],
//       ), // Column
//      ); // Padding
//     }
//   }
//   void signOut() {
//     _googleSignIn.disconnect();
//   }
//   Future<void> signIn() async {
//     try{
//       await _googleSignIn.signIn();
//     }catch(e){
//       print('Error signing in $e');
//   }
//   }
// }
//
// final GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: [
//     'email'
//   ]
// );
