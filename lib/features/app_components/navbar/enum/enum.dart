import 'package:flutter/material.dart';
import '../../../infinite_scroll/view/infinite_scroll.dart';
import '../../../signal_r/view/signal_r.dart';

enum KNavbar { signalR, infiniteScroll }

extension KDrawerExtension on KNavbar {
  IconData get icon => switch (this) {
    KNavbar.signalR => Icons.private_connectivity_outlined,
    KNavbar.infiniteScroll => Icons.data_exploration_outlined,
  };

  IconData get iconSelected => switch (this) {
    KNavbar.signalR => Icons.private_connectivity_rounded,
    KNavbar.infiniteScroll => Icons.data_exploration_rounded,
  };

  String get title => switch (this) {
    KNavbar.signalR => 'Signal R',
    KNavbar.infiniteScroll => 'Infinite Scroll',
  };

  Widget get widget => switch (this) {
    KNavbar.signalR => const SignalRView(),
    KNavbar.infiniteScroll => const InfiniteScrollView(),
  };

  String get route => switch (this) {
    KNavbar.signalR => SignalRView.name,
    KNavbar.infiniteScroll => InfiniteScrollView.name,
  };

  bool get isSignalR => this == KNavbar.signalR;
  bool get isInfiniteScroll => this == KNavbar.infiniteScroll;

  bool get isNotSignalR => !isSignalR;
  bool get isNotInfiniteScroll => !isInfiniteScroll;
}
