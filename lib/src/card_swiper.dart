import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_card_swiper/src/allowed_swipe_direction.dart';
import 'package:flutter_card_swiper/src/card_animation.dart';
import 'package:flutter_card_swiper/src/card_swiper_controller.dart';
import 'package:flutter_card_swiper/src/enums.dart';
import 'package:flutter_card_swiper/src/extensions.dart';
import 'package:flutter_card_swiper/src/typedefs.dart';
import 'package:flutter_card_swiper/src/undoable.dart';

class CardSwiper extends StatefulWidget {
  /// Function that builds each card in the stack.
  ///
  /// The [int] parameter specifies the index of the card to build, and the [BuildContext]
  /// parameter provides the build context. The function should return a widget that represents
  /// the card at the given index. It can return `null`, which will result in an
  /// empty card being displayed.
  final NullableIndexedWidgetBuilder cardBuilder;

  /// The number of cards in the stack.
  ///
  /// The [cardsCount] parameter specifies the number of cards that will be displayed in the stack.
  ///
  /// This parameter is required and must be greater than 0.
  final int cardsCount;

  /// The index of the card to display initially.
  ///
  /// Defaults to 0, meaning the first card in the stack is displayed initially.
  final int initialIndex;

  /// The [CardSwiperController] used to control the swiper externally.
  ///
  /// If `null`, the swiper can only be controlled by user input.
  final CardSwiperController? controller;

  /// The duration of each swipe animation.
  ///
  /// Defaults to 200 milliseconds.
  final Duration duration;

  /// The padding around the swiper.
  ///
  /// Defaults to `EdgeInsets.symmetric(horizontal: 20, vertical: 25)`.
  final EdgeInsetsGeometry padding;

  /// The maximum angle the card reaches while swiping.
  ///
  /// Must be between 0 and 360 degrees. Defaults to 30 degrees.
  final double maxAngle;

  /// The threshold from which the card is swiped away.
  ///
  /// Must be between 1 and 100 percent of the card width. Defaults to 50 percent.
  final int threshold;

  /// The scale of the card that is behind the front card.
  ///
  /// The [scale] and [backCardOffset] both impact the positions of the back cards.
  /// In order to keep the back card position same after changing the [scale],
  /// the [backCardOffset] should also be adjusted.
  /// * As a rough rule of thumb, 0.1 change in [scale] effects an
  /// [backCardOffset] of ~35px.
  ///
  /// Must be between 0 and 1. Defaults to 0.9.
  final double scale;

  /// Whether swiping is disabled.
  ///
  /// If `true`, swiping is disabled, except when triggered by the [controller].
  ///
  /// Defaults to `false`.
  final bool isDisabled;

  /// Callback function that is called when a swipe action is performed.
  ///
  /// The function is called with the oldIndex, the currentIndex and the direction of the swipe.
  /// If the function returns `false`, the swipe action is canceled and the current card remains
  /// on top of the stack. If the function returns `true`, the swipe action is performed as expected.
  final CardSwiperOnSwipeWillMoveToNext? onSwipeWillMoveToNext;

  /// Callback function that is called when is swiped.
  final CardSwiperOnSwiped? onSwiped;

  /// Callback function that is called when there are no more cards to swipe.
  final CardSwiperOnEnd? onEnd;

  /// Callback function that is called when the swiper is disabled.
  final CardSwiperOnTapDisabled? onTapDisabled;

  /// The direction in which the card is swiped when triggered by the [controller].
  ///
  /// Defaults to [CardSwiperDirection.right].
  final CardSwiperDirection direction;

  /// A boolean value that determines whether the card can be swiped horizontally. The default value is true.
  @Deprecated(
    'Will be deprecated in the next major release. Use [AllowedSwipeDirection] instead',
  )
  final bool isHorizontalSwipingEnabled;

  /// A boolean value that determines whether the card can be swiped vertically. The default value is true.
  @Deprecated(
    'Will be deprecated in the next major release. Use [AllowedSwipeDirection] instead',
  )
  final bool isVerticalSwipingEnabled;

  /// Defined the directions in which the card is allowed to be swiped.
  /// Defaults to [AllowedSwipeDirection.all]
  final AllowedSwipeDirection allowedSwipeDirection;

  /// A boolean value that determines whether the card stack should loop. When the last card is swiped,
  /// if isLoop is true, the first card will become the last card again. The default value is true.
  final bool isLoop;

  /// An integer that determines the number of cards that are displayed at the same time.
  /// The default value is 2. Note that you must display at least one card, and no more than the [cardsCount] parameter.
  final int numberOfCardsDisplayed;

  /// Callback function that is called when a card is unswiped.
  ///
  /// The function is called with the oldIndex, the currentIndex and the direction of the previous swipe.
  /// If the function returns `false`, the undo action is canceled and the current card remains
  /// on top of the stack. If the function returns `true`, the undo action is performed as expected.
  final CardSwiperOnUndo? onUndo;

  /// The offset of the back card from the front card.
  ///
  /// In order to keep the back card position same after changing the [backCardOffset],
  /// the [scale] should also be adjusted.
  /// * As a rough rule of thumb, 35px change in [backCardOffset] effects a
  /// [scale] change of 0.1.
  ///
  /// Must be a positive value. Defaults to Offset(0, 40).
  final Offset backCardOffset;

  ///Callback to notify when the card has been dragged.
  final Function(int? index, CardSwiperDirection direction)? onDragUpdate;

  ///Determines whether swiping to left return to previous card.
  final bool shouldRewindOnLeftSwipe;

  /// Updates back card with previous card or next card while swiping.
  final bool shouldRewindBackOnLeftSwipe;

  const CardSwiper(
      {Key? key,
      required this.cardBuilder,
      required this.cardsCount,
      this.controller,
      this.initialIndex = 0,
      this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      this.duration = const Duration(milliseconds: 200),
      this.maxAngle = 30,
      this.threshold = 50,
      this.scale = 0.9,
      this.isDisabled = false,
      this.onTapDisabled,
      this.onSwipeWillMoveToNext,
      this.onSwiped,
      this.onEnd,
      this.direction = CardSwiperDirection.right,
      @Deprecated('Will be deprecated in the next major release. Use [allowedSwipeDirection] instead')
          this.isHorizontalSwipingEnabled = true,
      @Deprecated('Will be deprecated in the next major release. Use [allowedSwipeDirection] instead')
          this.isVerticalSwipingEnabled = true,
      this.allowedSwipeDirection = const AllowedSwipeDirection.all(),
      this.isLoop = true,
      this.numberOfCardsDisplayed = 2,
      this.onUndo,
      this.backCardOffset = const Offset(0, 40),
      this.onDragUpdate,
      this.shouldRewindOnLeftSwipe = false,
      this.shouldRewindBackOnLeftSwipe = false})
      : assert(
          maxAngle >= 0 && maxAngle <= 360,
          'maxAngle must be between 0 and 360',
        ),
        assert(
          threshold >= 1 && threshold <= 100,
          'threshold must be between 1 and 100',
        ),
        assert(
          direction != CardSwiperDirection.none,
          'direction must not be none',
        ),
        assert(
          scale >= 0 && scale <= 1,
          'scale must be between 0 and 1',
        ),
        assert(
          numberOfCardsDisplayed >= 1 && numberOfCardsDisplayed <= cardsCount,
          'you must display at least one card, and no more than [cardsCount]',
        ),
        assert(
          initialIndex >= 0 && initialIndex < cardsCount,
          'initialIndex must be between 0 and [cardsCount]',
        ),
        super(key: key);

  @override
  State createState() => _CardSwiperState();
}

class _CardSwiperState<T extends Widget> extends State<CardSwiper>
    with SingleTickerProviderStateMixin {
  late CardAnimation _cardAnimation;
  late AnimationController _animationController;

  SwipeType _swipeType = SwipeType.none;
  CardSwiperDirection _detectedDirection = CardSwiperDirection.none;
  bool _tappedOnTop = false;

  final _undoableIndex = Undoable<int?>(null);
  final Queue<CardSwiperDirection> _directionHistory = Queue();

  int? get _currentIndex => _undoableIndex.state;

  int? get _nextIndex => getValidIndexOffset(1);

  bool get _canSwipe => _currentIndex != null && !widget.isDisabled;

  CardSwiperDirection _lastDetectedDirection = CardSwiperDirection.none;

  @override
  void initState() {
    super.initState();

    _undoableIndex.state = widget.initialIndex;

    widget.controller?.addListener(_controllerListener);

    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )
      ..addListener(_animationListener)
      ..addStatusListener(_animationStatusListener);

    _cardAnimation = CardAnimation(
      animationController: _animationController,
      maxAngle: widget.maxAngle,
      initialScale: widget.scale,
      // ignore: deprecated_member_use_from_same_package
      isVerticalSwipingEnabled: widget.isVerticalSwipingEnabled,
      // ignore: deprecated_member_use_from_same_package
      isHorizontalSwipingEnabled: widget.isHorizontalSwipingEnabled,
      allowedSwipeDirection: widget.allowedSwipeDirection,
      initialOffset: widget.backCardOffset,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    widget.controller?.removeListener(_controllerListener);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Padding(
          padding: widget.padding,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: List.generate(numberOfCardsOnScreen(), (index) {
                  if (index == 0) return _frontItem(constraints);

                  return _backItem(constraints, index);
                }).reversed.toList(),
              );
            },
          ),
        );
      },
    );
  }

  Widget _frontItem(BoxConstraints constraints) {
    return Positioned(
      left: _cardAnimation.left,
      top: _cardAnimation.top,
      child: GestureDetector(
        child: Transform.rotate(
          angle: _cardAnimation.angle,
          child: ConstrainedBox(
            constraints: constraints,
            child: widget.cardBuilder(context, _currentIndex!),
          ),
        ),
        onTap: () async {
          if (widget.isDisabled) {
            await widget.onTapDisabled?.call();
          }
        },
        onPanStart: (tapInfo) {
          if (!widget.isDisabled) {
            final renderBox = context.findRenderObject()! as RenderBox;
            final position = renderBox.globalToLocal(tapInfo.globalPosition);

            if (position.dy < renderBox.size.height / 2) _tappedOnTop = true;
          }
        },
        onPanUpdate: (tapInfo) {
          if (!widget.isDisabled) {
            if (_cardAnimation.left.abs() > _cardAnimation.top.abs()) {
              final direction = _cardAnimation.left.isNegative
                  ? CardSwiperDirection.left
                  : CardSwiperDirection.right;
              widget.onDragUpdate?.call(_currentIndex, direction);
              _lastDetectedDirection = direction;
            } else {
              final direction = _cardAnimation.top.isNegative
                  ? CardSwiperDirection.top
                  : CardSwiperDirection.bottom;
              widget.onDragUpdate?.call(_currentIndex, direction);
              _lastDetectedDirection = direction;
            }
            setState(
              () => _cardAnimation.update(
                tapInfo.delta.dx,
                tapInfo.delta.dy,
                _tappedOnTop,
              ),
            );
          }
        },
        onPanEnd: (tapInfo) {
          if (_canSwipe) {
            _tappedOnTop = false;
            _onEndAnimation();
          }
        },
      ),
    );
  }

  Widget _backItem(BoxConstraints constraints, int index) {
    return Positioned(
      top: (widget.backCardOffset.dy * index) - _cardAnimation.difference.dy,
      left: (widget.backCardOffset.dx * index) - _cardAnimation.difference.dx,
      child: Transform.scale(
        scale: _cardAnimation.scale - ((1 - widget.scale) * (index - 1)),
        child: ConstrainedBox(
          constraints: constraints,
          child: widget.cardBuilder(
            context,
            getValidIndexOffset(
              widget.shouldRewindBackOnLeftSwipe
                  ? _lastDetectedDirection == CardSwiperDirection.left
                      ? (index - 2)
                      : index
                  : index,
            )!,
          ),
        ),
      ),
    );
  }

  void _controllerListener() {
    switch (widget.controller?.state) {
      case CardSwiperState.swipe:
        return _swipe(widget.direction);
      case CardSwiperState.swipeLeft:
        return _swipe(CardSwiperDirection.left);
      case CardSwiperState.swipeRight:
        return _swipe(CardSwiperDirection.right);
      case CardSwiperState.swipeTop:
        return _swipe(CardSwiperDirection.top);
      case CardSwiperState.swipeBottom:
        return _swipe(CardSwiperDirection.bottom);
      case CardSwiperState.undo:
        return _undo();
      default:
        return;
    }
  }

  void _animationListener() {
    if (_animationController.status == AnimationStatus.forward) {
      setState(_cardAnimation.sync);
    }
  }

  Future<void> _animationStatusListener(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      switch (_swipeType) {
        case SwipeType.swipe:
          await _handleCompleteSwipe();
          break;
        default:
          break;
      }
      _reset();
    }
  }

  Future<void> _handleCompleteSwipe() async {
    final isLastCard = _currentIndex! == widget.cardsCount - 1;
    final shouldCancelSwipe = await widget.onSwipeWillMoveToNext
            ?.call(_currentIndex!, _nextIndex, _detectedDirection) ==
        false;

    if (shouldCancelSwipe) {
      return;
    }

    final previousIndex = _currentIndex;
    final index = widget.shouldRewindOnLeftSwipe
        ? _detectedDirection == CardSwiperDirection.left
            ? getValidIndexOffset(-1)
            : _nextIndex
        : _nextIndex;

    _undoableIndex.state = index;
    _directionHistory.add(_detectedDirection);

    if (isLastCard) {
      widget.onEnd?.call();
    }

    if (index != null) {
      await widget.onSwiped?.call(previousIndex!, index, _detectedDirection);
    }
  }

  void _reset() {
    setState(() {
      _animationController.reset();
      _cardAnimation.reset();
      _swipeType = SwipeType.none;
    });
  }

  void _onEndAnimation() {
    if (_cardAnimation.left.abs() > widget.threshold) {
      final direction = _cardAnimation.left.isNegative
          ? CardSwiperDirection.left
          : CardSwiperDirection.right;
      if (direction == CardSwiperDirection.left &&
              widget.allowedSwipeDirection.left ||
          direction == CardSwiperDirection.right &&
              widget.allowedSwipeDirection.right) {
        _swipe(direction);
        _lastDetectedDirection = direction;
      } else {
        _lastDetectedDirection = CardSwiperDirection.none;
        _goBack();
      }
    } else if (_cardAnimation.top.abs() > widget.threshold) {
      final direction = _cardAnimation.top.isNegative
          ? CardSwiperDirection.top
          : CardSwiperDirection.bottom;
      if (direction == CardSwiperDirection.top &&
              widget.allowedSwipeDirection.up ||
          direction == CardSwiperDirection.bottom &&
              widget.allowedSwipeDirection.down) {
        _lastDetectedDirection = direction;
        _swipe(direction);
      } else {
        _lastDetectedDirection = CardSwiperDirection.none;
        _goBack();
      }
    } else {
      _lastDetectedDirection = CardSwiperDirection.none;
      _goBack();
    }
  }

  void _swipe(CardSwiperDirection direction) {
    if (_currentIndex == null) return;

    _swipeType = SwipeType.swipe;
    _detectedDirection = direction;
    _cardAnimation.animate(context, direction);
  }

  void _goBack() {
    _swipeType = SwipeType.back;
    _detectedDirection = CardSwiperDirection.none;
    _cardAnimation.animateBack(context);
  }

  void _undo() {
    if (_directionHistory.isEmpty) return;
    if (_undoableIndex.previousState == null) return;

    final direction = _directionHistory.last;
    final shouldCancelUndo = widget.onUndo?.call(
          _currentIndex,
          _undoableIndex.previousState!,
          direction,
        ) ==
        false;

    if (shouldCancelUndo) {
      return;
    }

    _undoableIndex.undo();
    _directionHistory.removeLast();
    _swipeType = SwipeType.undo;
    _cardAnimation.animateUndo(context, direction);
  }

  int numberOfCardsOnScreen() {
    if (widget.isLoop) {
      return widget.numberOfCardsDisplayed;
    }
    if (_currentIndex == null) {
      return 0;
    }

    return math.min(
      widget.numberOfCardsDisplayed,
      widget.cardsCount - _currentIndex!,
    );
  }

  int? getValidIndexOffset(int offset) {
    if (_currentIndex == null) {
      return null;
    }

    final index = _currentIndex! + offset;
    if (!widget.isLoop && !index.isBetween(0, widget.cardsCount - 1)) {
      return null;
    }
    return index % widget.cardsCount;
  }
}
