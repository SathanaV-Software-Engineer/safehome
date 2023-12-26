import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safehome/no_internet_pages/no_internet_page.dart';

import '../utils/constants.dart';
import 'splash_controller.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: null,
        body: Padding(
          padding: EdgeInsets.zero,
          child: ConnectivityWidget(
            offlineBanner: const NoInternetConnectivityToast(),
            builder: (BuildContext context, bool isOnline) {
              return isOnline
                  ? FutureBuilder(
                      future: ref
                          .read(splashController)
                          .checkAppVersion(context, ref),
                      builder: (context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {}
                        return Image.asset(
                          splashImage,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          alignment: Alignment.center,
                        );
                      },
                    )
                  : const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
