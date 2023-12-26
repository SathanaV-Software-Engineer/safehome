import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final editSpaceController =
    ChangeNotifierProvider<EditSpaceProvider>((ref) => EditSpaceProvider());

class EditSpaceProvider extends ChangeNotifier {
  String _gatewayLabel = '';
  bool _showSubmitbutton = false;
  updateLabel(WidgetRef ref, String value, String? origValue) {
    _gatewayLabel = value;
    if (value != origValue) {
      _showSubmitbutton = true;
    } else {
      _showSubmitbutton = false;
    }
    notifyListeners();
  }

  String get gatewayLabel => _gatewayLabel;
  bool get showSubmitbutton => _showSubmitbutton;
}
