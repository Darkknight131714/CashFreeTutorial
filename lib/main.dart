import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    CFPaymentGatewayService().setCallback(verifyPayment, onError);
  }

  void verifyPayment(String orderId) {
    print("Verify Payment");
  }

  void onError(CFErrorResponse errorResponse, String orderId) {
    print(errorResponse.getMessage());
    print("Error while making payment");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bonjour"),
      ),
      body: ElevatedButton(
        child: Text("Pay"),
        onPressed: () async {
          int temp = Random().nextInt(10000);
          var resp = await http.post(
            Uri.parse('https://sandbox.cashfree.com/pg/orders'),
            headers: {
              'content-Type': 'application/json',
              'accept': 'application/json',
              'x-client-id': '329023cfdaca4929edebb9a3d6320923',
              'x-client-secret': '30ef035a9de592b74808a0b14ae4bf7103f86593',
              'x-api-version': '2022-09-01',
              'x-request-id': 'Depri',
            },
            body: jsonEncode(
              {
                "order_id": temp.toString(),
                "order_amount": '1',
                "order_currency": "INR",
                "order_note": "Additional order info",
                "customer_details": {
                  "customer_id": "hello",
                  "customer_name": "name",
                  "customer_email": "darkknight131714@gmail.com",
                  "customer_phone": "7575871552",
                }
              },
            ),
          );
          if (resp.statusCode != 200) {
            print(resp.statusCode);
            print("Error: " + resp.toString());
          } else {
            print(resp.statusCode);
            String orderId = jsonDecode(resp.body)['order_id'].toString();
            String paymentSessionId =
                jsonDecode(resp.body)['payment_session_id'];
            // print(jsonDecode(resp.body).toString());
            CFEnvironment environment = CFEnvironment.SANDBOX;
            var session = CFSessionBuilder()
                .setEnvironment(environment)
                .setOrderId(orderId)
                .setPaymentSessionId(paymentSessionId)
                .build();
            List<CFPaymentModes> components = <CFPaymentModes>[];
            var paymentComponent =
                CFPaymentComponentBuilder().setComponents(components).build();

            var theme = CFThemeBuilder()
                .setNavigationBarBackgroundColorColor("#FF0000")
                .setPrimaryFont("Menlo")
                .setSecondaryFont("Futura")
                .build();

            var cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
                .setSession(session!)
                .setPaymentComponent(paymentComponent)
                .setTheme(theme)
                .build();
            CFPaymentGatewayService().doPayment(cfDropCheckoutPayment);
          }
        },
      ),
    );
  }
}
