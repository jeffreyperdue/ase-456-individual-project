# 01_system_overview.md
Petfolio – System Overview  
LLM-Optimized Specification (Modular Document Set)

---

## 1. Purpose of This Document
This document provides a high-level overview of the Petfolio application, its goals, user roles, and architecture assumptions. It sets the foundation for all other modules in this specification set.

The specification is intentionally written to be:
- Unambiguous  
- Modular  
- Flexible for future updates  
- Safe for LLM-based implementation  
- Compatible with existing/unknown portions of the codebase  

LLMs should *always* check existing project structure under `lib/` before applying changes.

---

## 2. Product Description
**Petfolio** is a cross-platform Flutter application that enables pet owners, co-caretakers, and pet sitters to coordinate pet care in real time.  
It features:
- Pet profiles  
- Care plans  
- Task schedules & real-time updates  
- Sitter handoff via QR  
- Messaging  
- Lightweight notification system  
- Dual-role support (Owner & Sitter)

---

## 3. High-Level User Roles

### **Owner**
- Creates and manages pets
- Sets care plan and schedules
- Shares pet access via QR
- Receives real-time task updates
- Views sitter notes/photos
- Chats with sitters

### **Sitter**
- Accepts pet-care invitations (QR only)
- Views care plans and task schedules
- Completes tasks & adds notes/photos
- Chats with owners
- Does not edit pet profiles or plans
- Access is temporary, controlled by owner

### **Dual-role Users**
Users may be both owners and sitters.
- They can toggle roles via the **Top App Bar Role Toggle**
- The app auto-detects when sitter access is active
- Both dashboards are always available

---

## 4. High-Level Architecture Assumptions
These are reference assumptions. If any conflict with the existing codebase, LLMs should adapt but retain required behaviors.

### **Frontend**
- Flutter 3.x
- Riverpod (async + state mgmt)
- go_router (or custom Navigator if still present)
- Modular feature folders under `lib/features/`

### **Backend**
- Firebase Auth
- Firestore
- Firebase Storage
- Local notifications (flutter_local_notifications)
- Optional: FCM push (future)

### **Firestore Collections (Reference Only)**
Actual schemas provided in Document 10.

Typical collections:
- `/users`
- `/pets`
- `/carePlans`
- `/accessTokens`
- `/taskOccurrences`
- `/messages`
- `/notifications`

LLMs should confirm the actual structure before writing queries.

---

## 5. Core Value Propositions
- **Real-time sync** between owners and sitters
- **Simple, secure handoff** via expiring QR code
- **Unified chat** for communication
- **Clear care plans** and checklists
- **Lightweight notifications** that highlight sitter activity
- **Dual-role support** with seamless switching

---

## 6. High-Level Feature Areas (Modules)
Each module is documented separately:
1. Role System (02_role_system_spec.md)  
2. Onboarding Flows (03_onboarding_flows.md)  
3. Dashboards (04_dashboard_spec.md)  
4. Care Plan + Task Engine (05_care_plan_and_task_engine.md)  
5. Sharing & Access Tokens (06_sharing_and_access_token.md)  
6. Messaging System (07_messaging_system.md)  
7. Notifications (08_notification_system.md)  
8. Error States (09_error_states_and_edge_cases.md)  
9. Firestore Templates (10_firestore_schemas_and_json_references.md)  
10. Provider Templates (11_riverpod_provider_templates.md)  
11. LLM Implementation Guide (12_llm_implementation_guidelines.md)

---

## 7. Terminology
- **Owner**: The person who manages the pet
- **Sitter**: Temporary caretaker
- **AccessToken**: Temporary permission record linking sitter to pet
- **TaskOccurrence**: Concrete scheduled item (e.g., "Feed at 6 PM")
- **Care Plan**: The set of routines, feeding schedules, medications
- **Pet Card**: UI unit for pet overview
- **Notification Event**: Any activity authored by sitter
- **Chat Thread**: Messaging channel between an owner–sitter pair

---

## 8. LLM Adaptation Notes
Before generating code:
1. Identify existing folder structures under `lib/features/`
2. Identify existing Firestore collections
3. Identify any existing providers or services to avoid duplication
4. When differing schema is found, use provided schemas as reference to adjust correctly
5. Avoid destructive edits. Prefer extension over modification.

---

## 9. End of Document
This document provides the background necessary to understand the remaining specifications.

