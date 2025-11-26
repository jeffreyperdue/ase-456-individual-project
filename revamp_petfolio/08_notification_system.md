# 08_notification_system.md
Petfolio – Notification System Specification  
LLM-Optimized Format

---

## 1. Purpose
Describes how notification events are generated, stored, displayed, and connected to dashboards and messaging.

Notifications are lightweight, local to the app, and highlight sitter activity.

---

# 2. Notification Philosophy

Notifications exist to:
- Keep owners informed of sitter activity  
- Provide a historical trail  
- Surface “recent updates” on the dashboard  
- Support expansion to push notifications later  

---

# 3. Notification Types

### (1) Task Completion
Sitter finishes a scheduled task occurrence.

### (2) Notes
Sitter adds a text note.

### (3) Photos
Sitter uploads a photo.

### (4) Chat Messages
Any incoming message from sitter to owner.

---

# 4. Firestore Representation (Conceptual)

Notifications stored under:
/notifications/{notificationId}
userId: "<owner receiving the notification>"
petId: "..."
eventType: "task" | "note" | "photo" | "chat"
message: "Feed completed at 6 PM"
timestamp: Timestamp
metadata: { ... }


(Not a required structure; used as reference for LLMs.)

Metadata may contain relevant task IDs, photo URLs, or message IDs.

---

# 5. Rendering on Owner Dashboard

Chosen approach:
### **Show top 3 most recent notifications**  
Below the pet list.

Each entry includes:
- Event icon
- Text summary
- Time ago (“5 minutes ago”)
- Tap → opens relevant detail

### “View All” behavior
Opens full notification history (future screen).

---

# 6. No Badges (Current Scope)

The dashboard uses:
- A banner  
- No app icon badges  
- No bottom-nav badge counts (unless future)

---

# 7. Notification Triggers

Triggered when:
- Sitter checks a box  
- Sitter submits a note  
- Sitter uploads a photo  
- Sitter sends a chat message  

### Rules:
- Only notify owners  
- Owners do **not** notify sitters  
- Chat messages notify both parties only if needed (optional future)

---

# 8. Data Retention Rules

- Notifications persist indefinitely  
- Optional: Auto-purge after 6 months (not required yet)

---

# 9. Handling of Deleted Pets

If pet is deleted:
- Notifications remain but may show “(Pet Deleted)”  
- LLMs should check existing code before implementing cleanup routines

---

# 10. Implementation Notes for LLMs

- Use Firestore ordering by `timestamp desc`  
- Use `limit(3)` for dashboard banner  
- Use a dedicated Riverpod provider for notification stream  
- If notification schema differs, adjust reference models accordingly  
- Do not hardcode event messages; generate them using templates

---

# End of Document
