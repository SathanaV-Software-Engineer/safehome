import 'package:flutter/material.dart';
import 'package:safehome/no_internet_pages/shimmer_home_page.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/place_holders.dart';

class AddSensorWithoutInternet extends StatelessWidget {
  const AddSensorWithoutInternet({
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 30,
          ),
          CirclePlaceholder(radius: width / 6),
          const SizedBox(
            height: 10,
          ),
          TitlePlaceholder(width: width / 2.5),
          shimmerContainerBox(height, width, 2, 10, 1)
        ],
      ),
    ));
  }
}
