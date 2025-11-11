# Manual Testing Guide: Real-Time Task Synchronization

This guide walks you through testing the real-time task synchronization feature on web.

## Prerequisites

1. **Firebase Project Setup**
   - Ensure Firebase is configured with Firestore enabled
   - Firestore security rules allow read/write access (for testing)
   - Firebase Authentication enabled

2. **Flutter Web Setup**
   - Flutter SDK installed
   - Chrome browser installed

## Step 1: Run the App on Web

### Start the Development Server

```bash
# Navigate to project directory
cd pet_link

# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome
```

The app will open in Chrome at `http://localhost:XXXX` (port number varies, typically 53777 or similar).

**Alternative: Run in Release Mode (Faster)**
```bash
flutter run -d chrome --release
```

**Note**: For web testing, you may need to enable web support:
```bash
flutter config --enable-web
```

## Step 2: Set Up Test Accounts

You'll need **two browser windows/tabs** to simulate owner and sitter:

### Window 1: Owner Account
1. Open the app in Chrome (or refresh if already open)
2. If not signed in, click "Sign Up" or "Login"
3. Sign up/Login as **Owner**:
   - Email: `owner@test.com`
   - Password: `test123456` (minimum 6 characters)
4. After login, you'll see the HomePage with pet list
5. Keep this window open

### Window 2: Sitter Account
1. Open a **new Chrome window** (or use incognito mode: Ctrl+Shift+N)
2. Navigate to the same URL: `http://localhost:XXXX` (same port as Window 1)
3. Sign up/Login as **Sitter**:
   - Email: `sitter@test.com`
   - Password: `test123456`
4. Keep this window open

**Tip**: 
- Use Chrome's "New Window" (Ctrl+N) or "New Incognito Window" (Ctrl+Shift+N)
- This allows you to have both accounts open simultaneously
- Each window maintains separate authentication state

## Step 3: Owner Creates Pet and Care Plan

### In Owner Window:

1. **Create a Pet**
   - On the HomePage (Pets tab), click the **+** (FAB) button in the bottom right
   - This opens the EditPetPage
   - Fill in pet details:
     - **Name**: `Test Pet` (required)
     - **Species**: Select from dropdown (e.g., `Dog`)
     - **Breed**: Optional (e.g., `Golden Retriever`)
     - **Photo**: Optional (click to add)
   - Click **"Save"** button
   - Pet should appear in the pet list on HomePage

2. **View Pet Details**
   - Click on the pet card (or click the info icon) to open PetDetailPage
   - You should see:
     - Pet information card
     - Enhanced Profile section
     - Care Plan section
     - Quick Actions section

3. **Create a Care Plan**
   - On PetDetailPage, scroll to "Care Plan" section
   - If no care plan exists, click **"Create Care Plan"** button
   - This opens CarePlanFormPage
   - Fill in care plan details:
     - **Feeding Schedule**: 
       - Click "Add Feeding Schedule"
       - Time: `8:00 AM`
       - Amount: `1 cup`
       - Label: `Morning Feeding`
       - Add multiple times if needed
     - **Medication** (optional):
       - Click "Add Medication"
       - Name: `Heartworm Prevention`
       - Times: `6:00 PM`
       - Dosage: `1 tablet`
       - Instructions: Optional
   - Click **"Save"** to save the care plan
   - You'll be returned to PetDetailPage

4. **View Tasks**
   - On PetDetailPage, in the "Quick Actions" section
   - Click **"View Tasks"** card
   - This opens CarePlanViewPage
   - You should see tasks generated from the care plan:
     - Tasks organized by: Overdue, Due Soon, Today, Upcoming
     - Each task shows:
       - Title (e.g., "Morning Feeding")
       - Description
       - Scheduled time
       - Status (pending - no checkmark yet)

**Alternative Path to View Tasks:**
- From HomePage, click the **Care** tab (bottom navigation, heart icon)
- This shows CarePlanDashboard with overview of all pets' care plans
- Click on a pet's care plan to view details

## Step 4: Owner Shares Pet with Sitter

### In Owner Window:

1. **Navigate to Share Pet Page**
   - **Method 1**: From HomePage
     - Find the pet in the list
     - Click the **share icon** (📤) button on the pet card
     - This opens SharePetPage
   - **Method 2**: Direct navigation (if you know the route)
     - This is not directly accessible from PetDetailPage in current UI

2. **Create Sitter Access Token**
   - On SharePetPage, you'll see:
     - Pet info header at the top
     - "Create New Handoff" form
     - "Active Handoffs" section (empty initially)
   - In the "Create New Handoff" form:
     - **Access Level**: Select **"Sitter"** (not "Viewer")
       - Sitter: Can view pet info, care plan, and complete tasks
       - Viewer: Can only view pet info and care plan (no tasks)
     - **Expiration Date**: Click to set date (default: 7 days from now)
     - **Recipient User ID**: Optional - leave empty for now
       - If you know the sitter's Firebase user ID, you can enter it here
       - This links the token to a specific user
     - **Contact Information**: Optional
     - **Notes**: Optional (e.g., `Test handoff for real-time testing`)
   - Click **"Create Handoff"** button
   - You should see a success message
   - The token will appear in "Active Handoffs" section

3. **Get the Token ID**
   - After creation, the token appears in "Active Handoffs" section
   - **Important**: The token ID is **not directly visible** in the UI card
   - To get the token ID, you have two options:
     - **Option A**: Click **"QR Code"** button on the token card
       - This opens QRCodeDisplayPage
       - The QR code contains the token URL
       - For testing, you'll need to extract the token ID from the URL
     - **Option B**: Check Firebase Console
       - Go to Firestore Database
       - Navigate to `access_tokens` collection
       - Find the token document (filter by `petId`)
       - Copy the document ID (this is the token ID)

4. **Construct the Public Profile URL**
   - The public profile page route is: `/public-profile`
   - However, Flutter web routing uses `onGenerateRoute` with arguments
   - **For manual testing**, you'll need to:
     - Use the token ID to navigate programmatically, OR
     - **Better approach**: Use the Sitter Dashboard (see Step 5)

## Step 5: Sitter Accesses Pet Profile

### In Sitter Window:

**Important Note**: The current implementation has two ways for sitters to access pets:

### Method 1: Sitter Dashboard (Recommended for Testing)

1. **Navigate to Sitter Dashboard**
   - In the browser address bar, manually type:
     - `http://localhost:XXXX/sitter-dashboard`
     - Replace `XXXX` with your actual port number
   - OR use browser navigation if you have the URL saved
   - **Note**: There's no UI button to navigate to sitter dashboard from the main app
   - The sitter dashboard requires authentication (AuthWrapper)

2. **What You Should See**
   - If the sitter has active tokens:
     - Welcome section with pet count
     - List of assigned pets (grouped by token)
     - Each pet shows:
       - Pet name and photo (if available)
       - Species and breed
       - Upcoming tasks for that pet
       - "View Pet Profile" button (eye icon)
   - If no tokens assigned:
     - "No assigned pets" message
     - "You don't have any active pet sitting assignments"

3. **View Pet Profile from Dashboard**
   - Click the **"View Pet Profile"** button (eye icon) on a pet card
   - This opens PublicPetProfilePage with the token
   - You should see:
     - Pet information (read-only)
     - Care plan details (feeding schedules, medications)
     - **Tasks section** (if sitter role) with:
       - List of incomplete tasks
       - "Mark Complete" buttons on each task

### Method 2: Public Profile via Token (Advanced)

**Note**: This method requires manual URL construction or QR code scanning.

1. **Get Token ID** (from Owner window or Firebase Console)
2. **Navigate to Public Profile**
   - The route `/public-profile` requires arguments passed via navigation
   - For web testing, you may need to:
     - Use browser DevTools to trigger navigation programmatically
     - Or modify the app temporarily to accept URL parameters
   - **Current Limitation**: Flutter web doesn't automatically parse URL query parameters for `onGenerateRoute`

**Workaround for Testing:**
- Use the Sitter Dashboard method (Method 1) instead
- Or scan the QR code if testing on mobile device

## Step 6: Test Real-Time Task Completion

### Test Scenario 1: Sitter Completes Task from Public Profile

1. **In Sitter Window:**
   - Navigate to Sitter Dashboard: `http://localhost:XXXX/sitter-dashboard`
   - Click "View Pet Profile" on a pet card
   - This opens PublicPetProfilePage
   - Scroll to "Care Tasks" section
   - Find a task (e.g., "Morning Feeding")
   - Click **"Mark Complete"** button
   - You should see:
     - Loading indicator (snackbar with "Completing task...")
     - Success message: "[Task Title] marked as complete"
     - Task should disappear from incomplete tasks list
     - Or show as completed with checkmark

2. **In Owner Window:**
   - Navigate to CarePlanViewPage:
     - From HomePage → Click pet card → Click "View Tasks"
     - OR from HomePage → Care tab → Click pet's care plan
   - **Watch the task update in real-time** (no refresh needed!)
   - Within 1-2 seconds, you should see:
     - ✅ Checkmark icon appears
     - Task shows "Completed by sitter@test.com X minutes ago"
     - Task title has strikethrough
     - Text is grayed out
     - Task moves to completed state

### Test Scenario 2: Sitter Completes Task from Dashboard

1. **In Sitter Window:**
   - Stay on Sitter Dashboard (`/sitter-dashboard`)
   - Find a task in the pet's task list
   - Click **"Mark Complete"** button directly from dashboard
   - Task should update immediately

2. **In Owner Window:**
   - Verify the task updates in real-time on CarePlanViewPage
   - Both windows should show the same completion status

### Test Scenario 3: Multiple Tasks

1. **In Sitter Window:**
   - Complete multiple tasks
   - Each completion should show success message
   - Tasks should update immediately

2. **In Owner Window:**
   - All completed tasks should show as completed
   - New completions should appear without refresh
   - Completed tasks should be filtered out of "upcoming" lists

### Test Scenario 4: Multiple Windows

1. **Open Multiple Windows:**
   - Window 1: Owner (CarePlanViewPage)
   - Window 2: Sitter (PublicPetProfilePage)
   - Window 3: Sitter Dashboard (optional)

2. **Complete Task in One Window:**
   - Complete a task in Window 2 (Sitter)

3. **Verify All Windows Update:**
   - Window 1 (Owner) should update within 1-2 seconds
   - Window 3 (Sitter Dashboard) should update if open
   - No manual refresh needed in any window

## Step 7: Verify Real-Time Updates

### What to Check:

1. **Immediate Updates**
   - Task completion should appear within 1-2 seconds
   - No page refresh needed
   - No manual reload required
   - Updates happen automatically via Firestore streams

2. **Visual Indicators**
   - ✅ Checkmark icon appears on completed tasks
   - Task title has strikethrough decoration
   - Text color is grayed out (reduced opacity)
   - Completion timestamp shows (e.g., "5 minutes ago")
   - Sitter's email/user ID shows as completer
   - Completed tasks are filtered out of "incomplete" lists

3. **Multiple Windows Synchronization**
   - Open 3+ windows with different users/views
   - Complete task in one window
   - All other windows should update simultaneously
   - No conflicts or race conditions

4. **Data Persistence**
   - Refresh the page
   - Completed tasks should still show as completed
   - Completion data persists in Firestore

## Step 8: Test Edge Cases

### Test 1: Expired Token
1. **In Owner Window:**
   - Create a new token with expiration: 1 minute from now
   - Note the token ID

2. **Wait 1 minute**

3. **In Sitter Window:**
   - Try to access pet profile using the expired token
   - Should show "Invalid or expired access token" error
   - Sitter dashboard should not show expired tokens

### Test 2: Viewer Role (No Task Access)
1. **In Owner Window:**
   - Create a new token with **Viewer** role (not Sitter)
   - Note the token ID

2. **In Sitter Window:**
   - Access pet profile using viewer token
   - Should see:
     - Pet information (read-only)
     - Care plan details (read-only)
     - **Should NOT see tasks section**
     - **Should NOT see "Mark Complete" buttons**

### Test 3: Network Interruption
1. **Complete a task** in Sitter window
2. **Disconnect internet** (turn off WiFi or unplug Ethernet)
3. **Wait a few seconds**
4. **Reconnect internet**
5. **Verify:**
   - Task completion should sync when connection restored
   - Completion should appear in Owner window
   - No data loss

### Test 4: Sitter Not Signed In
1. **In Sitter Window:**
   - Sign out
   - Try to access Sitter Dashboard: `/sitter-dashboard`
   - Should redirect to login page (AuthWrapper)

2. **Try to complete task without signing in:**
   - Should show error or require login
   - PublicPetProfilePage may work without login, but task completion requires authentication

### Test 5: Token Linked to Specific User
1. **In Owner Window:**
   - Create token with **Recipient User ID** field filled
   - Enter the sitter's Firebase user ID
   - Save token

2. **In Sitter Window:**
   - Sign in as the linked sitter
   - Sitter Dashboard should show the pet
   - Token should be associated with this user

3. **Sign in as different user:**
   - Sitter Dashboard should NOT show the pet
   - Token is only accessible by the linked user

## Step 9: Verify Firestore Data

### Check Task Completions in Firebase Console:

1. **Open Firebase Console**
   - Go to: https://console.firebase.google.com
   - Select your Firebase project
   - Navigate to **Firestore Database**

2. **Check Collections:**

   **`task_completions` collection:**
   - Should see documents with structure:
     - `id`: Completion ID (auto-generated)
     - `petId`: Pet ID
     - `careTaskId`: Task ID
     - `completedBy`: Sitter's Firebase user ID
     - `completedAt`: Timestamp (Firestore Timestamp)
     - `notes`: Optional notes (may be null)
     - `additionalData`: Optional map (may be null)

   **`access_tokens` collection:**
   - Should see token documents with:
     - `id`: Token ID
     - `petId`: Pet ID
     - `role`: "sitter" or "viewer"
     - `grantedBy`: Owner's user ID
     - `grantedTo`: Sitter's user ID (may be null)
     - `expiresAt`: Expiration timestamp
     - `isValid`: Boolean
     - `isActive`: Boolean

3. **Verify Real-Time Updates**
   - Complete a task in the app
   - Watch Firestore console (refresh if needed)
   - New document should appear in `task_completions` collection immediately
   - Document should have correct structure and data

4. **Check Timestamps**
   - `completedAt` should be recent (within seconds)
   - `expiresAt` should be in the future (for active tokens)

## Troubleshooting

### Issue: Tasks Not Updating in Real-Time

**Symptoms:**
- Task completion doesn't appear in Owner window
- Updates only show after manual refresh
- Multiple windows show different states

**Solutions:**
1. **Check browser console for errors:**
   - Press F12 to open DevTools
   - Go to Console tab
   - Look for Firestore errors or network errors
   - Common errors: Permission denied, Network error

2. **Verify Firestore security rules:**
   - Go to Firebase Console → Firestore Database → Rules
   - Ensure rules allow read/write for authenticated users
   - For testing, you can temporarily use:
     ```javascript
     match /task_completions/{completionId} {
       allow read, write: if request.auth != null;
     }
     ```

3. **Check network tab:**
   - In DevTools, go to Network tab
   - Filter by "firestore" or "googleapis"
   - Look for failed requests (red status)
   - Check if WebSocket connections are established

4. **Verify Firebase connection:**
   - Check if Firebase is initialized correctly
   - Verify `firebase_options.dart` exists and is correct
   - Check browser console for Firebase initialization errors

5. **Try refreshing both windows:**
   - Sometimes streams need to be re-established
   - Refresh both Owner and Sitter windows
   - Complete a task again

### Issue: "Invalid access token"

**Symptoms:**
- Sitter can't access pet profile
- Error message: "Invalid or expired access token"
- Sitter dashboard shows "No assigned pets"

**Solutions:**
1. **Check token expiration:**
   - Go to Firebase Console → Firestore → `access_tokens`
   - Find the token document
   - Check `expiresAt` field
   - Verify it's in the future

2. **Verify token ID is correct:**
   - Double-check the token ID you're using
   - Token ID should match the document ID in Firestore
   - No typos or extra characters

3. **Check token validity:**
   - In Firestore, check `isValid` field is `true`
   - Check `isActive` field is `true`
   - Verify `petId` matches the pet you're trying to access

4. **Verify token exists:**
   - Check `access_tokens` collection in Firestore
   - Ensure token document exists
   - Check for any Firestore errors in console

### Issue: Sitter Can't See Tasks

**Symptoms:**
- Sitter can see pet info and care plan
- But no tasks section appears
- No "Mark Complete" buttons

**Solutions:**
1. **Verify token role is "sitter":**
   - In Firestore, check token's `role` field
   - Should be "sitter" (not "viewer")
   - Viewer role doesn't show tasks

2. **Check care plan exists:**
   - Verify pet has a care plan in Firestore
   - Check `care_plans` collection
   - Ensure care plan has feeding schedules or medications

3. **Verify tasks were generated:**
   - Tasks are generated from care plan schedules
   - Check if care plan has active schedules
   - Verify tasks exist in Firestore (they're generated on-the-fly)

4. **Check task filters:**
   - Tasks are filtered to show only incomplete tasks
   - Completed tasks are hidden from the list
   - Try completing a task to see if it disappears

### Issue: Task Completion Fails

**Symptoms:**
- Click "Mark Complete" but nothing happens
- Error message appears
- Task doesn't get marked as complete

**Solutions:**
1. **Check sitter is signed in:**
   - Verify sitter is authenticated
   - Check browser console for auth errors
   - Try signing out and signing back in

2. **Verify Firestore write permissions:**
   - Check Firestore security rules
   - Ensure `task_completions` collection allows writes
   - Rules should allow: `allow create: if request.auth != null;`

3. **Check browser console for errors:**
   - Look for specific error messages
   - Common errors: Permission denied, Network error, Validation error
   - Copy error message for debugging

4. **Verify task completion data:**
   - Check if `petId` and `careTaskId` are valid
   - Ensure task exists in the care plan
   - Verify sitter's user ID is correct

5. **Check network connectivity:**
   - Ensure internet connection is stable
   - Check if Firestore is accessible
   - Try completing task again after a few seconds

### Issue: Sitter Dashboard Shows "No assigned pets"

**Symptoms:**
- Sitter dashboard is empty
- Message: "No assigned pets"
- But owner created a token

**Solutions:**
1. **Check token is linked to sitter:**
   - If token has `grantedTo` field, it must match sitter's user ID
   - Verify sitter is signed in with correct account
   - Check sitter's Firebase user ID matches token's `grantedTo`

2. **Verify token is active:**
   - Check token's `isValid` and `isActive` fields
   - Ensure token hasn't expired
   - Verify token's `role` is "sitter"

3. **Check token query:**
   - Sitter dashboard queries tokens where `grantedTo == currentUser.uid`
   - If `grantedTo` is null, token won't appear in dashboard
   - **Solution**: Create token without `grantedTo` field, OR enter sitter's user ID

4. **Verify sitter is signed in:**
   - Ensure sitter is authenticated
   - Check `firebaseUserProvider` is working
   - Try refreshing the page

### Issue: Public Profile URL Doesn't Work

**Symptoms:**
- Can't access public profile via URL
- URL doesn't navigate to profile page
- Error or blank page

**Solutions:**
1. **Current Limitation:**
   - Flutter web routing with `onGenerateRoute` doesn't automatically parse URL query parameters
   - Public profile route requires arguments passed via navigation
   - **Workaround**: Use Sitter Dashboard instead (Method 1 in Step 5)

2. **For Direct URL Access (Advanced):**
   - You would need to implement URL parameter parsing
   - Or use a different routing approach (e.g., `go_router` package)
   - Or modify `app.dart` to handle URL parameters

3. **Alternative Testing Method:**
   - Use Sitter Dashboard: `/sitter-dashboard`
   - Click "View Pet Profile" button
   - This navigates to PublicPetProfilePage with token

## Quick Test Checklist

### Setup
- [ ] App runs on Chrome without errors
- [ ] Owner account created and signed in
- [ ] Sitter account created and signed in
- [ ] Both windows open simultaneously

### Pet and Care Plan
- [ ] Owner can create pet
- [ ] Owner can create care plan
- [ ] Care plan has feeding schedule
- [ ] Tasks are generated from care plan
- [ ] Owner can view tasks on CarePlanViewPage

### Sharing
- [ ] Owner can access SharePetPage (from HomePage share icon)
- [ ] Owner can create sitter access token
- [ ] Token appears in "Active Handoffs" section
- [ ] Token role is set to "sitter"
- [ ] Token ID can be retrieved (from QR code or Firestore)

### Sitter Access
- [ ] Sitter can access Sitter Dashboard (`/sitter-dashboard`)
- [ ] Sitter Dashboard shows assigned pets
- [ ] Sitter can click "View Pet Profile" button
- [ ] PublicPetProfilePage opens with pet info
- [ ] Sitter can see care plan details
- [ ] Sitter can see tasks list (if sitter role)

### Task Completion
- [ ] Sitter can complete tasks from PublicPetProfilePage
- [ ] Sitter can complete tasks from Sitter Dashboard
- [ ] Task completion shows success message
- [ ] Completed tasks disappear from incomplete list
- [ ] Owner sees task completion in real-time (no refresh)
- [ ] Completion appears within 1-2 seconds

### Real-Time Updates
- [ ] Multiple windows update simultaneously
- [ ] No manual refresh needed
- [ ] Updates happen automatically
- [ ] Completed tasks show checkmark
- [ ] Completion shows correct timestamp
- [ ] Completion shows correct sitter email/user ID
- [ ] Completed tasks have visual indicators (strikethrough, grayed out)

### Data Persistence
- [ ] Completed tasks persist after page refresh
- [ ] Task completions saved in Firestore
- [ ] Data structure is correct in Firestore

### Edge Cases
- [ ] Expired tokens show error message
- [ ] Viewer role doesn't show tasks
- [ ] Network interruption doesn't cause data loss
- [ ] Sitter must be signed in to complete tasks

## Tips for Testing

1. **Use Browser DevTools**
   - Press F12 to open DevTools
   - **Console tab**: Check for errors and logs
   - **Network tab**: Monitor Firestore requests
   - Filter by "firestore" to see real-time listeners
   - Look for WebSocket connections (ws://)

2. **Use Multiple Browsers**
   - Chrome for owner
   - Firefox/Edge for sitter
   - Easier to distinguish windows
   - Tests cross-browser compatibility

3. **Check Firestore Console**
   - Monitor data changes in real-time
   - Verify document structure
   - Check timestamps are correct
   - Verify field names match code

4. **Test with Different Scenarios**
   - Multiple pets with different care plans
   - Multiple sitters with different tokens
   - Multiple tasks with different schedules
   - Tasks at different times (past, present, future)

5. **Monitor Performance**
   - Check if updates are truly real-time (1-2 seconds)
   - Verify no excessive Firestore reads
   - Check browser memory usage
   - Monitor network usage

6. **Test Error Handling**
   - Disconnect internet
   - Use invalid token IDs
   - Try expired tokens
   - Test with missing data

## Expected Behavior Summary

✅ **Real-Time Updates**: Changes appear within 1-2 seconds across all windows
✅ **No Refresh Needed**: UI updates automatically via Firestore streams
✅ **Visual Feedback**: Clear indicators for completed vs pending tasks
✅ **Error Handling**: Graceful error messages for failures
✅ **Role-Based Access**: Sitters can complete, viewers cannot
✅ **Data Persistence**: Completions saved to Firestore permanently
✅ **Multi-User Support**: Multiple users can collaborate simultaneously
✅ **Token Security**: Access controlled via tokens with expiration

## Known Limitations & Workarounds

1. **Public Profile URL Access**
   - **Limitation**: Direct URL access with query parameters doesn't work out of the box
   - **Workaround**: Use Sitter Dashboard and click "View Pet Profile" button
   - **Future Improvement**: Implement URL parameter parsing or use `go_router`

2. **Token ID Display**
   - **Limitation**: Token ID is not directly visible in UI
   - **Workaround**: Check Firebase Console or QR code URL
   - **Future Improvement**: Add "Copy Token ID" button to AccessTokenCard

3. **Sitter Dashboard Navigation**
   - **Limitation**: No UI button to navigate to sitter dashboard
   - **Workaround**: Manually type URL: `/sitter-dashboard`
   - **Future Improvement**: Add navigation link in main app

4. **Task Generation**
   - **Limitation**: Tasks are generated on-the-fly, not stored in Firestore
   - **Workaround**: Tasks appear when care plan exists
   - **Future Improvement**: Consider storing tasks in Firestore for better performance

---

## Discrepancies Found & Fixed

### ✅ Fixed Issues:

1. **Share Pet Navigation**: 
   - **Was**: "From PetDetailPage, find 'Share Pet' button"
   - **Actual**: Share Pet is accessed from HomePage via share icon on pet card
   - **Fixed**: Updated guide to reflect actual UI

2. **Care Plan View Navigation**:
   - **Was**: "Navigate to Care tab" (implies direct view)
   - **Actual**: Care tab shows dashboard; tasks are on CarePlanViewPage accessed from PetDetailPage
   - **Fixed**: Clarified navigation path

3. **Public Profile URL**:
   - **Was**: Assumed URL parameters work automatically
   - **Actual**: Flutter web routing requires programmatic navigation
   - **Fixed**: Added workaround using Sitter Dashboard

4. **Token ID Access**:
   - **Was**: "Copy the Token ID" (assumed it's visible)
   - **Actual**: Token ID not directly displayed in UI
   - **Fixed**: Added instructions to get token ID from Firebase Console or QR code

5. **Sitter Dashboard Access**:
   - **Was**: Assumed navigation button exists
   - **Actual**: Must type URL manually
   - **Fixed**: Added clear instructions for manual URL entry

---

**Happy Testing! 🐾**

If you encounter any issues not covered in this guide, check the browser console for error messages and verify Firestore security rules are correctly configured.
