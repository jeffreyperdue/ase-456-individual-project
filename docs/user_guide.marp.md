---
marp: true
theme: default
paginate: true
class: lead
---

<!-- _class: lead -->

# Petfolio  
## User Guide

The shared hub for keeping your pet’s care in sync  
Version: MVP + Sync (Class Project)

---

## Who This Guide Is For

- **Pet Owners**
  - You own or manage one or more pets.
  - You want an organized place for care plans, reminders, and sitter handoffs.
- **Family / Roommates / Co‑caretakers**
  - You share day‑to‑day responsibilities with the owner.
- **Pet Sitters / Walkers**
  - You receive temporary access to care instructions and tasks.

This guide walks through **how to use the app today** – what’s implemented and how to get value from it quickly.

---

## 1. Getting Started

- **Install the app**
  - Use the build provided by your instructor/teammate (mobile or web).
- **Create an account**
  - Open the app and choose **Sign up**.
  - Enter your email and password.
  - Verify your email if prompted (depending on environment).
- **Log in**
  - Use **Log in** on the welcome screen.
  - After sign‑in, you’ll be taken through first‑time onboarding.

---

## 1.1 First-Time Onboarding

After logging in for the first time:

1. See a **Welcome** screen with a short overview of Petfolio.
2. Begin a guided flow to **create your first pet**.
3. Add basic pet details (name, species, photo, etc.).
4. Finish onboarding and land on the **main pet dashboard**.

> You can always add more pets later; the first flow just helps you start quickly.

---

## 2. The Main Screens

Depending on your build, you’ll see a **bottom navigation bar** with tabs such as:

- **Pets / Home**
  - List of your pets and a quick overview of their status.
- **Care / Tasks**
  - Access to care plans and task views (feeding, meds, etc.).
- **Profile / Settings**
  - Account info and app‑level actions (log out, etc.).

We’ll focus on the **owner experience** first, then cover **sitters and public views**.

---

## 3. Managing Pets (Owner)

On the **Pets** tab:

- **Add a new pet**
  - Tap the **Add Pet** button (usually a “+” icon or FAB).
  - Fill out:
    - Name, species, breed
    - Date of birth (if known)
    - Weight / height (optional)
    - Notes (medical / behavior, if available)
  - Upload a **photo** from your device (optional but recommended).
  - Save to create your pet.

---

## 3.1 Editing & Deleting Pets

- **Edit a pet**
  - Tap a pet card to open the **Pet Detail** screen.
  - Choose **Edit**.
  - Update basic info, notes, or photo.
  - Save changes.
- **Delete a pet**
  - From Edit mode, you may see a **Delete** action.
  - Deleting a pet removes their record and associated care data.
  - Only do this if you are sure you no longer need the data.

> Deletion is meant for testing / class use. In production, you might prefer archiving.

---

## 4. Care Plans

Each pet can have a **Care Plan** covering:

- **Diet & Feeding**
  - Food type, portion, frequency.
  - Feeding schedule times (e.g., 8 AM & 6 PM).
- **Medications**
  - Name, dosage, frequency, any special notes.
- **Emergency & Medical Notes**
  - Vet contact info, allergies, conditions.
- **Behavioral Notes**
  - Temperament, triggers, do’s and don’ts.

You access the care plan from the **Pet Detail** screen.

---

## 4.1 Editing the Care Plan

To create or edit a care plan:

1. Open your pet’s **Detail** screen.
2. Tap **Edit Care Plan** (or similar CTA).
3. Fill in:
   - Diet / feeding description.
   - Feeding times (e.g., morning, evening).
   - Medications with times and notes.
4. Save the care plan.

Once saved, the app uses these entries to schedule **reminders** on your device.

---

## 5. Reminders & Notifications

Petfolio uses **local notifications** to remind you of care events:

- **What you’ll see**
  - Notifications at the scheduled times for:
    - Feedings.
    - Medication doses.
- **Permissions**
  - On first use, the app asks for permission to send notifications.
  - You must allow notifications for reminders to appear.

> Reminders are **local to your device** – push notifications to other users are planned but not enabled yet.

---

## 5.1 Managing Notifications

- **Enable / disable**
  - Use your device’s system settings to allow or block notifications for Petfolio.
- **Adjust times**
  - Change feeding/medication times inside the **Care Plan**.
  - New times will be reflected in future reminders (some changes may require reopening the app depending on platform).
- **If you don’t see notifications**
  - Confirm system notification settings.
  - Confirm your device time and timezone are correct.

---

## 6. Sharing Your Pet with a Sitter

Petfolio makes it easy to hand off care to a **sitter** using a **QR code or link**:

- **Use cases**
  - Going on vacation.
  - Hiring a dog walker.
  - Leaving your pet with a trusted friend.
- **What the sitter gets**
  - Readable care plan and schedule.
  - A dashboard of tasks to complete.
  - No ability to change your pet’s core data.

---

## 6.1 Creating an Access Link

To share your pet:

1. Open your pet’s **Detail** screen.
2. Tap **Share Pet** or **Handoff**.
3. Choose:
   - **Role** (e.g., Sitter).
   - **Expiration** (how long access should last).
   - Optional notes or contact details.
4. Tap **Generate** to create an **Access Link / Token**.
5. A **QR code** is shown, and sometimes a shareable link.

You can now share this with your sitter.

---

## 6.2 What the Sitter Sees

When a sitter scans the QR or opens the link:

- They are taken to a **Sitter Dashboard** (app or web).
- They can:
  - View the pet’s **Care Plan**.
  - See a checklist of tasks (feeding, medication, etc.).
  - Mark tasks as **completed**.
- Owners see task completion updates in real time (where supported).

Sitters **cannot** edit your pet profile or care plan.

---

## 6.3 Managing Shared Access

As an owner:

- **View existing handoffs**
  - Open **Share Pet** or similar screen for that pet.
  - You may see a list of active or past **Access Tokens**.
- **Revoke or let expire**
  - Set short expiration times for temporary access.
  - If you revoke or let a token expire:
    - The sitter’s access will stop.
    - Their link or QR will no longer work.

> For the class MVP, interfaces for listing/revoking tokens may be basic or limited – check your specific build.

---

## 7. Lost & Found Mode

If your pet goes missing, Petfolio can help you share information quickly:

- **Lost Mode Features**
  - Mark a pet as **Lost**.
  - Create a **Lost Report** with last‑seen details.
  - Generate a **missing poster** image with key info.
  - Share a **public link or QR** to the poster.

---

## 7.1 Marking a Pet as Lost

To mark a pet as lost:

1. Open the **Pet Detail** screen.
2. Tap **Mark as Lost**.
3. Fill in:
   - Last seen location.
   - Date/time.
   - Any additional notes (e.g., collar, microchip, temperament).
4. Save to create a **Lost Report**.

The pet will now show as **Lost** in your dashboard (e.g., a badge or highlight).

---

## 7.2 Generating a Lost Poster

From the lost pet or report screen:

1. Tap **Generate Poster** (or a similar button).
2. The app builds an image poster that includes:
   - Pet name and photo.
   - Basic description.
   - Contact or scan instructions.
3. The poster is uploaded to the cloud and given a shareable **URL**.
4. You can:
   - Download/print the image.
   - Share the link digitally (messages, social, etc.).

---

## 7.3 Ending Lost Mode

When your pet is found:

1. Open the pet’s **Detail** screen.
2. Tap **Mark as Found** (or turn off lost mode).
3. The pet returns to normal status, and you can keep or archive the report.

> Public links may still work depending on configuration; check with your team if you need them fully disabled.

---

## 8. Sitter Experience (Quick Start)

For sitters:

1. **Receive QR / link** from the owner.
2. **Scan the QR** with your phone or open the link.
3. If needed, **log in or create an account** (depending on build).
4. You’ll see:
   - The pet’s **summary** and photo.
   - **Care Plan** with feeding/med instructions.
   - A **task list** with times.
5. As you complete tasks:
   - Mark them as **Done**.
   - The owner may see updates in their app.

Sitters should always follow the plan and contact the owner if unsure.

---

## 9. Tips for Clear Handoffs

For **owners**:

- Double‑check:
  - Feeding amounts and times.
  - Medication names, dosages, and side effects.
  - Emergency contacts and vet info.
- Add clear **behavior notes**:
  - How your pet reacts to strangers or other animals.
  - Things they are afraid of (storms, fireworks, etc.).

For **sitters**:

- Read the care plan fully before the first visit.
- Confirm your understanding with the owner.
- Use the app as a **checklist** so nothing is missed.

---

## 10. Troubleshooting

**I’m not getting notifications**
- Check:
  - Device notification permissions for Petfolio.
  - Your device’s **Do Not Disturb** or Focus modes.
  - That feeding/med times are set correctly in the care plan.

**My sitter can’t access the pet**
- Confirm:
  - Their QR/link is not expired.
  - You shared the **latest** link if you regenerated one.
  - They have an active internet connection.

---

## 10.1 More Troubleshooting

**I can’t log in**
- Check:
  - Email and password spelling.
  - That you used the same auth provider (email/password vs others if enabled).
- Try:
  - “Forgot password” flow (if enabled in your build).

**Data doesn’t look updated across devices**
- Ensure:
  - You have an internet connection on both devices.
  - You logged in with the same account on each.
  - Wait a few seconds – Firestore sync is usually near‑instant but not always immediate.

---

## 11. Privacy & Safety Notes

- **Owner control**
  - Owners decide who gets access and for how long.
  - Access links are time‑limited and can be revoked.
- **What sitters see**
  - Pet details and care info necessary for safe care.
  - They do *not* get full account access.
- **Public lost posters**
  - Designed to share only information helpful for finding your pet.
  - Avoid including overly personal details in the description.

For any sensitive information, use your best judgment before sharing.

---

## 12. Best Practices

- Keep your **care plan up to date**:
  - Update meds and feeding changes as soon as they happen.
- Before travel:
  - Review the sitter’s access and expiration dates.
  - Confirm your contact info in notes.
- For class demos:
  - Prepare a sample owner account plus a separate sitter flow.
  - Walk through:
    - Creating a pet.
    - Adding a care plan.
    - Generating a handoff.
    - Marking a pet as lost and generating a poster.

---

## 13. Feature Overview (What’s In / Out)

**Implemented (MVP + sync)**
- Pet profiles with photos.
- Care plans and local notifications.
- Time‑boxed sharing via access tokens + QR.
- Sitter dashboard and task completion.
- Lost & Found mode with posters.
---
**Planned / Not yet in this build**
- Full chat/messaging between owners and sitters.
- Push notifications (server‑driven).
- Advanced analytics and weight tracking.
- Offline‑first experience.

---

## 14. Wrap-Up

Petfolio is built to make **handoffs smoother**, **care plans clearer**, and **day‑to‑day routines easier** for everyone who loves your pet.

- Owners: Use it as your **single source of truth** for pet care.
- Sitters: Use it as your **checklist and reference**.
- Families: Use it to **stay in sync** and avoid missed feedings or meds.

Thank you for using Petfolio! 🐾


