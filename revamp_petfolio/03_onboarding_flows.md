# 03_onboarding_flows.md
Petfolio – Onboarding Flows Specification  
LLM-Optimized Format

---

## 1. Purpose
Defines the onboarding flows for Owners and Sitters, including wizard sequences, skip rules, progress indicators, and first-time logic.

---

## 2. High-Level Principles
- Onboarding should be **short**, **helpful**, and **contextual**.
- Owners and Sitters have different needs.
- Progress indicators should be **numeric** (e.g., “Step 2 of 5”).
- Users should never be forced into unnecessary steps.

---

# 3. Owner Onboarding Flow

### **Trigger Condition**
User logs in for the first time *and* has no pets.

### **Flow Overview**
Splash → Sign In/Up → Choose Role → Owner Onboarding Wizard


### **Wizard Steps (Flexible Length)**
The wizard should show numeric progress (“Step X of Y”), but Y is flexible.

Recommended steps:

1. **Welcome Screen**
   - “Welcome to Petfolio”
   - Brief explanation of app value

2. **What You Can Do**
   - Highlights: care plans, reminders, sitters, QR handoff, profiles

3. **Add Your First Pet**
   - Pet creation form (name, species, gender, age, weight)
   - Photo optional

4. **Care Plan Overview (Optional)**
   - Explain schedules, tasks, reminders

5. **Success Screen**
   - Confirms setup
   - Button: “Go to Dashboard”

### **Skip Logic**
Owners **should not** be forced to create a pet immediately if they do not have one yet.

Include:
> “Skip for now”

---

# 4. Sitter Onboarding Flow (Option A – Chosen)

### **Trigger Condition**
New user selects “Sitter” during signup OR user logs in with no pets and no sitter access.

### **Flow Overview**
Splash → Sign In/Up → Choose Role → Sitter Onboarding Wizard


### **Wizard Steps**
1. **Welcome Screen**
   - “Welcome to Petfolio – Your pet care companion.”

2. **How It Works**
   - Overview of sitter experience:
     - View care plans
     - Complete tasks
     - Add notes/photos
     - Chat with owners

3. **Accepting Pets**
   - Explain QR scanning
   - Text: “If you’ve been given a QR code, you can scan it now.”

4. **Scan Prompt**
   - Provide QR scan button  
   - Allow skipping

5. **Success Screen**
   - “You’re all set!”
   - Button → Sitter Dashboard

---

## 5. Returning User Behavior

### **Logged Out User**
Splash → Login → Dashboard

(No onboarding)

### **Logged In Returning User**
Splash → Dashboard


### **If user changed roles**
Do not trigger onboarding again.

---

## 6. Pet Info Optionality for Sitters
If a sitter has no pets and no active QR tokens:
- Show banner on Sitter Dashboard:
> “No pets yet. Scan a QR code to begin caring for a pet.”

No onboarding is required again.

---

## 7. Progress Indicator Behavior
Wizard shows:
- Step number
- Total steps

Format:
> “Step 2 of 5”

Total steps should adjust dynamically if implementation changes.

---

## 8. LLM Implementation Notes
- Wizard screens should use a shared layout component with a progress bar.
- Route names should follow existing navigation conventions.
- Check if onboarding state uses SharedPreferences or Firestore; adapt accordingly.
- Skip buttons must persist state so onboarding is not shown again.

---

## 9. End of Document
This defines the complete onboarding logic for all roles.
