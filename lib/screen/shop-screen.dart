import 'package:flutter/material.dart';
import 'package:chess_game/colors.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  int _coins = 0; // Number of coins to be purchased
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentErrorResponse);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccessResponse);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWalletSelected);
  }

  void _initiatePayment(String price, String amount) {
    int priceInRs = int.parse(price.split(' ')[0]);

    var options = {
      'key': 'rzp_live_ILgsfZCZoFIKMb',
      'amount': priceInRs * 100, // Convert to paisa
      'name': 'Acme Corp.',
      'description': 'Purchase $amount coins',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    _razorpay.open(options);
  }


  // void _storePaymentDetails(PaymentSuccessResponse paymentResponse) async {
  //   // Call PHP API to store payment details
  //   var url = Uri.parse(
  //       'https://epistatehealth.com/Esakki/ChessGame/payment_coin');
  //   var httpResponse = await http.post(url, body: {
  //     'payment_id': paymentResponse.paymentId,
  //     'amount': (_coins * 100).toString(),
  //     'coins': _coins.toString(),
  //   });
  //
  //   if (httpResponse.statusCode == 200) {
  //     print('Payment details stored successfully');
  //   } else {
  //     print('Failed to store payment details');
  //   }
  // }

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
    final List<Map<String, String>> items = [
      {
        "amount": "100",
        "image": "assets/coin1.png",
        "offer": "100 RS offer",
        "price": "10 RS"
      },
      {
        "amount": "200",
        "image": "assets/coin3.png",
        "offer": "200 RS offer",
        "price": "20 RS"
      },
      {
        "amount": "300",
        "image": "assets/coin4.png",
        "offer": "300 RS offer",
        "price": "30 RS"
      },
      {
        "amount": "400",
        "image": "assets/coin5.png",
        "offer": "400 RS offer",
        "price": "40 RS"
      }
    ];
    return Container(
      height: screenHeight,
      width: screenWidth,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/home.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: color.navy1.withOpacity(0.25),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('Shop', style: TextStyle(color: Colors.white)),
                  _buildCurrencyContainer(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    assetImage: 'assets/money1.png',
                    amount: "0",
                  ),
                  _buildCurrencyContainer(
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    assetImage: 'assets/Dollar.png',
                    amount: "100",
                  ),
                ],
              ),
            ),
            Container(
              height: screenHeight / 2,
              width: screenWidth,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2)
              ),
              child: GridView.builder(
                padding: EdgeInsets.all(10.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: 4, // You can set the number of items
                itemBuilder: (context, index) {
                  return _buildGridItem(
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      amount: items[index]["amount"]!,
                      image: items[index]["image"]!,
                      offer: items[index]["offer"]!,
                      price: items[index]["price"]!
                  );
                },
              ),
            ),
            // Text('Enter the number of coins:'),
            // TextField(
            //   keyboardType: TextInputType.number,
            //   onChanged: (value) {
            //     setState(() {
            //       _coins = int.parse(value);
            //     });
            //   },
            // ),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: _openCheckout,
            //   child: Text('Buy Coins'),
            // ),
          ],
        ),
      ),
    );
  }


  void _handlePaymentErrorResponse(PaymentFailureResponse response) {
    showAlertDialog(context, "Payment Failed", "Code: ${response.code}\nDescription: ${response.message}\nMetadata:${response.error.toString()}");
  }

  void _handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    final httpResponse = await http.post(
      Uri.parse('https://schmidivan.com/Esakki/ChessGame/payment_coin'), // Replace with your server URL
      body: {
        'payment_id': response.paymentId,
        'amount': '100', // Replace with the actual amount or other logic
        'user_id': 'user123' // Replace with actual user ID
      },
    );

    if (httpResponse.statusCode == 200) {
      showAlertDialog(context, "Payment Successful", "Payment ID: ${response.paymentId}");
    } else {
      showAlertDialog(context, "Payment Successful but could not update the database", "Payment ID: ${response.paymentId}");
    }
  }

  void _handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {
        Navigator.of(context).pop(); // Dismiss the dialog
      },
    );
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _buildCurrencyContainer({
    required double screenHeight,
    required double screenWidth,
    required String assetImage,
    required String amount,
  }) {
    return
     Container(
        height: screenHeight / 32,
        width: screenWidth / 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color.navy,
        ),
        child: Row(
          children: [
            Image(
              image: AssetImage(assetImage),
              height: screenHeight / 20,
              width: screenWidth / 16,
            ),
            SizedBox(
              height: screenHeight / 32,
              width: screenWidth / 7,
              child: Center(
                child: Text(amount, style: TextStyle(color: Colors.white)),
              ),
            ),
            Image(
              image: AssetImage('assets/plus1.png'),
              height: screenHeight / 28,
              width: screenWidth / 23,
            ),
          ],
        ),
    );
  }

  Widget _buildGridItem({
    required double screenHeight,
    required double screenWidth,
    required String amount,
    required String image,
    required String offer,
    required String price
  }) {
    return GestureDetector(
      onTap: () {
        _initiatePayment(price, amount); // Initiates the payment process
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(amount, style: TextStyle(color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
            Image(image: AssetImage(image),
                fit: BoxFit.contain,
                height: screenHeight / 10,
                width: screenWidth / 3),
            Text(offer, style: TextStyle(color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
            Text(price, style: TextStyle(color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class PaymentSuccessResponse {
  String paymentId;
  String orderId;
  String signature;

  PaymentSuccessResponse({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  });

  factory PaymentSuccessResponse.fromMap(Map<String, dynamic> map) {
    return PaymentSuccessResponse(
      paymentId: map['razorpay_payment_id'],
      orderId: map['razorpay_order_id'],
      signature: map['razorpay_signature'],
    );
  }
}