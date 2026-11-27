import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/app_lock.dart';
import '../core/auth/auth_service.dart';
import '../features/auth/lock_screen.dart';
import '../features/bills/bills_screen.dart';
import '../features/budget/budget_screen.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/chores/chores_screen.dart';
import '../features/debts/debts_screen.dart';
import '../features/auth/profile_picker_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/tablet_pin_screen.dart';
import '../features/home/home_screen.dart';
import '../features/members/members_screen.dart';
import '../features/pantry/grocery_history_screen.dart';
import '../features/pantry/pantry_screen.dart';
import '../features/sync/conflict_inbox_screen.dart';
import '../features/sync/sync_problems_screen.dart';
import '../features/vault/vault_screen.dart';
import '../features/health/health_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/rent/rent_screen.dart';
import '../features/vehicles/vehicles_screen.dart';

abstract final class Routes {
  static const home = '/';
  static const signIn = '/sign-in';
  static const lock = '/lock';
  static const profiles = '/profiles';
  static const conflicts = '/conflicts';
  static const syncProblems = '/sync-problems';
  static const members = '/members';
  static const tabletPin = '/tablet-pin';
  static const pantry = '/pantry';
  static const groceryHistory = '/pantry/history';
  static const budget = '/budget';
  static const bills = '/bills';
  static const chores = '/chores';
  static const calendar = '/calendar';
  static const debts = '/debts';
  static const vault = '/vault';
  static const vehicles = '/vehicles';
  static const rent = '/rent';
  static const inventory = '/inventory';
  static const health = '/health';
}

GoRouter buildRouter({required AuthService auth, required AppLock lock}) => GoRouter(
  refreshListenable: Listenable.merge([auth, lock]),
  redirect: (context, state) {
    final at = state.matchedLocation;
    if (!auth.signedIn) return at == Routes.signIn ? null : Routes.signIn;
    if (lock.locked) return at == Routes.lock ? null : Routes.lock;
    if (auth.needsTabletPin) return at == Routes.tabletPin ? null : Routes.tabletPin;
    if (at == Routes.signIn || at == Routes.lock || at == Routes.tabletPin) return Routes.home;
    return null;
  },
  routes: [
    GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
    GoRoute(path: Routes.signIn, builder: (_, _) => const SignInScreen()),
    GoRoute(path: Routes.lock, builder: (_, _) => const LockScreen()),
    GoRoute(path: Routes.profiles, builder: (_, _) => const ProfilePickerScreen()),
    GoRoute(path: Routes.conflicts, builder: (_, _) => const ConflictInboxScreen()),
    GoRoute(path: Routes.syncProblems, builder: (_, _) => const SyncProblemsScreen()),
    GoRoute(path: Routes.members, builder: (_, _) => const MembersScreen()),
    GoRoute(path: Routes.tabletPin, builder: (_, _) => const TabletPinScreen()),
    GoRoute(path: Routes.pantry, builder: (_, _) => const PantryScreen()),
    GoRoute(path: Routes.groceryHistory, builder: (_, _) => const GroceryHistoryScreen()),
    GoRoute(path: Routes.budget, builder: (_, _) => const BudgetScreen()),
    GoRoute(path: Routes.bills, builder: (_, _) => const BillsScreen()),
    GoRoute(path: Routes.chores, builder: (_, _) => const ChoresScreen()),
    GoRoute(path: Routes.calendar, builder: (_, _) => const CalendarScreen()),
    GoRoute(path: Routes.debts, builder: (_, _) => const DebtsScreen()),
    GoRoute(path: Routes.vault, builder: (_, _) => const VaultScreen()),
    GoRoute(path: Routes.vehicles, builder: (_, _) => const VehiclesScreen()),
    GoRoute(path: Routes.rent, builder: (_, _) => const RentScreen()),
    GoRoute(path: Routes.inventory, builder: (_, _) => const InventoryScreen()),
    GoRoute(path: Routes.health, builder: (_, _) => const HealthScreen()),
  ],
);
