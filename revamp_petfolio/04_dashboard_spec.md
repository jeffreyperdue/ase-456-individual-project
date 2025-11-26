# 04_dashboard_spec.md
Petfolio – Dashboard Specification  
LLM-Optimized Format

---

## 1. Purpose
Defines the behavior, structure, and UI rules for the Owner Dashboard, Sitter Dashboard, and the role-switching experience.

This document supports:
- Real-time updates
- Notifications banner behavior
- Pet list presentation
- AccessToken awareness
- Dual-role users

---

# 2. Owner Dashboard Specification

## 2.1 High-Level Purpose
The Owner Dashboard is the primary hub for users who own pets.  
It must prioritize:
1. Pet overview
2. Tasks status (read-only)
3. Notifications (recent sitter activity)
4. Sharing entry points

---

## 2.2 Layout Overview

**Top Section:**  
- App Bar with Role Toggle (Owner | Sitter)

**Main Content (Vertical Scroll):**
1. **Pet List (Primary content)**  
   - Pet cards displayed first (top of screen)
   - Each card shows:
     - Pet photo  
     - Name  
     - Status indicators  
     - “View Profile” button  
     - If sitter active → “Sitter Care Active” badge  

2. **Notifications Banner**
   - Below pet list
   - Shows **most recent 3 notifications**
   - “View All” link
   - Clicking notification opens relevant detail (task, note, photo, chat)

---

## 2.3 Pet Card Behavior
Each **Pet Card** includes:

### Info:
- Pet name
- Species icon
- Photo (circle or rounded square)
- “Care Status” (active sitter, lost mode, normal)

### Badges:
- **Active Sitter**
- **Lost Mode**
- **Tasks Happening Today** count (optional future)

### Actions:
- Tap: opens Pet Details
- Overflow menu: “Share Pet”, “Edit Profile”, “View Care Plan”

---

## 2.4 Notifications Banner

### Contains:
- Last 3 events where `authorRole == sitter`
- Event types:
  - Task completed
  - Note added
  - Photo added
  - Chat message

### Display:
- Compact list
- Tapping expands the detail view
- “View All” link → Notification Center (future)

### Behavior:
If no notifications:
> “No recent updates from sitters”

---

## 2.5 Empty State Rules

### **If user has no pets**
Show:
- Pet illustration
- Text:  
  > “Add your first pet to get started.”
- Button: “Add Pet”

### **If user has pets but no sitter activity**
- Pet list is shown normally
- Notifications banner shows:
  > “No recent sitter updates.”

---

# 3. Sitter Dashboard Specification

## 3.1 Purpose
For users currently sitting for pets.  
Must highlight:
- Pets being cared for
- Pending QR invitations
- Today’s tasks (future enhancement)
- Notes/photos the sitter may want to review

---

## 3.2 Layout Overview

**Top Section:**  
- App Bar with Role Toggle

**Main Content:**
1. **Pending Access Tokens Banner**  
   - If user has tokens not yet accepted  
   > “You have pending invitations. Tap to accept.”

2. **Pet List (as sitter)**  
   Each card shows:
   - Pet name  
   - Owner name  
   - Today's upcoming tasks  
   - “Go to Task List” action  

3. **Optional:**  
   If sitter has no pets:  
   > “Scan a QR code to begin caring for a pet.”

---

## 3.3 Pet Card Behavior (Sitter)
Each card includes:

- Pet photo  
- Pet name  
- Owner display name  
- “View Care Plan” button  
- “Open Tasks” button  

Should not include:
- Edit pet  
- Edit plan  
- Share pet  

---

# 4. Dual Role Behavior on Dashboard

## 4.1 Role Toggle (Top App Bar)
Two buttons:
- **Owner View**
- **Sitter View**

Users may freely toggle at any time.

---

## 4.2 Dynamic Behavior
- Dashboard content re-renders immediately on toggle
- No navigation change unless routes differ
- Shared global `roleProvider` (Riverpod) updates UI

---

## 4.3 Auto-Prompt
If user has pending sitter invites and is in Owner View:
Show banner:
> “You have sitter invitations waiting. Switch to Sitter View?”

---

# 5. Additional Behaviors

## 5.1 Lost Mode Indicator
If pet is marked lost:
- Pet card gets red outline
- Additional badge:
  > “LOST (Active)”

## 5.2 Active Sitter Indicator
Owner Dashboard shows:
- Badge: “Sitter Active”
- Badge color: green/secondary

---

# 6. Implementation Notes for LLMs
- Match existing theme and spacing rules
- Use Riverpod for dashboard state providers (`ownerDashboardProvider`, `sitterDashboardProvider`)
- If existing code uses `AsyncValue`, preserve pattern
- Use `.snapshots()` for real-time Firestore updates

---

# End of Document
