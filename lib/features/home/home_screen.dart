import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'widgets/home_header.dart';
import '../../../../core/widgets/ramadan_background.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0, // Hide default toolbar space
      ),
      body: RamadanBackground(
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            physics: const ClampingScrollPhysics(), // Prevent bounce/stretch
            child: Column(
              children: [
                const HomeHeader(),
                SizedBox(height: 100.h), // Bottom padding for nav bar
              ],
            ),
          ),
        ),
      ),
    );
  }
}
