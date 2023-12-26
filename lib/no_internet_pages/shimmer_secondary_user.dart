import 'package:flutter/material.dart';
import 'package:safehome/no_internet_pages/shimmer_home_page.dart';
import 'package:shimmer/shimmer.dart';

class SecondaryUserWithoutInternet extends StatelessWidget {
  const SecondaryUserWithoutInternet({
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
        children: [shimmerContainerBox(height, width, 4, 20, 1)],
      ),
    ));
  }
}
