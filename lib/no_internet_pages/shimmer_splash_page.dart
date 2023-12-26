import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SplashPageWithNoInternet extends StatelessWidget {
  const SplashPageWithNoInternet({
    super.key,
    required this.height,
    required this.width,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        enabled: true,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: height / 6,
              ),
              Center(
                child: Container(
                  height: height / 6,
                  width: width / 2,
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                height: height / 6,
              ),
              Center(
                child: Container(
                  height: height / 16,
                  width: width / 2.5,
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: height / 18),
              Center(
                child: Container(
                  height: height / 18,
                  width: width / 8,
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
