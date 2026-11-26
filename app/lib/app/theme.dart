import 'package:flutter/material.dart';

/// Palette from the design canvas (see CLAUDE.md).
abstract final class HomeColors {
  static const capiz = Color(0xFFE9EEE7); // background
  static const narra = Color(0xFF2A1E17); // text, primary buttons, bottom bar
  static const dahon = Color(0xFF2F6B3A); // money, home, done
  static const mangga = Color(0xFFF2B630); // due soon, active tab, FAB
  static const dagat = Color(0xFF2B5C8A); // chores, health, vehicles
  static const ube = Color(0xFF5B3F7A); // calendar, inventory
  static const gumamela = Color(0xFFC2332B); // emergencies and overdue only
  static const card = Color(0xFFFBFCF8);
}

const fontFamily = 'BricolageGrotesque';

/// Bricolage Grotesque is a variable font: heavier weights and narrower
/// widths are set with `fontVariations` on the text style.
ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: HomeColors.dahon,
    surface: HomeColors.capiz,
    primary: HomeColors.narra,
    onPrimary: Colors.white,
    secondary: HomeColors.mangga,
    error: HomeColors.gumamela,
  );
  return ThemeData(
    fontFamily: fontFamily,
    colorScheme: scheme,
    scaffoldBackgroundColor: HomeColors.capiz,
    cardTheme: const CardThemeData(
      color: HomeColors.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: HomeColors.narra,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: HomeColors.card,
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14)), borderSide: BorderSide.none),
    ),
    textTheme: const TextTheme(
      // Big figures: heavy, 75% width (design canvas).
      displaySmall: TextStyle(
        fontWeight: FontWeight.w800,
        fontVariations: [FontVariation.weight(800), FontVariation.width(75)],
        color: Colors.white,
        height: 1.05,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w700,
        fontVariations: [FontVariation.weight(700)],
        color: HomeColors.narra,
      ),
    ),
  );
}

/// Solid colour header with one large figure and a one-line caption, used at
/// the top of every screen.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.figure, required this.caption, this.color = HomeColors.narra, this.leading});

  final String figure;
  final String caption;
  final Color color;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      color: color,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?leading,
          Text(figure, style: text.displaySmall),
          const SizedBox(height: 6),
          Text(caption, style: text.bodyLarge?.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}
