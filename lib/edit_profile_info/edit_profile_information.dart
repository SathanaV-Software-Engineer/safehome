import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/edit_profile_info/edit_profile_controller.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';
import 'package:safehome/setting/settings_controller.dart';
import 'package:safehome/utils/dialog_boxes.dart';

import '../login/login_controller.dart';
import '../login/user_model.dart';

class EditProfileInformation extends ConsumerWidget {
  static final GlobalKey<FormState> _key = GlobalKey();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  EditProfileInformation({Key? key}) : super(key: key);
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
    UserModel loginUser = ref.watch(loginController).loggedUser;
    TextEditingController mobileController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();

    bool enableButton = ref.watch(editProfileController).enableButton;
    return ConnectivityWidget(
        offlineBanner: const NoInternetConnectivityToast(),
        builder: (BuildContext context, bool isOnline) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: height / 5,
                ),
                Text(
                  "Edit Profile Information",
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child:
                      _mobileNumber(context, ref, loginUser, mobileController),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _userName(context, ref, loginUser, nameController),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _userEmail(context, ref, loginUser, emailController),
                ),
                const SizedBox(height: 40.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: height / 17,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: enableButton
                            ? MaterialStateProperty.all(primaryColor)
                            : MaterialStateProperty.all(Colors.grey),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0))),
                      ),
                      child: const Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () async {
                        if (!enableButton) return;
                        if (mobileController.text != loginUser.mobileNumber) {
                          showCustomDialog(ref, context, 'changeSim', '', '')
                              .then((value) {
                            nameController.text = loginUser.profileName!;
                            emailController.text = loginUser.email!;
                            mobileController.text = loginUser.mobileNumber!;
                          });
                        } else {
                          ref
                              .read(settingsController)
                              .updateUserInformation(
                                  context,
                                  ref,
                                  ref.read(editProfileController).userDetails,
                                  false)
                              .then((val) {
                            nameController.text = loginUser.profileName!;
                            emailController.text = loginUser.email!;
                            mobileController.text = loginUser.mobileNumber!;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  _mobileNumber(
      BuildContext context, WidgetRef ref, UserModel loggedInUser, controller) {
    controller.text =
        ref.watch(editProfileController).userDetails.mobileNumber!;
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      controller: controller,
      onChanged: (value) {
        ref
            .read(editProfileController)
            .textFieldUpdate(loggedInUser, 'mobileNumber', controller.text);
      },
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.0),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          hintText: 'Mobile Number',
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

  _userName(
      BuildContext context, WidgetRef ref, UserModel loggedInUser, controller) {
    controller.text = ref.watch(editProfileController).userDetails.profileName!;
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      controller: controller,
      onChanged: (value) {
        ref
            .read(editProfileController)
            .textFieldUpdate(loggedInUser, 'profileName', controller.text);
      },
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.0),
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          hintText: 'Profile Name',
          counterText: "",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.person_2_rounded,
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

  _userEmail(
      BuildContext context, WidgetRef ref, UserModel loggedInUser, controller) {
    controller.text = ref.watch(editProfileController).userDetails.email!;
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    return TextFormField(
      cursorColor: Theme.of(context).primaryColor,
      validator: (value) =>
          controller.text!.isEmpty || EmailValidator.validate(controller.text)
              ? null
              : "Please enter a valid email",
      controller: controller,
      onChanged: (value) {
        ref
            .read(editProfileController)
            .textFieldUpdate(loggedInUser, 'email', controller.text);
      },
      style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.0),
      decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          ),
          contentPadding: const EdgeInsets.all(16.0),
          hintText: 'Email',
          counterText: "",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.email_sharp,
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
