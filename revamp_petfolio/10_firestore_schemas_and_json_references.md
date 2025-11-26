# 10_firestore_schemas_and_json_references.md
Petfolio – Firestore Schemas & JSON Reference Templates  
LLM-Optimized Format

---

## 1. Purpose
Provides reference Firestore collection schemas and JSON templates.  
These are **guidelines**, not strict requirements.

LLMs should:
- Check the existing Firestore structure
- Adapt these schemas accordingly
- Maintain backward compatibility

All timestamps should ideally be stored as UTC (`Timestamp` objects).

---

# 2. Firestore Collection Overview

Recommended (but flexible) collections:

/users
/pets
/carePlans
/accessTokens
/taskLogs
/messageThreads
/{threadId}/messages
/notifications


If the current codebase uses different names (e.g., `tasks` instead of `taskLogs`), LLM should map accordingly.

---

# 3. Schema Templates

## 3.1 **User Document**

**Collection:** `/users/{userId}`

```json
{
  "id": "string",
  "email": "string",
  "displayName": "string",
  "photoUrl": "string|null",
  "roles": ["owner", "sitter"],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}


Notes for LLMs:

Check if app already stores additional fields (e.g., phone number).

Never remove existing fields; only extend.

3.2 Pet Document

Collection: /pets/{petId}

{
  "id": "string",
  "ownerId": "string",
  "name": "string",
  "species": "string",
  "gender": "string|null",
  "ageYears": 3,
  "weightKg": 12.5,
  "photoUrl": "string|null",
  "isLost": false,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}

Notes:

If existing schema uses DOB rather than age fields, adapt accordingly.

If weight stored as string in current code, preserve format.

3.3 Care Plan Document

Collection: /carePlans/{carePlanId}

{
  "id": "string",
  "petId": "string",
  "dietText": "string|null",
  "feedingSchedule": ["08:00", "18:00"],
  "medications": [
    {
      "name": "Antibiotic",
      "time": "12:00",
      "dosage": "5mg",
      "notes": "With food"
    }
  ],
  "customTasks": [
    {
      "title": "Brush coat",
      "time": "20:00"
    }
  ],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}


Notes:

Keep times simple strings; parse them client-side.

If current app stores schedules differently, adjust generators accordingly.

3.4 Access Token Document

Collection: /accessTokens/{tokenId}
{
  "id": "string",
  "petId": "string",
  "grantedBy": "string",
  "grantedTo": "string|null",
  "role": "sitter",
  "status": "pending | active | expired",
  "expiresAt": "Timestamp",
  "durationHours": 48,
  "createdAt": "Timestamp"
}

Notes:

This supports QR-based handoff.

Must be indexed for expiration queries.

3.5 Task Log Document (Sitter Completion)

Collection: /taskLogs/{logId}

{
  "id": "string",
  "petId": "string",
  "taskType": "feeding | medication | custom",
  "scheduledTime": "18:00",
  "timestampCompleted": "Timestamp",
  "completedBy": "userId",
  "note": "optional note text",
  "photoUrl": "string|null"
}

Notes:

This is one log per completed occurrence.

Do NOT store all occurrences; generate dynamically.

3.6 Message Thread

Collection: /messageThreads/{threadId}
{
  "id": "string",
  "ownerId": "string",
  "sitterId": "string",
  "participants": ["ownerId", "sitterId"],
  "lastMessagePreview": "string|null",
  "lastMessageAt": "Timestamp"
}

Message Document

Collection: /messageThreads/{threadId}/messages/{messageId}

{
  "id": "string",
  "senderId": "string",
  "timestamp": "Timestamp",
  "type": "text | photo",
  "text": "string|null",
  "photoUrl": "string|null"
}

3.7 Notification Document

Collection: /notifications/{notificationId}

{
  "id": "string",
  "userId": "string",
  "petId": "string",
  "eventType": "task | note | photo | chat",
  "message": "string",
  "timestamp": "Timestamp",
  "metadata": {
    "taskId": "string|null",
    "photoUrl": "string|null",
    "messageId": "string|null"
  }
}

4. Query Patterns (LLM Reference)
Read pet list
FirebaseFirestore.instance
  .collection('pets')
  .where('ownerId', isEqualTo: userId)

Active sitter access
.collection('accessTokens')
.where('grantedTo', isEqualTo: userId)
.where('status', isEqualTo: 'active')

Recent notifications
.collection('notifications')
.where('userId', isEqualTo: userId)
.orderBy('timestamp', descending: true)
.limit(3)

5. Adaptation Notes for LLMs

Before writing code:

Inspect the existing collections in Firestore.

Inspect model classes in lib/models/ or lib/features/....

Adapt fields to match existing schema.

Never break backward compatibility.

When adding missing fields, default them safely.

End of Document