# Week 10 Manual Testing Guide
## Petfolio - UI Polish & Error Handling

This guide provides step-by-step instructions for manually testing all Week 10 improvements.

---

## 🚀 **Setup & Running the App**

### Prerequisites
1. Ensure Flutter is installed and configured
2. Firebase project is set up and connected
3. Have test accounts ready (or create new ones)

### Running the App

```bash
# Navigate to the pet_link directory
cd ase-456-individual-project/pet_link

# Get dependencies
flutter pub get

# Run on your preferred platform
flutter run
# or
flutter run -d chrome  # for web
flutter run -d android # for Android emulator
flutter run -d ios     # for iOS simulator
```

---

## 📋 **Testing Checklist**

### **Phase 1: Error Handling Testing**

#### ✅ **Test 1.1: Authentication Error Messages**

**Login Page Errors:**
1. Go to the login page
2. Try to log in with:
   - **Invalid email** (e.g., "notanemail") → Should show: "Invalid email address. Please check and try again."
   - **Non-existent email** → Should show: "No account found with this email."
   - **Wrong password** → Should show: "Incorrect password. Please try again."
   - **Empty fields** → Should show validation errors before submission

**Sign Up Page Errors:**
1. Go to the sign up page
2. Try to sign up with:
   - **Weak password** (< 6 chars) → Should show: "Password is too weak. Please use at least 6 characters."
   - **Existing email** → Should show: "An account with this email already exists."
   - **Invalid email format** → Should show: "Invalid email address. Please check and try again."

**Expected Result:** All error messages should be user-friendly and actionable (not technical error codes).

---

#### ✅ **Test 1.2: Network Error Handling**

**Simulate Network Errors:**
1. **Disable internet connection** (turn off WiFi/mobile data)
2. Try to:
   - Log in → Should show: "Network error. Please check your internet connection and try again."
   - Create a pet → Should show network error message
   - Save a care plan → Should show network error message
   - Share a pet → Should show network error message

**Expected Result:** Clear network error messages with guidance to check connection.

---

#### ✅ **Test 1.3: Firebase Permission Errors**

**Permission Denied Errors:**
1. Create a pet as one user
2. Try to edit that pet from a different account (without permission)
3. Should show: "You don't have permission to perform this action."

**Expected Result:** Permission errors are clearly communicated.

---

#### ✅ **Test 1.4: Generic Error Handling**

**Unexpected Errors:**
1. Try operations with invalid data
2. Interrupt operations mid-way
3. Check that errors don't show technical stack traces

**Expected Result:** All errors show user-friendly messages like "Something went wrong. Please try again."

---

### **Phase 2: Loading States Testing**

#### ✅ **Test 2.1: Button Loading States**

**During Async Operations:**
1. **Sign In Button:**
   - Enter credentials and click "Sign In"
   - Button should show loading spinner and be disabled
   - Should not allow multiple clicks

2. **Save Pet Button:**
   - Go to Edit Pet page
   - Fill in pet details
   - Click "Save"
   - Button should show loading state with spinner
   - Button should be disabled during save

3. **Save Care Plan Button:**
   - Go to Care Plan form
   - Fill in care plan details
   - Click "Create Care Plan" or "Update Care Plan"
   - Button should show loading state

**Expected Result:** All buttons show consistent loading indicators and are disabled during operations.

---

#### ✅ **Test 2.2: Full Page Loading States**

**Initial Page Loads:**
1. **Home Page:**
   - Log in and navigate to home
   - While pets are loading, should show centered CircularProgressIndicator
   - Should not show blank screen

2. **Pet Detail Page:**
   - Click on a pet from home page
   - While loading pet details, should show loading indicator

3. **Care Plan View:**
   - Open a care plan
   - While loading, should show loading indicator

**Expected Result:** All pages show loading indicators during data fetch, no blank screens.

---

#### ✅ **Test 2.3: Inline Loading States**

**Small Loading Indicators:**
1. Navigate to Share Pet page
2. Click "Create Handoff"
3. Button icon should show small loading spinner
4. Check other inline loading states throughout the app

**Expected Result:** Consistent small loading spinners for inline operations.

---

### **Phase 3: Success Feedback Testing**

#### ✅ **Test 3.1: Success Messages**

**Key Actions Should Show Success:**
1. **Pet Management:**
   - Create a new pet → Should show: "Pet profile created successfully!"
   - Update pet → Should show: "Pet profile updated successfully!"
   - Delete pet → Should show confirmation

2. **Care Plans:**
   - Create care plan → Should show: "Care plan created successfully!"
   - Update care plan → Should show: "Care plan updated successfully!"
   - Delete care plan → Should show: "Care plan deleted successfully"

3. **Authentication:**
   - Sign up successfully → Should show success before navigation
   - Sign in successfully → Should show "Signed in successfully"
   - Password reset email sent → Should show confirmation

4. **Sharing:**
   - Create handoff → Should show: "Handoff created successfully"
   - Delete handoff → Should show: "Handoff deleted successfully"

**Expected Result:** Success messages appear in primary color (blue), auto-dismiss after ~2 seconds.

---

#### ✅ **Test 3.2: Success Animation**

**Optional - If Success Animation is Used:**
1. Complete a major action (save pet, create care plan)
2. Check if success animation appears (fade + scale animation)
3. Should auto-dismiss after 2 seconds

**Expected Result:** Smooth animation provides positive feedback without being intrusive.

---

### **Phase 4: Retry Mechanisms Testing**

#### ✅ **Test 4.1: Error State Retry Buttons**

**Network Errors:**
1. Disable internet
2. Navigate to home page
3. Should show error state with "Retry" button
4. Click "Retry" → Should attempt to reload data
5. Re-enable internet → Retry should succeed

**Expected Result:** All error states provide retry functionality.

---

#### ✅ **Test 4.2: Retry in SnackBars**

**Retry Actions:**
1. Trigger an operation that fails (e.g., upload with no network)
2. Check if error SnackBar has "Retry" action
3. Click "Retry" → Should retry the operation

**Expected Result:** Failed operations offer retry option in error messages.

---

### **Phase 5: Page Transitions Testing**

#### ✅ **Test 5.1: Navigation Transitions**

**If Page Transitions Are Applied:**
1. Navigate between pages:
   - Home → Pet Detail → Should see smooth transition
   - Pet Detail → Edit Pet → Should see transition
   - Share Pet → QR Code → Should see transition

**Expected Result:** Smooth fade/slide transitions between pages (if implemented).

---

#### ✅ **Test 5.2: Content Updates**

**Dynamic Content Changes:**
1. Update pet list (add/remove pet)
2. Complete a task (check if it updates smoothly)
3. Change pet status (lost/found)

**Expected Result:** Content changes animate smoothly (if AnimatedSwitcher is used).

---

### **Phase 6: Consistency Testing**

#### ✅ **Test 6.1: Visual Consistency**

**Check Throughout App:**
1. All loading indicators should have consistent size/color
2. All error messages should use consistent styling
3. All success messages should use consistent styling
4. Button states should be consistent across pages

**Expected Result:** Visual consistency across all screens.

---

#### ✅ **Test 6.2: Theme Consistency**

**Check Theme Colors:**
1. Success messages → Should use primary blue color
2. Error messages → Should use error red color
3. Loading indicators → Should use primary blue color
4. Buttons → Should follow theme consistently

**Expected Result:** All UI elements follow app theme.

---

## 🧪 **Specific Test Scenarios**

### **Scenario 1: Complete Pet Creation Flow**
1. Log in
2. Click "+" button on home page
3. Fill in pet details
4. Click "Save"
5. **Observe:**
   - Button shows loading state
   - Success message appears
   - Pet appears in list

---

### **Scenario 2: Error Recovery Flow**
1. Start creating a pet
2. Disable internet mid-way
3. Try to save
4. **Observe:**
   - Error message appears
   - Retry option available
5. Re-enable internet
6. Click retry or try again
7. **Observe:**
   - Operation succeeds
   - Success message appears

---

### **Scenario 3: Task Completion**
1. Navigate to Care tab
2. Click on a task to complete
3. **Observe:**
   - Loading state during completion
   - Success feedback
   - Task updates in real-time

---

### **Scenario 4: Lost Pet Flow**
1. Go to pet detail page
2. Mark pet as lost
3. Generate poster
4. **Observe:**
   - Loading during poster generation
   - Success/error messages
   - Retry options if upload fails

---

## 🔍 **What to Look For**

### ✅ **Positive Indicators:**
- ✅ Clear, user-friendly error messages
- ✅ Consistent loading indicators
- ✅ Success feedback for all major actions
- ✅ Smooth transitions between states
- ✅ Retry options for failed operations
- ✅ No technical error codes visible to users
- ✅ No blank screens during loading
- ✅ Buttons disabled during operations (prevents double-submission)

### ❌ **Red Flags:**
- ❌ Technical stack traces in error messages
- ❌ Blank screens during loading
- ❌ Inconsistent error message styling
- ❌ Missing loading indicators
- ❌ Buttons allowing multiple clicks during async operations
- ❌ No retry options for recoverable errors
- ❌ Error messages that don't guide users on what to do

---

## 🐛 **Known Issues to Test**

### **Test Edge Cases:**
1. **Rapid clicking:**
   - Click save button multiple times rapidly
   - Should only submit once

2. **Slow network:**
   - Use network throttling in DevTools
   - Verify loading states appear and remain visible

3. **Page navigation during loading:**
   - Start an operation
   - Navigate away
   - Should handle cancellation gracefully

4. **Offline to online transition:**
   - Start offline
   - Perform action (should fail)
   - Go online
   - Retry operation (should succeed)

---

## 📱 **Platform-Specific Testing**

### **Web Testing:**
- Test in Chrome, Firefox, Safari
- Test responsive behavior (resize window)
- Test keyboard navigation

### **Mobile Testing:**
- Test on actual device (not just emulator)
- Test with slow network (cellular data)
- Test orientation changes
- Test with device low on memory

---

## 🔧 **Tools for Testing**

### **Network Simulation:**
```bash
# In Flutter DevTools, use Network tab to throttle connection
# Or use browser DevTools to simulate offline mode
```

### **Error Simulation:**
- Disconnect from internet
- Use invalid credentials
- Try accessing unauthorized resources
- Interrupt operations mid-way

---

## 📊 **Test Results Template**

Use this template to track your testing:

| Test # | Feature | Steps | Expected Result | Actual Result | Status | Notes |
|--------|---------|-------|-----------------|---------------|--------|-------|
| 1 | Login Error | Enter invalid email | User-friendly message | ✅ | Pass | Message clear |
| 2 | Save Button Loading | Click save pet | Shows spinner | ⏳ | Testing | ... |

---

## ✅ **Completion Criteria**

All tests should pass:
- ✅ All error messages are user-friendly
- ✅ All loading states are visible and consistent
- ✅ Success feedback appears for all major actions
- ✅ Retry mechanisms work correctly
- ✅ No technical error codes visible
- ✅ Consistent UI/UX across all pages
- ✅ Smooth transitions (if implemented)
- ✅ App handles network errors gracefully

---

**Testing Status:** 🟡 Ready for Testing  
**Last Updated:** Week 10 Implementation  
**Tested By:** [Your Name]  
**Date:** [Date]

