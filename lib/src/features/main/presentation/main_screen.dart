import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/localization/app_text.dart';
import '../../../core/network/offline_status.dart';
import 'package:ios26_bottom_navigationbar/ios26_bottom_navigationbar.dart';

import '../../home/presentation/home_page.dart';
import '../../explore/presentation/explore_page.dart';
import '../../profile/presentation/pages/profile_page.dart';
import '../../tickets/data/tickets_repository.dart';
import '../../tickets/presentation/cubit/tickets_cubit.dart';
import '../../tickets/presentation/pages/tickets_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  // Request the tickets tab without replacing the existing MainScreen route.
  // A counter is used so repeated requests also refresh the tickets.
  static final ValueNotifier<int> _ticketsRequests = ValueNotifier<int>(0);

  static void requestTicketsTab() => _ticketsRequests.value++;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final TicketsCubit _ticketsCubit;

  @override
  void initState() {
    super.initState();
    _ticketsCubit = TicketsCubit(context.read<TicketsRepository>());
    MainScreen._ticketsRequests.addListener(_openTickets);
  }

  void _openTickets() {
    if (!mounted) return;
    setState(() => _selectedIndex = 2);
    _ticketsCubit.refresh();
  }

  @override
  void dispose() {
    MainScreen._ticketsRequests.removeListener(_openTickets);
    _ticketsCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Glass navbar orqasida kontent ko'rinadi
      extendBody: true,

      body: Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: OfflineStatus.offline,
            builder: (context, offline, _) => offline
                ? SafeArea(
                    bottom: false,
                    child: Material(
                      color: isDark
                          ? const Color(0xFF3B3022)
                          : const Color(0xFFFFF2D8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.wifi_off_rounded, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppText.of(context, 'offline_cache_notice'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                const HomePage(),
                const ExplorePage(),
                BlocProvider.value(
                  value: _ticketsCubit,
                  child: const TicketsPage(),
                ),
                const ProfilePage(),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: IOS26BottomNavigationBar(
        currentIndex: _selectedIndex,

        onTap: (newIndex) {
          if (newIndex == 2) _ticketsCubit.refresh();
          setState(() {
            _selectedIndex = newIndex;
          });
        },

        style: isDark
            ? IOS26NavThemeData.dark(
                activeColor: const Color(0xFFB49AFF),
                inactiveColor: const Color(0xFFAAA4B7),
                backgroundColor: const Color(
                  0xFF292533,
                ).withValues(alpha: 0.75),
                indicatorColor: const Color(0xFF7656D6).withValues(alpha: 0.35),
                height: 66,
                borderRadius: BorderRadius.circular(36),
              )
            : IOS26NavThemeData.light(
                activeColor: const Color(0xFF7656D6),
                inactiveColor: const Color(0xFF898397),
                backgroundColor: Colors.white.withValues(alpha: 0.75),
                indicatorColor: const Color(0xFFEEE8FF),
                height: 66,
                borderRadius: BorderRadius.circular(36),
              ),

        items: [
          IOS26NavItem.icon(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: AppText.of(context, 'home'),
          ),
          IOS26NavItem.icon(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore_rounded,
            label: AppText.of(context, 'explore'),
          ),
          IOS26NavItem.icon(
            icon: Icons.confirmation_number_outlined,
            activeIcon: Icons.confirmation_number_rounded,
            label: AppText.of(context, 'tickets'),
          ),
          IOS26NavItem.icon(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: AppText.of(context, 'profile'),
          ),
        ],
      ),
    );
  }
}
