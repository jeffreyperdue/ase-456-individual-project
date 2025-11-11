# Deploy Firestore Security Rules

The Firestore security rules have been created in `firestore.rules`. You need to deploy them to Firebase for the Lost & Found feature to work.

## Steps to Deploy Rules

### Option 1: Using Firebase CLI (Recommended)

1. **Install Firebase CLI** (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Initialize Firebase** (if not already done):
   ```bash
   cd ase-456-individual-project/pet_link
   firebase init firestore
   ```
   - Select your Firebase project: `pet-link-e256d`
   - Use the existing `firestore.rules` file
   - Use the default `firestore.indexes.json` (or create one if prompted)

4. **Deploy the rules**:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Option 2: Using Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `pet-link-e256d`
3. Navigate to **Firestore Database** → **Rules** tab
4. Copy the contents of `firestore.rules` file
5. Paste into the rules editor
6. Click **Publish**

## Verify Rules are Deployed

After deploying, test the Lost & Found feature:
1. Mark a pet as lost
2. Check that it works without permission errors
3. Try viewing the poster

## Rules Overview

The `firestore.rules` file includes security rules for:
- ✅ **Users** - Users can read/write their own documents
- ✅ **Pets** - Owners can read/write their own pets, shared access via tokens
- ✅ **Care Plans** - Owners can read/write care plans for their pets
- ✅ **Access Tokens** - For sharing pet access
- ✅ **Lost Reports** - Owners can create/read/update/delete their own lost reports
- ✅ **Task Logs** - For future use

## Important Notes

- **Security**: The rules ensure that users can only access their own data
- **Lost Reports**: Only the owner of a lost report can create, read, update, or delete it
- **Testing**: Make sure to test the rules after deployment to ensure they work as expected

## Troubleshooting

If you get permission errors after deploying:
1. Check that the rules were deployed successfully
2. Verify the user is authenticated
3. Check that the `ownerId` in the document matches the authenticated user's ID
4. Check Firebase Console → Firestore → Rules to see if there are any rule validation errors

