import 'dart:convert';

import 'package:chess_game/login/sign_in.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:phone_text_field/phone_text_field.dart';
import '../api/signup_api.dart';
import '../user/user_preference.dart';
import '../user/users.dart';
import 'email_otpscreen.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

String getCountryFlagUrl(String countryCode) {
  // Define a map of international dialing codes to country codes
  final Map<String, String> dialingToCountryCode = {
    '+91': 'IN',
    '+1': 'US',
    '+7': 'RU', // Russia
    '+20': 'EG', // Egypt
    '+27': 'ZA', // South Africa
    '+30': 'GR', // Greece
    '+31': 'NL', // Netherlands
    '+32': 'BE', // Belgium
    '+33': 'FR', // France
    '+34': 'ES', // Spain
    '+36': 'HU', // Hungary
    '+39': 'IT', // Italy
    '+40': 'RO', // Romania
    '+41': 'CH', // Switzerland
    '+43': 'AT', // Austria
    '+44': 'GB', // United Kingdom
    '+45': 'DK', // Denmark
    '+46': 'SE', // Sweden
    '+47': 'NO', // Norway
    '+48': 'PL', // Poland
    '+49': 'DE', // Germany
    '+51': 'PE', // Peru
    '+52': 'MX', // Mexico
    '+53': 'CU', // Cuba
    '+54': 'AR', // Argentina
    '+55': 'BR', // Brazil
    '+56': 'CL', // Chile
    '+57': 'CO', // Colombia
    '+58': 'VE', // Venezuela
    '+60': 'MY', // Malaysia
    '+61': 'AU', // Australia
    '+62': 'ID', // Indonesia
    '+63': 'PH', // Philippines
    '+64': 'NZ', // New Zealand
    '+65': 'SG', // Singapore
    '+66': 'TH', // Thailand
    '+81': 'JP', // Japan
    '+82': 'KR', // South Korea
    '+84': 'VN', // Vietnam
    '+86': 'CN', // China
    '+90': 'TR', // Turkey
    '+92': 'PK', // Pakistan
    '+93': 'AF', // Afghanistan
    '+94': 'LK', // Sri Lanka
    '+95': 'MM', // Myanmar
    '+98': 'IR', // Iran
    '+212': 'MA', // Morocco
    '+213': 'DZ', // Algeria
    '+216': 'TN', // Tunisia
    '+218': 'LY', // Libya
    '+220': 'GM', // Gambia
    '+221': 'SN', // Senegal
    '+222': 'MR', // Mauritania
    '+223': 'ML', // Mali
    '+224': 'GN', // Guinea
    '+225': 'CI', // Ivory Coast
    '+226': 'BF', // Burkina Faso
    '+227': 'NE', // Niger
    '+228': 'TG', // Togo
    '+229': 'BJ', // Benin
    '+230': 'MU', // Mauritius
    '+231': 'LR', // Liberia
    '+232': 'SL', // Sierra Leone
    '+233': 'GH', // Ghana
    '+234': 'NG', // Nigeria
    '+235': 'TD', // Chad
    '+236': 'CF', // Central African Republic
    '+237': 'CM', // Cameroon
    '+238': 'CV', // Cape Verde
    '+239': 'ST', // Sao Tome and Principe
    '+240': 'GQ', // Equatorial Guinea
    '+241': 'GA', // Gabon
    '+242': 'CG', // Congo
    '+243': 'CD', // Democratic Republic of the Congo
    '+244': 'AO', // Angola
    '+245': 'GW', // Guinea-Bissau
    '+246': 'IO', // British Indian Ocean Territory
    '+248': 'SC', // Seychelles
    '+249': 'SD', // Sudan
    '+250': 'RW', // Rwanda
    '+251': 'ET', // Ethiopia
    '+252': 'SO', // Somalia
    '+253': 'DJ', // Djibouti
    '+254': 'KE', // Kenya
    '+255': 'TZ', // Tanzania
    '+256': 'UG', // Uganda
    '+257': 'BI', // Burundi
    '+258': 'MZ', // Mozambique
    '+260': 'ZM', // Zambia
    '+261': 'MG', // Madagascar
    '+262': 'RE', // Réunion
    '+263': 'ZW', // Zimbabwe
    '+264': 'NA', // Namibia
    '+265': 'MW', // Malawi
    '+266': 'LS', // Lesotho
    '+267': 'BW', // Botswana
    '+268': 'SZ', // Eswatini (Swaziland)
    '+269': 'KM', // Comoros
    '+290': 'SH', // Saint Helena
    '+291': 'ER', // Eritrea
    '+297': 'AW', // Aruba
    '+298': 'FO', // Faroe Islands
    '+299': 'GL', // Greenland
    '+350': 'GI', // Gibraltar
    '+351': 'PT', // Portugal
    '+352': 'LU', // Luxembourg
    '+353': 'IE', // Ireland
    '+354': 'IS', // Iceland
    '+355': 'AL', // Albania
    '+356': 'MT', // Malta
    '+357': 'CY', // Cyprus
    '+358': 'FI', // Finland
    '+359': 'BG', // Bulgaria
    '+370': 'LT', // Lithuania
    '+371': 'LV', // Latvia
    '+372': 'EE', // Estonia
    '+373': 'MD', // Moldova
    '+374': 'AM', // Armenia
    '+375': 'BY', // Belarus
    '+376': 'AD', // Andorra
    '+377': 'MC', // Monaco
    '+378': 'SM', // San Marino
    '+380': 'UA', // Ukraine
    '+381': 'RS', // Serbia
    '+382': 'ME', // Montenegro
    '+383': 'XK', // Kosovo
    '+385': 'HR', // Croatia
    '+386': 'SI', // Slovenia
    '+387': 'BA', // Bosnia and Herzegovina
    '+389': 'MK', // North Macedonia
    '+420': 'CZ', // Czech Republic
    '+421': 'SK', // Slovakia
    '+423': 'LI', // Liechtenstein
    '+500': 'FK', // Falkland Islands
    '+501': 'BZ', // Belize
    '+502': 'GT', // Guatemala
    '+503': 'SV', // El Salvador
    '+504': 'HN', // Honduras
    '+505': 'NI', // Nicaragua
    '+506': 'CR', // Costa Rica
    '+507': 'PA', // Panama
    '+508': 'PM', // Saint Pierre and Miquelon
    '+509': 'HT', // Haiti
    '+590': 'GP', // Guadeloupe
    '+591': 'BO', // Bolivia
    '+592': 'GY', // Guyana
    '+593': 'EC', // Ecuador
    '+594': 'GF', // French Guiana
    '+595': 'PY', // Paraguay
    '+596': 'MQ', // Martinique
    '+597': 'SR', // Suriname
    '+598': 'UY', // Uruguay
    '+599': 'CW', // Curaçao
    '+670': 'TL', // Timor-Leste
    '+672': 'NF', // Norfolk Island
    '+673': 'BN', // Brunei
    '+674': 'NR', // Nauru
    '+675': 'PG', // Papua New Guinea
    '+676': 'TO', // Tonga
    '+677': 'SB', // Solomon Islands
    '+678': 'VU', // Vanuatu
    '+679': 'FJ', // Fiji
    '+680': 'PW', // Palau
    '+681': 'WF', // Wallis and Futuna
    '+682': 'CK', // Cook Islands
    '+683': 'NU', // Niue
    '+685': 'WS', // Samoa
    '+686': 'KI', // Kiribati
    '+687': 'NC', // New Caledonia
    '+688': 'TV', // Tuvalu
    '+689': 'PF', // French Polynesia
    '+690': 'TK', // Tokelau
    '+691': 'FM', // Micronesia
    '+692': 'MH', // Marshall Islands
    '+850': 'KP', // North Korea
    '+852': 'HK', // Hong Kong
    '+853': 'MO', // Macau
    '+855': 'KH', // Cambodia
    '+856': 'LA', // Laos
    '+870': 'PN', // Pitcairn Islands
    '+880': 'BD', // Bangladesh
    '+886': 'TW', // Taiwan
    '+960': 'MV', // Maldives
    '+961': 'LB', // Lebanon
    '+962': 'JO', // Jordan
    '+963': 'SY', // Syria
    '+964': 'IQ', // Iraq
    '+965': 'KW', // Kuwait
    '+966': 'SA', // Saudi Arabia
    '+967': 'YE', // Yemen
    '+968': 'OM', // Oman
    '+971': 'AE', // United Arab Emirates
    '+972': 'IL', // Israel
    '+973': 'BH', // Bahrain
    '+974': 'QA', // Qatar
    '+975': 'BT', // Bhutan
    '+976': 'MN', // Mongolia
    '+977': 'NP', // Nepal
    '+992': 'TJ', // Tajikistan
    '+993': 'TM', // Turkmenistan
    '+994': 'AZ', // Azerbaijan
    '+995': 'GE', // Georgia
    '+996': 'KG', // Kyrgyzstan
    '+998': 'UZ', // Uzbekistan
    // Add other countries here
  };

  // Get the country code (e.g., IN, US) from the dialing code (e.g., +91, +1)
  String? countryCodeFromDialingCode = dialingToCountryCode[countryCode];

  // Define a map of country codes to flag URLs
  final Map<String, String> countryFlags = {
    'IN': 'flags/in.png',
    'US': 'flags/us.png',
    // Add other countries here
  };

  return countryFlags[countryCodeFromDialingCode] ?? 'https://example.com/flags/default.png';
}

// String getCountryFlagUrl(String countryCode) {
//   // Define a map of country codes to flag URLs
//   final Map<String, String> countryFlags = {
//     'IN': 'https://example.com/flags/in.png',
//     'US': 'https://example.com/flags/us.png',
//     // Add other countries here
//   };
//
//   return countryFlags[countryCode] ?? 'https://example.com/flags/default.png';
// }

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

  String countryFlagUrl = ''; // Declare the variable here
  var _isObscured;
  var phone="";
  EmailOTP myauth = EmailOTP();
  TextEditingController countryCode = TextEditingController();
  late DateTime otpGenerationTime;
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
        // If the server did not return a 200 OK response,
        // throw an exception or handle the error as needed.
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      // Handle any exceptions or errors that occur during the HTTP request.
      print('Error: Email Error : $e');
    }
  }

  Future<Users?> validate2(
      BuildContext context,
      String? email,
      String? mobile,
      ) async {
    try {
      // var uri = Uri.parse('https://leadproduct.000webhostapp.com/chessApi/validate.php');
      var uri = Uri.parse('https://schmidivan.com/Esakki/ChessGame/validate');
      var response = await http.post(uri, body: {
        "email": email,
        "mobile": mobile
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
        }else if(userJson['mobileFound'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.deepOrange,
              content: Text('Mobile number already exists'),
            ),
          );
        }
        else {
          // Proceed with user registration
          sendOTP(email);
        }
      } else if (response.statusCode == 404) {
        // Email not found in validation, proceed with registration
        sendOTP(email);
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
    return null;
  }


  Future<void> sendOTP(String? email) async {
    myauth.setConfig(
      appEmail: 'esakkimuthu2369@gmail.com',
      appName: 'BLAZING OTP',
      userEmail: emailController.text,
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );
    myauth.setSMTP(
      host: "smtp.gmail.com",
      auth: true,
      username: "esakkimuthu2369@gmail.com",
      password: "cjjv ibxm fdsb kwgu",
      secure: "TLS",
      port: 587,
    );
    if (await myauth.sendOTP()) {
      otpGenerationTime = DateTime.now();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPPage(
            myauth: myauth,
            nameController: nameController,
            emailController: emailController,
            mobileController: mobileController,
            countryCode: countryCode.text,
            countryFlagUrl: countryFlagUrl,
            //  passwordController: passwordController,
          ),
          settings: RouteSettings(arguments: myauth),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "'Oops, OTP send failed'",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.deepOrange,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    countryCode.text='+91 ';
    _isObscured = true;
  }
  TextEditingController phoneController = TextEditingController();
  final String _password = '';
  final _formKey = GlobalKey<FormState>();
  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
//  var passwordController = TextEditingController();

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
                                  return 'Enter Your User Name';
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
                                  labelText: 'User Name',
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
                        child:
                        PhoneTextField(
                          textStyle: const TextStyle(color: Colors.white),
                          initialCountryCode: '+91',
                          countryViewOptions: CountryViewOptions.countryCodeOnly,
                          showCountryCodeAsIcon: true,
                          invalidNumberMessage: 'invalid number',
                          // onChanged: (value) {},
                          onChanged: (PhoneNumber value) {
                            setState(() {
                              mobileController.text = value.completeNumber; // Extract the phone number
                              countryCode.text = value.countryCode; // Get country code
                              countryFlagUrl = getCountryFlagUrl(value.countryCode); // Retrieve flag URL
                              debugPrint('onChanged: $phone');
                            });
                          },
                          // controller: countryCode,
                          decoration: const InputDecoration(
                            labelText: 'phone Number',
                            labelStyle: TextStyle(
                                color: Colors.white
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.all(Radius.circular(9.0))
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius:
                                BorderRadius.all(Radius.circular(9.0))),
                            //prefixStyle: TextStyle(color: Colors.green),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.only(left: screenWidth / 12,
                      //       right: screenWidth / 12,
                      //       bottom: screenHeight / 35),
                      //   child: TextFormField(
                      //     controller: passwordController,
                      //     obscureText: _isObscured,
                      //     // validator: (value) {
                      //     //   if (value == null || value.isEmpty) {
                      //     //     return 'Please enter a password';
                      //     //   } else if (value.length < 8) {
                      //     //     return 'Password must be at least 8 characters long';
                      //     //   }
                      //     //   // Add more password validation rules as needed
                      //     //   return null;
                      //     // },
                      //     // onChanged: (value) {
                      //     //   setState(() {
                      //     //     _password = value;
                      //     //   });
                      //     // },
                      //     validator: MultiValidator([
                      //
                      //       RequiredValidator(
                      //           errorText: 'Please enter Password'),
                      //       MinLengthValidator(8,
                      //           errorText:
                      //           'Password must be at least 8 digit'),
                      //       PatternValidator(r'(?=.?[#!@$%^&-])',
                      //           errorText:
                      //           'Password must be at least one special character'),
                      //
                      //     ]).call,
                      //     style: const TextStyle(color: Colors.white),
                      //     cursorColor: Colors.white,
                      //     decoration: InputDecoration(
                      //       // hintText: 'Password',
                      //       labelText: 'Password',
                      //       prefixIcon: const Icon(
                      //         Icons.lock,
                      //         color: Colors.grey,
                      //       ),
                      //       suffixIcon: IconButton(
                      //         icon: _isObscured ?
                      //         const Icon(
                      //           Icons.visibility_off, color: Colors.grey,) :
                      //         const Icon(Icons.visibility, color: Colors.grey,),
                      //         onPressed: () {
                      //           setState(() {
                      //             _isObscured = !_isObscured;
                      //           });
                      //         },
                      //       ),
                      //       labelStyle: const TextStyle(
                      //           color: color.beige
                      //       ),
                      //       enabledBorder: const OutlineInputBorder(
                      //         borderSide: BorderSide(color: color.beige),
                      //         // Change the color here
                      //         borderRadius: BorderRadius.all(
                      //             Radius.circular(9.0)),
                      //       ),
                      //       focusedBorder: const OutlineInputBorder(
                      //         borderSide: BorderSide(color: color.beige),
                      //         // Change the color here
                      //         borderRadius: BorderRadius.all(
                      //             Radius.circular(9.0)),
                      //       ),
                      //       fillColor: Colors.white,
                      //       errorStyle: const TextStyle(fontSize: 12.0),
                      //       border: const OutlineInputBorder(
                      //           borderSide: BorderSide(color: Colors.red),
                      //           borderRadius:
                      //           BorderRadius.all(Radius.circular(9.0))),
                      //     ),
                      //   ),
                      // ),
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
                            final email = emailController.text;
                            final mobile = mobileController.text;
                            if (_formKey.currentState!.validate()) {
                              await validate2(context,email,mobile);
                            }
                          },
                        ),
                      ),
                      // SizedBox(height: screenHeight / 50,),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     const Text("already have a account ? ",
                      //       style: TextStyle(color: Colors.white),),
                      //     GestureDetector(
                      //         onTap: () {
                      //           Navigator.push(context, MaterialPageRoute(
                      //               builder: (context) => const SignIn()));
                      //         },
                      //         child: const Text('Login',
                      //           style: TextStyle(color: Colors.blue,
                      //               fontWeight: FontWeight.bold),
                      //         ))
                      //   ],
                      // ),

                    ]),
              ),
              // SizedBox(height: screenHeight / 50,),
              // const Align(
              //     alignment: Alignment.center,
              //     child: Text('OR', style: TextStyle(color: Colors.white,
              //         fontSize: 20,
              //         fontWeight: FontWeight.w500))),
              // SizedBox(height: screenHeight / 50,),
              // Align(
              //   alignment: Alignment.center,
              //   child: GestureDetector(
              //     onTap: () {},
              //     child: Container(
              //       height: screenHeight / 15,
              //       width: screenWidth / 1.2,
              //       decoration: BoxDecoration(
              //           color: Colors.white.withOpacity(0.15)
              //       ),
              //       child:
              //       //_buildWidget(),
              //       const Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //         children: [
              //          // Image(image: const AssetImage('assets/google.png'),height: screenHeight/20,width: screenWidth/10,),
              //           Text('  Continue with Google',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w500),)
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(height: screenHeight / 50,),
              // Align(
              //   alignment: Alignment.center,
              //   child: Container(
              //     height: screenHeight / 15,
              //     width: screenWidth / 1.2,
              //     decoration: BoxDecoration(
              //         color: Colors.white.withOpacity(0.15)
              //     ),
              //     child: const Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       children: [
              //       //  Image(image: const AssetImage('assets/facebook1.png'), height: screenHeight / 20, width: screenWidth / 10,),
              //         Text('  Continue with Facebook', style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 20,
              //             fontWeight: FontWeight.w500),)
              //       ],
              //     ),
              //   ),
              // )
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