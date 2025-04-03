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
              async function payWithPaystack() {
                const accessCode = window.accessCode;
                
                const popup = new PaystackPop();

                const popupIframes = document.querySelectorAll(
                  'iframe[src="https://checkout.paystack.com/popup"]'
                );

                if (popupIframes.length > 0) {
                  let timeoutId;

                  const lastContainer = popupIframes[popupIframes.length - 1];

                  // Create a MutationObserver instance
                  const observer = new MutationObserver((mutationsList) => {
                    for (const mutation of mutationsList) {
                      
                      if (
                        mutation.type === "attributes" &&
                        mutation.attributeName === "style"
                      ) {
                        if (lastContainer.style['display'] == 'none' && lastContainer.style['visibility'] == 'hidden') {
                          clearTimeout(timeoutId);
                          timeoutId = setTimeout(() => {
                            window.flutter_inappwebview.callHandler('closePaymentHandler');
                          }, 50);
                        }
                      }
                    }
                  });

                  // Configure the observer to watch for attribute changes
                  observer.observe(lastContainer, {
                    attributes: true,
                    attributeFilter: ["style"],
                  });
                }

                popup.resumeTransaction(accessCode);
              }
            </script>
          </body>
          </html>
          """,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;

          controller.addJavaScriptHandler(
            handlerName: 'closePaymentHandler',
            callback: (args) {
              Navigator.of(context).pop();
              return true;
            },
          );
        },
        onLoadStop: (controller, url) {
          controller.evaluateJavascript(source: """
window.accessCode = '${widget.paymentSheetParameters?.accessCode}';
      payWithPaystack();
    """);
        },
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint("JS Console: ${consoleMessage.message}");
        },
      ),
    );
  }
}
