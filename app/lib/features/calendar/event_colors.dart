import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import 'calendar_repository.dart' show eventColorDefault;

/// Colours an event can have, by the name stored in `events.color`. The first
/// is the default (stored as null). Mangga is left out because bills use it,
/// and Gumamela because it is kept for emergencies and overdue.
const eventColorNames = [eventColorDefault, 'dagat', 'dahon', 'narra', 'rosas', 'tubig'];

/// The colour for a stored name; null for none or a name this app doesn't know.
Color? eventColor(String? name) => switch (name) {
  'ube' => HomeColors.ube,
  'dagat' => HomeColors.dagat,
  'dahon' => HomeColors.dahon,
  'narra' => HomeColors.narra,
  'rosas' => const Color(0xFFB0527A),
  'tubig' => const Color(0xFF2E8A86),
  _ => null,
};

String eventColorLabel(AppLocalizations l10n, String name) => switch (name) {
  'dagat' => l10n.eventColourDagat,
  'dahon' => l10n.eventColourDahon,
  'narra' => l10n.eventColourNarra,
  'rosas' => l10n.eventColourRosas,
  'tubig' => l10n.eventColourTubig,
  _ => l10n.eventColourUbe,
};

/// A light tint of [c] on a card, for the multi-day band; stronger when the
/// bands are stacked and thin.
Color bandTint(Color c, {bool stacked = false}) => Color.lerp(const Color(0xFFFBFCF8), c, stacked ? 0.32 : 0.18)!;
