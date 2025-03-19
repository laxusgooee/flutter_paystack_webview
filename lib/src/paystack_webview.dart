import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_paystack_webview/src/models/webview.dart';
import 'package:flutter_paystack_webview/src/models/errors.dart';
import 'package:flutter_paystack_webview/src/views/html_view.dart';

/// [PaystackWebview] is the facade of the library and exposes the operations that can be
/// executed on the PaystackWebview platform.
///
class PaystackWebview {
  // Disables the platform override in order to use a manually registered
  // ignore: comment_references
  // [SharePlatform] for testing purposes.
  // See https://github.com/flutter/flutter/issues/52267 for more details.
  //
  PaystackWebview._();

  /// Sets the publishable key that is used to identify the account on the
  /// PaystackWebview platform.
  static set publickKey(String value) {
    if (value == instance._publickKey) {
      return;
    }
    instance._publickKey = value;
    instance.markNeedsSettings();
  }

  /// Retrieves the publishable API key.
  static String get publickKey {
    if (instance._publickKey == null) {
      throw const PaystackConfigException('Publishable key is not set');
    }
    return instance._publickKey!;
  }

  /// Sets the custom url scheme
  static set urlScheme(String? value) {
    if (value == instance._urlScheme) {
      return;
    }
    instance._urlScheme = value;
    instance.markNeedsSettings();
  }

  /// Retrieves the custom url scheme
  static String? get urlScheme {
    return instance._urlScheme;
  }

  /// Initializes the payment by providing a configuration
  ///
  /// See [paymentSheetParameters] for more info. In order to show the
  /// payment sheet it is required to call [presentPaymentSheet].
  Future<void> initWebview({
    required SetupWebviewParameters paymentSheetParameters,
  }) async {
    assert(!(paymentSheetParameters.accessCode == null),
        'access code is required if you are yoing a backend');
    await _awaitForSettings();

    if (paymentSheetParameters == instance._paystackParameters) {
      return;
    }

    instance._paystackParameters = paymentSheetParameters;
    instance.markNeedsSettings();
  }

  Future<dynamic> showWebview(
      {required BuildContext context,
      bool enableDrag = false,
      bool isDismissible = true,
      bool isScrollControlled = false}) async {
    await _awaitForSettings();

    if (context.mounted) {
      return await showModalBottomSheet<void>(
          context: context,
          enableDrag: enableDrag,
          isDismissible: isDismissible,
          isScrollControlled: isScrollControlled,
          builder: (BuildContext context) => HTMLView(
                paymentSheetParameters: instance._paystackParameters,
              ));
    }
  }

  /// Reconfigures the PaystackWebview platform by applying the current values for
  /// [publickKey], [urlScheme]
  Future<void> applySettings() => _initialise(
        publickKey: publickKey,
        urlScheme: urlScheme,
      );

  FutureOr<void> _awaitForSettings() {
    if (_needsSettings) {
      _settingsFuture = applySettings();
    }
    if (_settingsFuture != null) {
      return _settingsFuture;
    }
    return null;
  }

  Future<void>? _settingsFuture;

  static final PaystackWebview instance = PaystackWebview._();

  String? _publickKey;
  String? _urlScheme;

  SetupWebviewParameters? _paystackParameters;

  bool _needsSettings = true;
  void markNeedsSettings() {
    _needsSettings = true;
    _awaitForSettings();
  }

  Future<void> _initialise(
      {required String publickKey, String? urlScheme}) async {
    _needsSettings = false;
  }

  // Internal use only
}
