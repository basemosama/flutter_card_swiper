import 'dart:async';

import 'package:flutter_card_swiper/src/enums.dart';

typedef CardSwiperOnSwipeWillMoveToNext = FutureOr<bool> Function(
  int previousIndex,
  int? currentIndex,
  CardSwiperDirection direction,
);

typedef CardSwiperOnSwiped = Future<void> Function(
  int previousIndex,
  int currentIndex,
  CardSwiperDirection direction,
);

typedef CardSwiperOnEnd = FutureOr<void> Function();

typedef CardSwiperOnTapDisabled = FutureOr<void> Function();

typedef CardSwiperOnUndo = bool Function(
  int? previousIndex,
  int currentIndex,
  CardSwiperDirection direction,
);
