# 📄 **12_llm_implementation_guidelines.md**

```markdown
# 12_llm_implementation_guidelines.md
Petfolio – LLM Implementation Guidelines  
The Most Important File for Future AI Contributors

---

## 1. Purpose
Provides explicit instructions for other LLMs working on the Petfolio codebase.  
Ensures safe, consistent, extendable, and non-destructive contributions.

---

# 2. Golden Rules for LLMs

### **Rule #1: Never overwrite existing logic blindly.**
Always inspect:
- Existing files under `lib/features/`
- Existing providers
- Existing Firestore schemas
- Existing routing setup

---

### **Rule #2: Changes must be additive or adaptive, not destructive.**
Prefer:
- Extending models  
- Adding optional fields  
- Creating helper functions  

Avoid:
- Renaming collections  
- Removing fields  
- Changing required values  

---

### **Rule #3: Follow Petfolio terminology exactly.**
Terms defined in System Overview must remain consistent:
- Owner  
- Sitter  
- AccessToken  
- TaskOccurrence  
- Care Plan  
- NotificationEvent  

---

### **Rule #4: Align with Riverpod patterns already in the project.**
Inspect:
lib/features/<feature>/providers/

yaml
Copy code
Before creating a new provider, answer:
1. Is there already a provider for this data?
2. Should I extend or reuse it?
3. Can I add a new provider without breaking existing logic?

---

### **Rule #5: Use Firestore snapshots for anything real-time.**

Examples:
- Pet lists  
- Task updates  
- Chats  
- Notifications  

Avoid one-time `.get()` calls unless necessary.

---

# 3. Implementation Sequence for LLMs

## Step 1 — Scan the Project
Identify:
- File structure
- Existing widgets/screens
- Existing providers
- Existing models
- Any TODO markers left by the developer

## Step 2 — Identify the Feature Area
Map the requested implementation to the correct module:
- Dashboard → Document 4  
- Care Plan → Document 5  
- Sharing → Document 6  
- Messaging → Document 7  
- Notifications → Document 8  

## Step 3 — Compare Schema to Document 10
Match fields carefully.

If discrepancies are found:
- Preserve existing schema
- Add missing fields
- Never remove fields

## Step 4 — Generate Code with Integration Points
For new features:
- Provide updated UI  
- Provide providers  
- Provide Firestore queries  
- Provide error handling  
- Provide comments showing assumptions  

## Step 5 — Provide Validation Checks
Always include:
- Null checks  
- Permission checks  
- Role checks (owner vs sitter)  
- Token expiration checks  

---

# 4. LLM Interaction Safety Guidelines

### 4.1 Never Delete Collections
If user requests to redesign a schema, provide:
> “Here is a recommended migration strategy.”

Not:
- deletion  
- hard resets  

### 4.2 Avoid Breaking the Build
Make sure:
- Imports remain valid  
- Async calls handled properly  
- Refactoring steps are explicit  
- No circular dependencies created  

### 4.3 Respect the Style of Existing Code
If the code uses:
- `StateNotifier` → use it  
- `AsyncNotifier` → use it  
- Plain providers → use them  

LLMs may adjust templates accordingly.

---

# 5. Recommended Folder Structure (Flexible)

lib/
features/
onboarding/
dashboard/
pets/
care_plans/
sharing/
messaging/
notifications/
access_tokens/
models/
providers/
services/
widgets/

yaml
Copy code

If the app already uses a different structure, follow the existing one.

---

# 6. Example Prompt for Future LLM Usage

You may include this prompt in your documentation:

> **“You are a code assistant working on the Petfolio Flutter app.  
> Before generating code, inspect the relevant features under lib/features/.  
> Use the schemas, rules, and flows defined in the Petfolio Specification Documents.  
> Do not overwrite existing models or providers; extend or adapt them.  
> Ensure all Firestore queries match the current production schema.”**

---

# 7. Known Pitfalls to Avoid

- Duplicating providers  
- Writing queries using wrong collection names  
- Hard-writing test data into code  
- Ignoring expiration rules  
- Forgetting timezone correctness  
- Treating chat as per-pet instead of per-owner-sitter  

---

# 8. Best Practices for Future Enhancements

- Keep Firestore reads minimal  
- Cache static pet data locally when possible  
- Use Riverpod for all asynchronous dependencies  
- Write small, composable widgets  
- Keep routes named consistently  

---

# 9. Final Reminder to All LLMs

> **Always scan the codebase before writing code.  
> Always adapt your implementation to existing structure.  
> Always follow the rules and schemas in this specification.  
> Never delete or break existing functionality.**  

This ensures Petfolio remains stable, scalable, and consistent regardless of how many AI systems contribute.

---

# End of Document