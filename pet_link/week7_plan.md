🗓 Week 7 Plan – Petfolio (Navigation & Information Architecture)

Sprint 2 Theme: UX Foundation → Multi-Section Navigation
Duration: ~6 hours

🎯 Week 7 Objectives

Create missing Care and Profile sections to support 3-tab navigation.

Build a unified bottom-navigation system linking Pets, Care, and Profile sections.

Ensure consistent navigation structure across all major app routes.

Add visual indicators (active tab highlight, icon color changes, labels).

Implement basic navigation using existing MaterialApp routing (go_router deferred to future).

Maintain the onboarding state flow so new vs returning users still route correctly.

🧱 Features & User Stories

| Feature | Epic | User Stories | Status |
|---------|------|--------------|--------|
| Feature 2A: Care Section Creation | Navigation & IA | US-004 & US-005 | 🟡 Planned for Week 7 |
| Feature 2B: Profile Section Creation | Navigation & IA | US-004 & US-005 | 🟡 Planned for Week 7 |
| Feature 2C: Bottom Navigation System | Navigation & IA | US-004 & US-005 | 🟡 Planned for Week 7 |

**US-004**: As a user, I want clear navigation between different app sections so that I can easily find what I'm looking for.

**US-005**: As a user, I want to see which section I'm currently in so that I don't get lost in the app.

**Acceptance Criteria**
- [ ] Care section page with care plan dashboard and task management
- [ ] Profile section page with user settings and account management  
- [ ] Bottom navigation bar with 3 tabs (Pets, Care, Profile)
- [ ] Active tab highlight (color + icon change + label)
- [ ] Each tab loads its respective view without state loss
- [ ] Navigation state persists when returning to the app
- [ ] Works with AppStartup onboarding logic and existing MaterialApp routing

⚙️ Technical Implementation Plan

**Phase 1: Create Missing Sections (2 hours)**

1. **Care Section Page**
   - Create `lib/features/care_plans/presentation/pages/care_dashboard_page.dart`
   - Integrate existing `CarePlanDashboard` widget
   - Add task management and care plan overview
   - Include navigation to individual pet care plans

2. **Profile Section Page**  
   - Create `lib/features/auth/presentation/pages/profile_page.dart`
   - Display user information (name, email, photo)
   - Add account settings and preferences
   - Include sign out functionality (moved from HomePage)

**Phase 2: Navigation Infrastructure (2 hours)**

3. **Navigation State Management**
   ```dart
   // Create lib/app/navigation_provider.dart
   final navIndexProvider = StateNotifierProvider<NavIndexNotifier, int>((ref) {
     return NavIndexNotifier();
   });
   
   class NavIndexNotifier extends StateNotifier<int> {
     NavIndexNotifier() : super(0);
     
     void setIndex(int index) {
       state = index;
     }
   }
   ```

4. **Main Navigation Scaffold**
   ```dart
   // Create lib/app/main_scaffold.dart
   class MainScaffold extends ConsumerWidget {
     final Widget child;
     const MainScaffold({required this.child});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final currentIndex = ref.watch(navIndexProvider);
       return Scaffold(
         body: child,
         bottomNavigationBar: NavigationBar(
           currentIndex: currentIndex,
           onDestinationSelected: (i) => ref.read(navIndexProvider.notifier).setIndex(i),
           destinations: const [
             NavigationDestination(icon: Icon(Icons.pets), label: 'Pets'),
             NavigationDestination(icon: Icon(Icons.favorite), label: 'Care'),
             NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
           ],
         ),
       );
     }
   }
   ```

**Phase 3: Route Integration (1.5 hours)**

5. **Update App Routes**
   - Add `/care` and `/profile` routes to `app.dart`
   - Wrap existing HomePage with MainScaffold
   - Create route handlers for tab navigation
   - Preserve existing onboarding flow

6. **Navigation Logic**
   - Implement tab switching without page reload
   - Maintain state across tab switches
   - Handle deep linking to specific tabs

**Phase 4: UI Polish & Testing (0.5 hours)**

7. **UI Enhancements**
   - Use Material 3 NavigationBar for modern look
   - Match existing Petfolio theme colors
   - Add smooth transitions between tabs
   - Ensure responsive design

8. **Testing & Validation**
   - Test onboarding → Dashboard flow
   - Verify tab switching works correctly
   - Test on Android and Web platforms
   - Validate state persistence

🧪 Validation Path

1. **Onboarding Flow**: Launch app → complete onboarding → land on Dashboard with bottom navigation
2. **Tab Navigation**: Tap each tab → view switches instantly with active indicator
3. **State Persistence**: Close and reopen app → returns to last selected tab
4. **Returning Users**: Verify onboarding flags still bypass Welcome flow for returning users
5. **Deep Linking**: Test direct navigation to `/care` and `/profile` routes

🚧 Dependencies & Risks

**Dependencies:**
- ✅ Completed Week 6 onboarding (AppStartup & state flags)
- ✅ Existing CarePlanDashboard widget
- ✅ User authentication and profile data

**Risks:**
- **Missing Sections**: Care and Profile pages don't exist yet
- **State Management**: Tab state persistence across app restarts
- **Route Conflicts**: Integration with existing MaterialApp routing

**Mitigations:**
- Create Care and Profile pages as first priority
- Use SharedPreferences for tab state persistence
- Keep onboarding routes separate from tab navigation
- Test cold-start flows thoroughly

📊 Success Metrics

| Metric | Target |
|--------|--------|
| Navigation latency | < 250 ms between tabs |
| App startup to dashboard | < 3 s |
| Visual consistency | All tabs use shared theme |
| Usability | Users can intuitively find Pets, Care, and Profile without training |
| State persistence | Last selected tab remembered across app restarts |

📋 Implementation Checklist

**Phase 1: Missing Sections**
- [ ] Create `CareDashboardPage` with existing care plan functionality
- [ ] Create `ProfilePage` with user info and settings
- [ ] Move sign out functionality from HomePage to ProfilePage

**Phase 2: Navigation Infrastructure**  
- [ ] Create `navigation_provider.dart` with Riverpod state management
- [ ] Create `MainScaffold` with Material 3 NavigationBar
- [ ] Implement tab switching logic

**Phase 3: Route Integration**
- [ ] Add `/care` and `/profile` routes to `app.dart`
- [ ] Wrap HomePage with MainScaffold
- [ ] Test onboarding flow integration

**Phase 4: Polish & Testing**
- [ ] Apply consistent theming across all tabs
- [ ] Test on Android and Web platforms
- [ ] Validate state persistence
- [ ] Performance testing for smooth transitions