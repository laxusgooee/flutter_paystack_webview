import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_paystack_webview/flutter_paystack_webview.dart';

class HTMLView extends StatefulWidget {
  const HTMLView({super.key, this.paymentSheetParameters});

  final SetupWebviewParameters? paymentSheetParameters;

  @override
  State<HTMLView> createState() => _HTMLViewState();
}

class _HTMLViewState extends State<HTMLView> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: null,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: InAppWebView(
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
        ),
        initialData: InAppWebViewInitialData(
          data: """
          <!DOCTYPE html>
          <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Paystack</title>
            <script src="https://js.paystack.co/v2/inline.js"></script>
          </head>
          <body style="background-color:#fff;height:100vh">
            <script>
              function payWithPaystack() {
                const accessCode = window.accessCode;

                console.log('>>>>>>>>>>>>' + accessCode);
                
                const popup = new PaystackPop();
                popup.resumeTransaction(accessCode);
              }
            </script>
          </body>
          </html>
          """,
        ),
        onLoadStop: (controller, url) {
          controller.evaluateJavascript(source: """
window.accessCode = '${widget.paymentSheetParameters?.accessCode}';
      payWithPaystack();
    """);
        },
        onConsoleMessage: (controller, consoleMessage) {
          print("JS Console: ${consoleMessage.message}");
        },
      ),
    );
  }
}
