import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/utils/dialog_boxes.dart';

final loaderProvider = StateProvider<String>((ref) => '');

// Set function
void setLoaderMessage(BuildContext context, WidgetRef ref, String message) {
  ref.read(loaderProvider.notifier).state = message;
  if (message.isNotEmpty) {
    showLoaderWithMessage(context, message);
  }
}

void cleanLoaderMessage(BuildContext context, WidgetRef ref) {
  setLoaderMessage(context, ref, '');
  Navigator.of(context, rootNavigator: true).pop();
}
