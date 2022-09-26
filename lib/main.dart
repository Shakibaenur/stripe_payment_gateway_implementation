import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:stripe_gateway_implementation/utils/constants.dart';

import 'data/network/client/dio_base_client.dart';

void main() {

  Stripe.publishableKey = Constants.stripePublisherKey;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Map<String, dynamic>? paymentIntentData;
  late int price = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
          ),
          onPressed: () {
            makePayment(amount: "5000", currency: "BDT");
          },
          child: const Text('Stripe'),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  Future<void> makePayment(
      {required String amount, required String currency}) async {
    try {
      paymentIntentData = await createPaymentIntent(amount, currency);
      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            // applePay: PaymentSheetApplePay(merchantCountryCode: 'US'),
            // googlePay: PaymentSheetGooglePay(merchantCountryCode: 'US'),
            merchantDisplayName: 'Shakiba',
            customerId: paymentIntentData!['customer'],
            paymentIntentClientSecret: paymentIntentData!['client_secret'],
            customerEphemeralKeySecret: paymentIntentData!['ephemeralkey'],
          ),
        );
        displayPaymentSheet();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      Response response = await DioBaseClient().postPayment(
        'https://api.stripe.com/v1/payment_intents',
        data: body,
        queryParameters: {
          "amount": calculateAmount(amount),
          'currency': currency,
          'payment_method_types[]': 'card'
        },
      );
      return response.data;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      snackbar('Payment Successful');
    } on Exception catch (e) {
      if (e is StripeException) {
        snackbar("Error from Stripe: ${e.error.localizedMessage}");
      } else {
        snackbar("Unforeseen error: ${e}");
      }
    } catch (e) {
      snackbar("exception: ${e}");
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }
  snackbar(String text) {
    return ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }
}
