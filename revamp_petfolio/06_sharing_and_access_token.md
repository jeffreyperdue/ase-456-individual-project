# 06_sharing_and_access_token.md
Petfolio – Sharing Flow & AccessToken Specification  
LLM-Optimized Format

---

## 1. Purpose
Defines the core “handoff” mechanic of Petfolio:
- QR sharing
- AccessToken lifecycle
- Expiration countdown
- Acceptance flow
- Error states
- Renewal behavior

---

# 2. Sharing Overview

Owners can share pet access with sitters using a **QR code** that encodes a temporary AccessToken reference.

There is **no link-based sharing** at this stage.

---

# 3. AccessToken Data Model (Conceptual)

Example fields:
{
"id": "auto-id",
"petId": "...",
"grantedBy": "ownerUserId",
"grantedTo": null, // filled after acceptance
"role": "sitter",
"expiresAt": Timestamp,
"status": "pending | active | expired",
"durationHours": 48,
}


Implementation details provided in Document 10.

---

# 4. AccessToken Lifecycle

### **States:**
1. **pending**  
   QR is generated; sitter has not scanned yet.

2. **active**  
   Sitter accepted; sitter now has access to pet.

3. **expired**  
   48 hours passed OR owner revoked token.

---

# 5. QR Code Generation

### Requirements:
- Generated client-side
- Encodes AccessToken ID
- Shows expiration countdown:
  > “Expires in 47h 59m”
- Refreshes locally every minute
- Owner can delete QR/token manually

---

# 6. QR Acceptance Flow

### Sitter scanning QR sees:
- Pet name  
- Owner name  
- Duration  
- “Accept Care” button  

### After acceptance:
- AccessToken.grantedTo = currentUser  
- Status becomes `active`
- Pet appears on Sitter Dashboard

---

# 7. Error Handling

### **Expired Token**
Message:
> “This access token has expired.”

### **Already Caring**
Message:
> “You are already caring for {petName}.”

### **Owner shared to user already**
Message:
> “{petName} is already shared with {userName}.”

### **User does not exist (email search)**
- Allow send  
- Inform sender:
> “This email is not yet registered. Invite sent.”

### **Sitter logs in later**
App prompts acceptance on next login.

---

# 8. Access Expiration Behavior

When AccessToken expires:

### **Owner View**
- Badge on pet card: “Sitter Access Expired”
- Option to renew

### **Sitter View**
Chosen option:
**Pet remains visible**  
With banner:
> “Access expired. Ask the owner to renew.”

Chat remains intact.

Tasks no longer accessible.

---

# 9. Renewal Behavior
Owner may create a new QR token at any time.

---

# 10. Implementation Notes for LLMs
- Check if Firestore security rules already exist for AccessToken; extend rather than overwrite.
- Do not break existing QR logic; adapt to current libraries.
- Use `qr_flutter` unless otherwise required.
- Prefer storing expiration timestamp in UTC.

---

# End of Document
