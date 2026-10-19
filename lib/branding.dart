import 'package:flutter/material.dart';

class HubColors {
  static const ink = Color(0xff213830);
  static const green = Color(0xff285e50);
  static const muted = Color(0xff6e7b73);
  static const background = Color(0xfff6f7f3);
  static const line = Color(0xffe2e6df);
  static const pale = Color(0xffedf3ee);
}

ThemeData eventHubTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'Inter',
  colorScheme: const ColorScheme.light(
    primary: HubColors.green,
    onPrimary: Colors.white,
    primaryContainer: HubColors.pale,
    onPrimaryContainer: HubColors.ink,
    secondary: HubColors.muted,
    secondaryContainer: HubColors.pale,
    onSecondaryContainer: HubColors.ink,
    surface: Colors.white,
    onSurface: HubColors.ink,
    onSurfaceVariant: HubColors.muted,
    surfaceContainer: HubColors.background,
    surfaceContainerHighest: HubColors.pale,
    outline: Color(0xff97a69d),
    outlineVariant: HubColors.line,
    error: Color(0xff9d3838),
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: HubColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xfffcfcfa),
    foregroundColor: HubColors.ink,
    surfaceTintColor: Colors.transparent,
    scrolledUnderElevation: 0,
    elevation: 0,
    toolbarHeight: 76,
    titleSpacing: 20,
    shape: Border(bottom: BorderSide(color: HubColors.line)),
    titleTextStyle: TextStyle(
      fontFamily: 'Inter',
      fontSize: 19,
      fontWeight: FontWeight.w600,
      color: HubColors.ink,
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 29,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.8,
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.7,
    ),
    headlineSmall: TextStyle(
      fontSize: 23,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    titleLarge: TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    ),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 15, height: 1.55),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, height: 1.5, color: HubColors.muted),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: HubColors.line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: HubColors.green, width: 1.5),
    ),
    labelStyle: const TextStyle(color: HubColors.muted),
    helperMaxLines: 3,
    errorMaxLines: 3,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    color: Colors.white,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: const BorderSide(color: HubColors.line),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      side: const BorderSide(color: HubColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: HubColors.pale,
    side: const BorderSide(color: HubColors.line),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 13),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
  ),
);

/// The calendar/G mark is drawn locally, so no image package or network is needed.
class HubLogo extends StatelessWidget {
  final double size;
  const HubLogo({super.key, this.size = 40});
  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'GSU EventHub logo',
    child: CustomPaint(size: Size.square(size), painter: const _LogoPainter()),
  );
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 40);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 40, 40),
        const Radius.circular(11),
      ),
      Paint()..color = HubColors.green,
    );
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.65
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 10.5, 20, 19.5),
        const Radius.circular(2),
      ),
      stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(15, 8)
        ..lineTo(15, 13)
        ..moveTo(25, 8)
        ..lineTo(25, 13)
        ..moveTo(10, 17)
        ..lineTo(30, 17),
      stroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(24.5, 22)
        ..cubicTo(19, 17, 13, 24, 18, 28)
        ..cubicTo(20, 30, 23, 29, 24.6, 27.8)
        ..lineTo(24.6, 25)
        ..lineTo(21, 25),
      stroke..strokeWidth = 1.7,
    );
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}

class AppBrand extends StatelessWidget {
  final String subtitle;
  const AppBrand({super.key, this.subtitle = 'Campus event planner'});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const HubLogo(size: 36),
      const SizedBox(width: 10),
      Flexible(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'GSU EventHub',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.6,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, color: HubColors.muted),
            ),
          ],
        ),
      ),
    ],
  );
}
