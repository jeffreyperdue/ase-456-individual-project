# 07_messaging_system.md
Petfolio – Messaging System Specification  
LLM-Optimized Format

---

## 1. Purpose
Defines the messaging system between owners and sitters, including:
- Chat thread structure  
- UI behavior  
- Message types  
- Notification integration  
- Persistence across AccessToken expiration  

Messaging should feel lightweight, reliable, and persistent.

---

# 2. Messaging Philosophy

The chat system is designed to:
- Enable seamless communication between an owner and sitter  
- Keep threads persistent (not tied to a single sitter session)  
- Keep UI simple and consistent across platforms  
- Provide hooks for notifications and “recent activity” on Owner Dashboard  

---

# 3. Chat Thread Model

Chosen approach:
### **One unified chat per owner–sitter pair.**

Not per pet.  
Not per access session.  
Not per task.

### Why?
- Avoids splitting conversations
- Ideal for multi-pet households
- Mirrors Microsoft Teams / iMessage behavior where conversation persists

---

# 4. Firestore Structure (Conceptual)

Reference schema (implementation details in Document 10):

/messageThreads/{threadId}
ownerId: "..."
sitterId: "..."
participants: ["ownerId", "sitterId"]
lastMessageAt: Timestamp
lastMessagePreview: "text excerpt..."

/messageThreads/{threadId}/messages/{messageId}
senderId: "..."
timestamp: Timestamp
type: "text" | "photo"
text: "..."
photoUrl: "..."


A thread is uniquely identified by the `(ownerId, sitterId)` pair.

If the codebase uses a different structure, LLMs should re-map these fields accordingly.

---

# 5. Message Types

Supported:
1. **Text Message**
2. **Photo Message**
   - Uploaded to Firebase Storage
   - Linked in Firestore message doc

Future:
- Audio messages
- Inline task links

---

# 6. Chat UI Rules

### Chat List (Recent Threads)
- Ordered by `lastMessageAt`
- Shows:
  - Participant name (owner or sitter)
  - Pet icon next to name (optional)
  - Preview text
  - Time of last message

### Chat Thread UI
- Standard bubble layout
- Timestamp under messages
- “Photo” messages show thumbnail + zoom-on-tap
- Composer with:
  - Text field
  - Photo upload button

### Empty State
If thread has no messages yet:
> “Say hello to get started.”

---

# 7. Notification Integration

Every new message triggers:
1. A Notification record in `/notifications/`
2. Dashboard banner update  
3. Optional push notification (future)

Owner view shows messages as part of “Recent Activity”.

---

# 8. Behavior Across AccessToken Expiration

Chat **must remain available** even after sitter access expires.

- Messages remain visible for both parties
- Thread remains visible in chat list
- New messages allowed  
  (Owners and sitters can still communicate even without active access)

Gradual expiration UX:
- Sitter may see pet card with “Access expired” banner
- Chat remains functional

---

# 9. Edge Cases

### If sitter has never had access to any pet from this owner
Thread should not exist.

### If owner shares access again later  
The same thread is reused.

### If sitter is removed manually  
Chat remains intact.

---

# 10. Implementation Notes for LLMs

- Use Firestore `.snapshots()` for real-time messages  
- Use pagination (limit + startAfter) for long threads  
- Respect existing project folder structure (likely `lib/features/messaging/`)  
- Use Riverpod for message thread providers  
- Ensure Storage upload rules are compatible with message photos

---

# End of Document
