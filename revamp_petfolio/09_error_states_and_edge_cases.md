# 09_error_states_and_edge_cases.md
Petfolio – Error States & Edge Cases  
LLM-Optimized Format

---

## 1. Purpose
Defines standard error messages, fallback behaviors, and conditions that must be gracefully handled by the UI.

This ensures predictable user experience and reduces ambiguity for LLM-based implementation.

---

# 2. QR / Sharing Errors

### **(1) Expired AccessToken**
When sitter scans QR > 48 hours:
Message:
> “This access token has expired.”

Provide:
- Close button
- Option: “Ask owner to resend” (optional)

---

### **(2) Already Caring for Pet**
If sitter already has active access:
> “You are already caring for {petName}.”

---

### **(3) Owner Already Shared to This Sitter**
When owner tries to share to someone already caring:
> “{petName} is already shared with {sitterUserName}.”

---

### **(4) User Email Not Found**
If owner types email that does not match an account:
- Still allow sending
- But display:
> “Invite sent. This user has not yet created an account.”

---

# 3. Sitter Errors

### **(1) No Pets in Sitter View**
Display:
> “No pets yet. Scan a QR code to begin caring for a pet.”

### **(2) Access Expired**
In sitter dashboard:
> “Access expired. Ask the owner to renew.”

Pet remains visible but becomes read-only.

---

# 4. Owner Errors

### **(1) No Pets in Owner View**
> “Add your first pet to get started.”

### **(2) No Notifications**
> “No recent updates from sitters.”

---

# 5. Lost Mode Edge Cases

### **(1) Pet Marked as Lost**
UI must:
- Show red banner
- Replace normal care indicators with “LOST (Active)”

### **(2) Pet Marked as Found**
- Remove red indicators
- Restore normal dashboard state

---

# 6. Messaging Edge Cases

### **(1) Thread With No Messages**
> “Say hello to get started.”

### **(2) Photos Fail to Upload**
> “Photo upload failed. Try again.”

### **(3) Invalid Thread Access**
If user tries to access thread without permission:
> “You do not have access to this conversation.”

---

# 7. Task Engine Edge Cases

### **(1) Sitter Joins Mid-Day**
Do not show past occurrences.  
Do not show missed tasks.

### **(2) Owner Updates Care Plan**
Upcoming tasks update dynamically.  
No backward cleanup required.

### **(3) Network Failure When Completing Task**
- Temporarily mark task as pending  
- Retry automatically with exponential backoff  
- Show snack bar:
  > “Trying to reconnect…”

---

# 8. General App Errors

### **Offline Mode**
> “You’re offline. Some features may not be available.”

Ensure app does not crash when Firestore disconnects.

### **Authentication Failure**
> “Your session expired. Please log in again.”

---

# 9. Developer / LLM Guidance

### Rules:
- All error messages should be user-friendly, not technical
- Avoid exposing Firestore or internal exceptions
- If existing app uses a generic error widget, reuse it
- LLMs should align message styling with the existing theme

---

# End of Document
