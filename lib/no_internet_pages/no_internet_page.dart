import 'package:flutter/material.dart';

class NoInternetConnectivityToast extends StatelessWidget {
  const NoInternetConnectivityToast({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: height,
      color: const Color.fromARGB(82, 28, 12, 11),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 1.0, color: Colors.white),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            width: width,
            height: 150,
            child: Column(
              children: [
                Icon(
                  Icons.signal_wifi_connected_no_internet_4_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 50,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "No Internet Connection!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Check Your Internet Connection",
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
