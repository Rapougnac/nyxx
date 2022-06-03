import 'package:nyxx/src/utils/enum.dart';

// All colors got from DiscordColor class from DSharp+.
// https://github.com/DSharpPlus/DSharpPlus/blob/a2f6eca7f5f675e83748b20b957ae8bdb8fd0cab/DSharpPlus/Entities/DiscordColor.Colors.cs

/// Wrapper for colors.
/// Simplifies creation and provides interface to interact with colors for nyxx.
class DiscordColor extends IEnum<int> {
  /// Construct color from int.
  /// It allows to create color from hex number and decimal number
  ///
  /// ```
  /// final color = DiscordColor.fromInt(43563);
  /// final color2 = DiscordColor.fromInt(0xff0044);
  /// ```
  const DiscordColor.fromInt(int value) : super(value);

  /// Construct color from individual color components
  factory DiscordColor.fromRgb(int r, int g, int b) => DiscordColor.fromInt(r << 16 | g << 8 | b);

  /// Construct color from individual color components with doubles
  /// Values should be from 0.0 to 1.0
  factory DiscordColor.fromDouble(double r, double g, double b) {
    final rb = (r * 255).toInt().clamp(0, 255);
    final gb = (g * 255).toInt().clamp(0, 255);
    final bb = (b * 255).toInt().clamp(0, 255);

    return DiscordColor.fromInt(rb << 16 | gb << 8 | bb);
  }

  /// Construct color from hex String.
  /// Leading # will be ignored in process.
  factory DiscordColor.fromHexString(String hexStr) {
    if (hexStr.isEmpty) {
      throw ArgumentError("Hex color String cannot be empty");
    }

    if (hexStr.startsWith("#")) {
      hexStr = hexStr.substring(1);
    }

    return DiscordColor.fromInt(int.parse(hexStr, radix: 16));
  }

  /// Gets the blue component of this color as an integer.
  int get r => (value >> 16) & 0xFF;

  /// Gets the green component of this color as an integer.
  int get g => (value >> 8) & 0xFF;

  /// Gets the blue component of this color as an integer.
  int get b => value & 0xFF;

  @override
  String toString() => asHexString();

  /// Returns
  String asHexString() {
    final buffer = StringBuffer();

    buffer.write("#");
    buffer.write(r.toRadixString(16).padLeft(2, "0"));
    buffer.write(g.toRadixString(16).padLeft(2, "0"));
    buffer.write(b.toRadixString(16).padLeft(2, "0"));

    return buffer.toString().toUpperCase();
  }

  /// Represents no color, or integer 0.
  static const DiscordColor none = DiscordColor.fromInt(0);

  /// A near-black color. Due to API limitations, the color is #010101, rather than #000000, as the latter is treated as no color.
  static const DiscordColor black = DiscordColor.fromInt(0x010101);

  /// White, or #FFFFFF.
  static const DiscordColor white = DiscordColor.fromInt(0xFFFFFF);

  /// Gray, or #808080.
  static const DiscordColor gray = DiscordColor.fromInt(0x808080);

  /// Dark gray, or #A9A9A9.
  static const DiscordColor darkGray = DiscordColor.fromInt(0xA9A9A9);

  /// Light gray, or #808080.
  static const DiscordColor lightGray = DiscordColor.fromInt(0xD3D3D3);

  /// Very dark gray, or #666666.
  static const DiscordColor veryDarkGray = DiscordColor.fromInt(0x666666);

  /// Flutter blue, or #02569B
  static const DiscordColor flutterBlue = DiscordColor.fromInt(0x02569B);

  /// Dart's primary blue color, or #0175C2
  static const DiscordColor dartBlue = DiscordColor.fromInt(0x0175C2);

  ///  Dart's secondary blue color, or #13B9FD
  static const DiscordColor dartSecondary = DiscordColor.fromInt(0x13B9FD);

  /// Discord Blurple, or #7289DA.
  static const DiscordColor blurple = DiscordColor.fromInt(0x7289DA);

  /// Discord Grayple, or #99AAB5.
  static const DiscordColor grayple = DiscordColor.fromInt(0x99AAB5);

  /// Discord Dark, But Not Black, or #2C2F33.
  static const DiscordColor darkButNotBlack = DiscordColor.fromInt(0x2C2F33);

  /// Discord Not QuiteBlack, or #23272A.
  static const DiscordColor notQuiteBlack = DiscordColor.fromInt(0x23272A);

  /// Red, or #FF0000.
  static const DiscordColor red = DiscordColor.fromInt(0xFF0000);

  /// Dark red, or #7F0000.
  static const DiscordColor darkRed = DiscordColor.fromInt(0x7F0000);

  /// Green, or #00FF00.
  static const DiscordColor green = DiscordColor.fromInt(0x00FF00);

  /// Dark green, or #007F00.
  static const DiscordColor darkGreen = DiscordColor.fromInt(0x007F00);

  /// Blue, or #0000FF.
  static const DiscordColor blue = DiscordColor.fromInt(0x0000FF);

  /// Dark blue, or #00007F.
  static const DiscordColor darkBlue = DiscordColor.fromInt(0x00007F);

  /// Yellow, or #FFFF00.
  static const DiscordColor yellow = DiscordColor.fromInt(0xFFFF00);

  /// Cyan, or #00FFFF.
  static const DiscordColor cyan = DiscordColor.fromInt(0x00FFFF);

  /// Magenta, or #FF00FF.
  static const DiscordColor magenta = DiscordColor.fromInt(0xFF00FF);

  /// Teal, or #008080.
  static const DiscordColor teal = DiscordColor.fromInt(0x008080);

  /// Aquamarine, or #00FFBF.
  static const DiscordColor aquamarine = DiscordColor.fromInt(0x00FFBF);

  /// Gold, or #FFD700.
  static const DiscordColor gold = DiscordColor.fromInt(0xFFD700);

  /// Goldenrod, or #DAA520
  static const DiscordColor goldenrod = DiscordColor.fromInt(0xDAA520);

  /// Azure, or #007FFF.
  static const DiscordColor azure = DiscordColor.fromInt(0x007FFF);

  /// Rose, or #FF007F.
  static const DiscordColor rose = DiscordColor.fromInt(0xFF007F);

  /// Spring green, or #00FF7F.
  static const DiscordColor springGreen = DiscordColor.fromInt(0x00FF7F);

  /// Chartreuse, or #7FFF00.
  static const DiscordColor chartreuse = DiscordColor.fromInt(0x7FFF00);

  /// Orange, or #FFA500.
  static const DiscordColor orange = DiscordColor.fromInt(0xFFA500);

  /// Purple, or #800080.
  static const DiscordColor purple = DiscordColor.fromInt(0x800080);

  /// Violet, or #EE82EE.
  static const DiscordColor violet = DiscordColor.fromInt(0xEE82EE);

  /// Brown, or #A52A2A.
  static const DiscordColor brown = DiscordColor.fromInt(0xA52A2A);

  /// Hot pink, or #FF69B4
  static const DiscordColor hotPink = DiscordColor.fromInt(0xFF69B4);

  /// Lilac, or #C8A2C8.
  static const DiscordColor lilac = DiscordColor.fromInt(0xC8A2C8);

  /// Cornflower blue, or #6495ED.
  static const DiscordColor cornflowerBlue = DiscordColor.fromInt(0x6495ED);

  /// Midnight blue, or #191970.
  static const DiscordColor midnightBlue = DiscordColor.fromInt(0x191970);

  /// Wheat, or #F5DEB3.
  static const DiscordColor wheat = DiscordColor.fromInt(0xF5DEB3);

  /// Indian red, or #CD5C5C.
  static const DiscordColor indianRed = DiscordColor.fromInt(0xCD5C5C);

  /// Turquoise, or #30D5C8.
  static const DiscordColor turquoise = DiscordColor.fromInt(0x30D5C8);

  /// Sap green, or #507D2A.
  static const DiscordColor sapGreen = DiscordColor.fromInt(0x507D2A);

  /// Phthalo blue, or #000F89.
  static const DiscordColor phthaloBlue = DiscordColor.fromInt(0x000F89);

  /// Phthalo green, or #123524.
  static const DiscordColor phthaloGreen = DiscordColor.fromInt(0x123524);

  /// Sienna, or #882D17.
  static const DiscordColor sienna = DiscordColor.fromInt(0x882D17);
}
