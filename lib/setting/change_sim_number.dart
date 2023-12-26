import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/login/user_model.dart';
import 'package:safehome/setting/settings_controller.dart';

class ChangeSimNo extends ConsumerWidget {
  static final GlobalKey<FormState> _key = GlobalKey();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  ChangeSimNo({Key? key}) : super(key: key);
  final Color primaryColor = const Color.fromARGB(255, 5, 77, 67);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Form(key: _key, child: _body(context, ref)),
      ),
    );
  }

  _body(
    BuildContext context,
    WidgetRef ref,
  ) {
    double height = MediaQuery.of(context).size.height;
    UserModel loggedUser = ref.watch(loginController).loggedUser;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          "Enter New SIM Number",
          style: TextStyle(
            color: Color.fromARGB(255, 133, 132, 132),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _oldSimNo(context, ref),
        ),
        const SizedBox(height: 12.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _newSimNo(context, ref),
        ),
        const SizedBox(height: 60.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: height / 17,
            width: double.infinity,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(primaryColor),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
              ),
              child: const Text(
                "Change SIM Number",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                ref
                    .read(settingsController)
                    .updateUser(context, ref, loggedUser, 'mobileNumber', '');
              },
            ),
          ),
        ),
      ],
    );
  }

  _oldSimNo(context, ref) {
    UserModel loggedUser = ref.watch(loginController).loggedUser;
    TextEditingController oldSimController = TextEditingController();
    oldSimController.text = loggedUser.mobileNumber!;
    oldSimController.selection = TextSelection.fromPosition(
        TextPosition(offset: oldSimController.text.length));
    return TextFormField(
      controller: oldSimController,
      decoration: InputDecoration(
          enabled: false,
          contentPadding: const EdgeInsets.all(16.0),
          hintText: '',
          counterText: "",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.call,
              size: 25,
              color: primaryColor,
            ),
          ),
          hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 15.0, color: const Color.fromARGB(248, 183, 184, 185)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: primaryColor)),
          filled: true,
          fillColor: Colors.white),
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.0),
      keyboardType: TextInputType.number,
    );
  }

  _newSimNo(BuildContext context, WidgetRef ref) {
    String newSimNumber = ref.watch(settingsController).newMobileNumber;
    TextEditingController newSimController = TextEditingController();
    newSimController.text = newSimNumber;
    newSimController.selection = TextSelection.fromPosition(
        TextPosition(offset: newSimController.text.length));
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      controller: newSimController,
      onChanged: (value) =>
          ref.read(settingsController).updateMobileNumber(value),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          hintText: 'New Mobile Number',
          counterText: "",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.call,
              size: 25,
              color: primaryColor,
            ),
          ),
          hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 15.0, color: const Color.fromARGB(248, 183, 184, 185)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: primaryColor)),
          filled: true,
          fillColor: Colors.white),
    );
  }
}
