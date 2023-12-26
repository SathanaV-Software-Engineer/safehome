import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:safehome/add_user/secondary_user_controller.dart';
import 'package:safehome/add_user/secondary_user_modal.dart';
import 'package:safehome/home/loader_contoller.dart';
import 'package:safehome/login/login_controller.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';
import 'package:safehome/utils/api_handler.dart';
import 'package:safehome/utils/common_utils.dart';
import 'package:safehome/utils/dialog_boxes.dart';

class AddUserPage extends ConsumerWidget {
  static final GlobalKey<FormState> _key = GlobalKey();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  AddUserPage({Key? key}) : super(key: key);
  final Color primaryColor = const Color.fromARGB(255, 5, 77, 67);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          key: scaffoldKey,
          body: Form(key: _key, child: _body(context, ref)),
        ),
      ),
    );
  }

  _body(
    BuildContext context,
    WidgetRef ref,
  ) {
    return ConnectivityWidget(
        offlineBanner: const NoInternetConnectivityToast(),
        builder: (BuildContext context, bool isOnline) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref.read(loginController).setToken();
                          },
                          child: Text(
                            "Watchers List",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MyTooltip(
                            message:
                                'People who may be neighbours, family, or friends will be notified if something unusual occurs in your area.',
                            child: Icon(
                              Icons.info_outline,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 50.0),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 20),
                //   child: _mobileNumber(context, ref),
                // ),
                const SizedBox(height: 40.0),
                Column(
                  children: List.generate(
                    ref.read(secondaryUserController).mobileList.length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _addSecondaryUser(context, ref, index),
                      );
                    },
                  )
                      .expand(
                          (widget) => [widget, const SizedBox(height: 10.0)])
                      .toList(),
                ),
              ],
            ),
          );
        });
  }

  _addSecondaryUser(context, ref, index) {
    final FlutterContactPicker contactPicker = FlutterContactPicker();
    TextEditingController controller = TextEditingController();
    MobileNumberModal mobileNumberDetails =
        ref.watch(secondaryUserController).mobileList[index];
    controller.text = mobileNumberDetails.mobileNumber;
    controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length));
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 1, 0, 1),
            child: SizedBox(
              width: 195,
              child: TextFormField(
                maxLength: 13,
                key: Key(index.toString()),
                onChanged: (value) {
                  ref
                      .read(secondaryUserController)
                      .updateMobileList(index, value);
                  controller.text = value;
                  controller.selection = TextSelection.fromPosition(
                      TextPosition(offset: controller.text.length));
                },
                controller: controller,
                enabled: !mobileNumberDetails.isSaved,
                cursorColor: Theme.of(context).primaryColor,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(16.0),
                  hintText: 'Add Secondary User',
                  counterText: "",
                  hintStyle: TextStyle(
                    fontSize: 15.0,
                    color: Color.fromARGB(248, 183, 184, 185),
                  ),
                  filled: true,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  fillColor: Colors.white,
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontSize: 16.0),
                keyboardType: TextInputType.number,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (mobileNumberDetails.isSaved)
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      showCustomDialog(ref, context, 'deleteSecondaryUser',
                          mobileNumberDetails.customerId, '');
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Icon(
                        Icons.delete_forever_rounded,
                        size: 25,
                        color: Color.fromARGB(255, 151, 58, 51),
                      ),
                    ),
                  ),
                if (mobileNumberDetails.isSaved)
                  GestureDetector(
                    onTap: () async {
                      await FlutterShare.share(
                        title: 'Check out "Salzer Home Guard"',
                        text: 'Check out "Salzer Home Guard"',
                        linkUrl:
                            'https://play.google.com/store/apps/details?id=com.schnelliot.safehome',
                        chooserTitle: 'Share "Salzer Home Guard" via',
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Icon(
                        Icons.share,
                        size: 25,
                        color: primaryColor,
                      ),
                    ),
                  ),
                if (!mobileNumberDetails.isSaved &&
                    mobileNumberDetails.mobileNumber.isEmpty)
                  GestureDetector(
                    onTap: () async {
                      Contact? contact = await contactPicker.selectContact();
                      if (contact != null) {
                        List phones = contact.phoneNumbers ?? [];
                        if (phones.isNotEmpty) {
                          String phoneNumber = removeCountryCode(phones[0]);
                          ref.read(secondaryUserController).updateMobileList(
                              index, removeSpaces(phoneNumber));
                        } else {
                          showToast('Selected contact has no phone number');
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Icon(
                        Icons.perm_contact_cal_sharp,
                        size: 25,
                        color: primaryColor,
                      ),
                    ),
                  ),
                if (mobileNumberDetails.isValid && !mobileNumberDetails.isSaved)
                  GestureDetector(
                    onTap: () => ref
                        .read(secondaryUserController)
                        .saveMobileNumber(context, ref, index)
                        .then((value) {
                      if (context.mounted) cleanLoaderMessage(context, ref);
                    }),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Icon(
                        Icons.check,
                        size: 25,
                        color: primaryColor,
                      ),
                    ),
                  ),
                getLoadingIcon(mobileNumberDetails),
              ],
            ),
          ),
        ],
      ),
    );
  }

  getLoadingIcon(MobileNumberModal mobileNumberDetails) {
    if (mobileNumberDetails.showError) {
      return const Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(
          Icons.warning,
          size: 25,
          color: Colors.orangeAccent,
        ),
      );
    } else if (!mobileNumberDetails.isValid &&
        mobileNumberDetails.mobileNumber.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class MyTooltip extends StatelessWidget {
  final Widget child;
  final String message;

  const MyTooltip({super.key, required this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      message: message,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      showDuration: const Duration(seconds: 3),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: child,
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
  }
}
