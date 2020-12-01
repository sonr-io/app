import 'package:sonar_app/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:sonar_app/controller/controller.dart';

class LiquidFill extends StatefulWidget {
  // Required Properties
  final IconData iconData;
  final Duration waveDuration;
  final double boxHeight = Get.height / 3;
  final double boxWidth;
  final Color waveColor;

  // Constructer
  LiquidFill({
    Key key,
    @required this.iconData,
    this.waveDuration = const Duration(seconds: 2),
    this.boxWidth = 225,
    this.waveColor = Colors.blueAccent,
  })  : assert(null != iconData),
        assert(null != waveDuration),
        assert(null != boxWidth),
        assert(null != waveColor),
        super(key: key);

  @override
  _LiquidFillState createState() => _LiquidFillState();
}

class _LiquidFillState extends State<LiquidFill> with TickerProviderStateMixin {
  final _iconKey = GlobalKey();
  AnimationController _waveController;
  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: widget.waveDuration,
    );
    _waveController.repeat();
  }

  @override
  void dispose() {
    _waveController?.stop();
    _waveController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ReceiveController receive = Get.find();
    return Obx(() {
      if (receive.progress.value < 1.0) {
        return Stack(
          children: <Widget>[
            SizedBox(
              height: widget.boxHeight,
              width: widget.boxWidth,
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (BuildContext context, Widget child) {
                  return CustomPaint(
                    painter: WavePainter(
                      iconKey: _iconKey,
                      waveAnimation: _waveController,
                      percent: receive.progress.value,
                      boxHeight: widget.boxHeight,
                      waveColor: widget.waveColor,
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: widget.boxHeight,
              width: widget.boxWidth,
              child: ShaderMask(
                blendMode: BlendMode.srcOut,
                shaderCallback: (bounds) => LinearGradient(
                  colors: [NeumorphicTheme.baseColor(context)],
                  stops: [0.0],
                ).createShader(bounds),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Icon(widget.iconData, key: _iconKey, size: 225),
                  ),
                ),
              ),
            )
          ],
        );
      }
      _waveController.stop();
      return Container();
    });
  }
}
