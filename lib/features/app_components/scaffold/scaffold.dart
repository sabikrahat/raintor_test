import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raintor_test/core/config/constant.dart';
import '../navbar/enum/enum.dart';
import '../navbar/navbar.dart';

class KScaffold extends ConsumerWidget {
  const KScaffold({super.key, required this.path, required this.body});

  final String? path;
  final Widget body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedNavbar = KNavbar.values.firstWhere(
      (e) => e.route == path,
      orElse: () => KNavbar.signalR,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedNavbar.title),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: body,
      bottomNavigationBar: KBottomNavbar(selectedNavbar: selectedNavbar),
    );
  }
}
