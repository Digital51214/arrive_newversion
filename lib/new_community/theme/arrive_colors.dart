import 'package:flutter/material.dart';

class ArriveColors {
  ArriveColors._();

  static const Color bg = Color(0xFF252D42);
  static const Color bgDark = Color(0xFF232A3D);

  static const Color glass = Color(0x1FFFFFFF);
  static const Color glassHover = Color(0x2DFFFFFF);
  static const Color glassBorder = Color(0x38FFFFFF);
  static const Color glassBorderHover = Color(0x59FFFFFF);

  // POSTPARTUM MODE COLORS (PINK)
  static const Color pink = Color(0xFFD4A0B8);


  static const Color pinkBright = Color(0xFFE8BCD0);

  // SPEAK FREELY MODE COLORS (BLUE)
  static const Color speakBlue = Color(0xFF89CFF0);
  static const Color speakBlueBright = Color(0xFFB8E7FA);

  static const Color blue = Color(0xFF90B8E0);
  static const Color sage = Color(0xFF8DBFAA);
  static const Color gold = Color(0xFFD4B896);
  static const Color green = Color(0xFF7DDE8A);
  static const Color purple = Color(0xFFC0AEE0);

  static const Color text = Color(0xFFFFFAF5);
  static const Color textSoft = Color(0xD9F0EBE4);
  static const Color textMuted = Color(0xA6F0EBE4);

  // Avatar gradients
  static const LinearGradient avA = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x47D296B8),
      Color(0x14D296B8),
    ],
  );

  static const LinearGradient avB = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x4778A5DC),
      Color(0x1478A5DC),
    ],
  );

  static const LinearGradient avC = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x478DBFAA),
      Color(0x148DBFAA),
    ],
  );

  static const LinearGradient avD = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x47B9A8D7),
      Color(0x14B9A8D7),
    ],
  );

  static const LinearGradient avE = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x14FFFFFF),
      Color(0x07FFFFFF),
    ],
  );

  // POSTPARTUM BUTTON
  static const LinearGradient primaryBtn = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xCCD496B8),
      Color(0xB378A5DC),
    ],
  );

  // SPEAK FREELY BUTTON
  static const LinearGradient speakFreelyBtn = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xCC89CFF0),
      Color(0xCCFFD8B1),
    ],
  );

  static const Color headerBg = Color(0xB3111620);
  static const Color navBg = Color(0xD90D1117);
  static const Color modalBg = Color(0xF0141A26);

  // Post top border colors
  static const Color postPinkBorder = Color(0x73D4A0B8);
  static const Color postBlueBorder = Color(0x7390B8E0);
  static const Color postSageBorder = Color(0x668DBFAA);
  static const Color postPurpleBorder = Color(0x66B9A8D7);
}