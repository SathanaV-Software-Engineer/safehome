import 'package:flutter/material.dart';
import 'package:safehome/no_internet_pages/shimmer_home_page.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerNotifications extends StatelessWidget {
  const ShimmerNotifications({
    super.key,
    required this.height,
    required this.width,
  });

  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          shimmerContainerBox(height, width, 1, 5, 1, 17),
          shimmerContainerBox(height, width, 1, 25, 1, 17),
          shimmerContainerBox(height, width, 5, 4, 1, 9),
        ],
      ),
    ));
  }
}
