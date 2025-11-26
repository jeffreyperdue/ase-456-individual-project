# 02_role_system_spec.md
Petfolio – Role System Specification  
LLM-Optimized Format

---

## 1. Purpose
This document defines how user roles (Owner and Sitter) behave, how dual-role users switch context, and how the UI adapts to role changes.

---

## 2. Defined Roles

### **Owner Role**
Owners can:
- Create/edit pets
- Create/edit care plans
- Share pet access (QR)
- View sitter progress in real time
- Receive notifications
- Chat with sitters

Cannot:
- Complete tasks (except in emergency scenarios — scope-limited)

---

### **Sitter Role**
Sitters can:
- Accept access tokens via QR
- View pet profiles (read-only)
- View care plans
- Complete scheduled tasks
- Add notes/photos to tasks
- Chat with owners

Cannot:
- Edit pets
- Edit care plans
- Share access onwards
- Modify schedules

---

## 3. Dual Role Behavior
A user may have:
- Their own pets  
- Pets shared with them as a sitter  

Both roles must be accessible at all times.

---

## 4. Role Switching

### **Primary Interaction**
A **Top App Bar toggle** with two states:
- **Owner View**
- **Sitter View**

### Requirements
- Always visible in top layout of the app (unless full-screen modals)
- Switches immediately without requiring reload
- Changes dashboard data source accordingly

### State Rules
- When in **Owner View**:
  - Show owned pets
  - Show owner dashboard
  - Allow pet creation

- When in **Sitter View**:
  - Show all pets the user is currently caring for
  - Show sitter dashboard
  - No editing tools visible

### Auto-Detection Rule
If user has **active AccessTokens**, the app may:
- Prompt: “You have active sitter tasks. Switch to Sitter View?”

But should **never override the user's chosen role**.

---

## 5. Role-Specific Routing
Optional implementation recommendation:
- Owners start at `/owner/dashboard`
- Sitters start at `/sitter/dashboard`
- Role toggle updates global router state

LLMs should check if go_router is already implemented.

---

## 6. Role Persistence
When user toggles roles:
- Save last chosen role in SharedPreferences
- Restore on next app launch

This ensures a predictable UX.

---

## 7. Edge Cases

### **User has no pets and no sitter access**
- Owner dashboard shows: “Add your first pet”
- Sitter dashboard shows: “Scan QR to begin caring for a pet”

### **User has pets but role set to Sitter**
Show a banner:
> “You are viewing the Sitter Dashboard. Switch to Owner View to manage your pets.”

### **User has sitter access but role set to Owner**
No restrictions. Owners can manage their own pets while also sitting for others.

---

## 8. Implementation Flexibility for LLMs
- If the app currently uses a bottom navigation bar that conflicts with a top toggle, LLMs may integrate toggle into AppBar actions or profile drawer.  
- Role state should be held in a global provider (`roleProvider`) and subscribed to across dashboards.
- LLMs should not break existing routing; they should extend it.

---

## 9. End of Document
This completes the role system logic that other modules will depend on.
