import 'package:flutter/material.dart';
import 'package:safehome/no_internet_pages/shimmer_home_page.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/place_holders.dart';

class DeviceHistoryWithoutInternet extends StatelessWidget {
  const DeviceHistoryWithoutInternet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Center(
        child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              shimmerContainerBox(height, width, 1, 10, 2.6, 18),
              shimmerContainerBox(height, width, 1, 10, 2.6, 18)
            ],
          ),
          Row(
            children: [
              shimmerContainerBox(height, width, 1, 10, 2.6, 18),
              shimmerContainerBox(height, width, 1, 10, 2.6, 18)
            ],
          ),
          const BannerPlaceholder()
        ],
      ),
    ));
  }
}
