import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Size get size => MediaQuery.of(context).size;
  final scroll = ScrollController();
  final scrollDuration = const Duration(milliseconds: 400);
  final double scrollAmountMultiplier = 4.0;
  late final AnimationController _animation;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scroll.position.isScrollingNotifier.addListener(
        () {
          if (!scroll.position.isScrollingNotifier.value) {
            _animation.stop();
          } else {
            _animation.repeat();
          }
        },
      );
    });
    _animation = AnimationController(vsync: this);
    super.initState();
  }

  ListView _horizontalList(int n) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      controller: scroll,
      itemCount: 100,
      itemBuilder: (context, index) => Image.asset(
        'assets/images/bush.png',
        height: 100,
        width: size.width,
        alignment: Alignment.bottomCenter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        fit: StackFit.expand,
        children: [
          Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent &&
                  event.kind == PointerDeviceKind.mouse) {
                final scrollDelta = event.scrollDelta.dy;
                final newOffset =
                    scroll.offset + scrollDelta * scrollAmountMultiplier;
                if (scrollDelta.isNegative) {
                  scroll.animateTo(
                    math.max(0.0, newOffset),
                    curve: Curves.linearToEaseOut,
                    duration: scrollDuration,
                  );
                } else {
                  scroll.animateTo(
                    math.min(scroll.position.maxScrollExtent, newOffset),
                    duration: scrollDuration,
                    curve: Curves.linearToEaseOut,
                  );
                }
              }
            },
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _horizontalList(100),
            ),
          ),
          Positioned(
            top: 200,
            left: 10,
            child: Lottie.asset(
              'assets/lottie/bee.json',
              height: 200,
              controller: _animation,
              onLoaded: (lottie) {
                _animation.duration = lottie.duration;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
