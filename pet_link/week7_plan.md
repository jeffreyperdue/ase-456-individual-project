🗓 Week 7 Plan – Petfolio (Navigation & Information Architecture)

Sprint 2 Theme: UX Foundation → Multi-Section Navigation
Duration: ~4.5 hours

🎯 Week 7 Objectives

Build a unified bottom-navigation system linking Pets, Care, and Profile sections.

Ensure consistent navigation structure across all major app routes.

Add visual indicators (active tab highlight, icon color changes, labels).

Refactor page routing to use go_router for cleaner, declarative navigation.

Maintain the onboarding state flow so new vs returning users still route correctly.

🧱 Features & User Stories
Feature	Epic	User Stories	Status
Feature 2: Bottom Navigation System	Navigation & IA	US-004 & US-005	🟡 Planned for Week 7
US-004

As a user, I want clear navigation between different app sections so that I can easily find what I’m looking for.

US-005

As a user, I want to see which section I’m currently in so that I don’t get lost in the app.

Acceptance Criteria

 Bottom navigation bar with 3 tabs (Pets, Care, Profile)

 Active tab highlight (color + icon change + label)

 Each tab loads its respective view without state loss

 Navigation state persists when returning to the app

 Works with AppStartup onboarding logic and go_router integration

⚙️ Technical Implementation Plan
1. Set up Navigation Scaffold
class MainScaffold extends ConsumerWidget {
  final Widget child;
  const MainScaffold({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => ref.read(navIndexProvider.notifier).setIndex(i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pets'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Care'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

2. Integrate go_router

Define top-level routes for each tab (/pets, /care, /profile).

Preserve onboarding routing inside AppStartup.

Add transitions and named routes for modular navigation.

3. State Management

Add navIndexProvider (Riverpod) to sync UI state with router path.

Keep independent scroll positions and form state per tab.

4. UI Enhancements

Use Flutter’s NavigationBar (Material 3) for a modern feel with shadows and animations.

Match existing Petfolio theme (colors, icon tone from Welcome View).

Add slide/fade transitions between tabs for visual continuity.

5. Testing & Validation

Verify onboarding → Dashboard routes still work.

Confirm active tab highlight updates correctly.

Test platform compatibility (Android, Web).

Add unit/widget tests for MainScaffold and navIndexProvider.

🧪 Validation Path

Launch app → complete onboarding → land on Dashboard.

Tap each tab → view switches instantly with active indicator.

Close and reopen app → returns to last tab.

Verify onboarding flags still bypass Welcome flow for returning users.

🚧 Dependencies & Risks

Depends on: Completed Week 6 onboarding (AppStartup & state flags).

Risk: Routing conflicts between onboarding and go_router navigation.

Mitigation: Keep onboarding routes separate from tab navigation; test cold-start flows thoroughly.

📊 Success Metrics
Metric	Target
Navigation latency	< 250 ms between tabs
App startup to dashboard	< 3 s
Visual consistency	All tabs use shared theme
Usability	Users can intuitively find Pets, Care, and Profile without training