# 🏗️ Petfolio Project Architecture Tour

*A beginner-friendly guide to understanding the Petfolio project structure*

---

## 🎯 What is Petfolio?

Petfolio is a **cross-platform pet care app** built with Flutter that helps pet owners, families, and pet sitters stay synchronized with real-time care schedules, reminders, and pet information. Think of it as a shared hub for pet care where everyone involved in your pet's wellbeing can access the same information and coordinate care tasks.

---

## 📁 Project Overview

Your Petfolio project is organized into several main areas:

```
Petfolio/
├── 📱 pet_link/          # The main Flutter app
├── 📋 Documentation/     # Project planning & design files
├── 🎨 Visual Prototypes/ # UI/UX design mockups
└── 📊 Weekly Reports/    # Progress tracking
```

---

## 📱 The Flutter App (`pet_link/`)

This is the heart of your project - the actual mobile/web application. Let's explore its structure:

### 🏗️ App Structure Overview

```
pet_link/
├── lib/                  # Source code (Dart/Flutter)
├── android/             # Android-specific files
├── ios/                 # iOS-specific files
├── web/                 # Web-specific files
├── pubspec.yaml         # Dependencies & app configuration
└── firebase.json        # Firebase project configuration
```

---

## 📚 The `lib/` Folder - Your App's Brain

The `lib/` folder contains all your app's source code. This is where the magic happens!

### 🎯 Core App Files

```
lib/
├── main.dart            # 🚀 App entry point - starts everything
├── firebase_options.dart # 🔥 Firebase connection settings
├── app/                 # 🎨 App-wide configuration
└── features/            # 🧩 Individual app features
```

#### `main.dart` - The Starting Point
- **What it does**: This is like the "power button" for your app
- **Why it matters**: Initializes Firebase, sets up notifications, and launches the app
- **Think of it as**: The front door of a house - everything starts here

#### `app/` Folder - App-Wide Settings
```
app/
├── app.dart             # 🎨 Main app configuration (theme, routes)
└── theme.dart           # 🎨 Colors, fonts, and visual styling
```

- **`app.dart`**: Defines how your app looks and behaves globally
- **`theme.dart`**: Sets your app's visual identity (colors, fonts, button styles)

---

## 🧩 The `features/` Folder - Your App's Features

This is where you organize different parts of your app. Each "feature" is like a mini-app within your main app.

### 🏗️ Feature Architecture

Petfolio follows **Clean Architecture**, which organizes code into layers:

```
features/[feature_name]/
├── domain/              # 🧠 Business logic & data models
├── data/                # 💾 Data storage & external services
├── application/         # 🔄 Use cases & state management
├── presentation/        # 🎨 User interface (screens, widgets)
└── services/            # ⚙️ Helper services & utilities
```

### 📋 Current Features

#### 1. 🔐 Authentication (`features/auth/`)
**Purpose**: Handles user login, signup, and account management

```
auth/
├── domain/user.dart              # 👤 What a user looks like
├── data/auth_service.dart        # 🔐 Firebase authentication
├── application/auth_provider.dart # 📊 State management
└── presentation/pages/           # 🎨 Login & signup screens
    ├── login_page.dart
    ├── signup_page.dart
    └── auth_wrapper.dart
```

- **`user.dart`**: Defines what information we store about each user
- **`auth_service.dart`**: Talks to Firebase to handle login/signup
- **`auth_provider.dart`**: Manages whether someone is logged in or not
- **`pages/`**: The actual screens users see for logging in

#### 2. 🐾 Pet Management (`features/pets/`)
**Purpose**: Create, edit, and manage pet profiles

```
pets/
├── domain/
│   ├── pet.dart                  # 🐕 Basic pet information
│   └── pet_profile.dart          # 📋 Detailed pet profile
├── data/
│   ├── pets_repository.dart      # 💾 Pet data storage
│   └── pet_profile_repository_impl.dart
├── application/                  # 🔄 Business logic
└── presentation/
    ├── pages/                    # 🎨 Pet screens
    │   ├── home_page.dart        # 🏠 Main dashboard
    │   ├── edit_pet_page.dart    # ✏️ Add/edit pets
    │   ├── pet_detail_page.dart  # 👀 View pet details
    │   └── pet_profile_form_page.dart
    └── widgets/                  # 🧩 Reusable UI components
        └── pet_profile_card.dart
```

- **`pet.dart`**: Basic pet info (name, species, breed, weight, etc.)
- **`pet_profile.dart`**: Detailed info (emergency contacts, medical history, notes)
- **`home_page.dart`**: The main screen showing all your pets
- **`edit_pet_page.dart`**: Screen to add or modify pet information

#### 3. 📅 Care Plans (`features/care_plans/`)
**Purpose**: Create feeding schedules, medication reminders, and care routines

```
care_plans/
├── domain/
│   ├── care_plan.dart           # 📋 Complete care plan
│   ├── feeding_schedule.dart    # 🍽️ Feeding times & details
│   ├── medication.dart          # 💊 Medication schedules
│   └── care_task.dart           # ✅ Individual care tasks
├── data/
│   └── care_plan_repository_impl.dart
├── application/                 # 🔄 Care plan business logic
├── presentation/
│   ├── pages/
│   │   ├── care_plan_form_page.dart    # ✏️ Create/edit care plans
│   │   └── care_plan_view_page.dart    # 👀 View care plans
│   └── widgets/                 # 🧩 Care plan UI components
│       ├── feeding_schedule_widget.dart
│       ├── medication_widget.dart
│       └── care_task_card.dart
└── services/
    ├── care_scheduler.dart      # ⏰ Schedule management
    └── care_task_generator.dart # 🏭 Create tasks from schedules
```

- **`care_plan.dart`**: The main care plan containing feeding schedules and medications
- **`feeding_schedule.dart`**: When and how much to feed your pet
- **`medication.dart`**: Medication schedules and dosages
- **`care_scheduler.dart`**: Handles the timing and scheduling logic

---

## 🔧 Configuration Files

### 📦 `pubspec.yaml` - Dependencies
**What it does**: Lists all the external packages your app uses
**Key dependencies**:
- `flutter_riverpod`: State management (keeps track of app data)
- `firebase_auth`: User authentication
- `cloud_firestore`: Database for storing pet data
- `firebase_storage`: File storage for pet photos
- `image_picker`: Taking/selecting photos
- `flutter_local_notifications`: Reminder notifications

### 🔥 `firebase.json` - Firebase Configuration
**What it does**: Connects your app to Firebase services
**Contains**: Database rules, storage settings, and project IDs

---

## 🎨 Visual Design (`visual_prototypes/`)

This folder contains design mockups and color schemes:
- **Color palettes**: Different visual themes for the app
- **Wireframes**: Basic layout designs showing where elements go
- **UI mockups**: Visual representations of what screens will look like

---

## 📋 Project Planning Files

### 📖 `README.md`
**Purpose**: The main project documentation
**Contains**: 
- Project overview and goals
- Development timeline
- Success criteria
- Technical architecture details

### 📅 `week4_plan.md`
**Purpose**: Current development status and goals
**Contains**: Completed features and remaining tasks

### 🚀 `30_day_launch_plan`
**Purpose**: Marketing and user acquisition strategy
**Contains**: Plan to grow from 0 to 500+ daily active users

---

## 🏗️ Architecture Principles

### 🧩 Clean Architecture
Petfolio uses **Clean Architecture**, which separates code into layers:

1. **Domain Layer** (`domain/`): Business rules and data models
2. **Data Layer** (`data/`): External services and data storage
3. **Application Layer** (`application/`): Use cases and state management
4. **Presentation Layer** (`presentation/`): User interface

### 🔄 State Management with Riverpod
- **What it does**: Manages app data and UI updates
- **Why it's good**: Automatically updates UI when data changes
- **Example**: When you add a new pet, the pet list updates automatically

### 🔥 Firebase Backend
- **Authentication**: User accounts and login
- **Firestore**: Database for pets, care plans, and user data
- **Storage**: File storage for pet photos
- **Notifications**: Push notifications for reminders

---

## 🎯 Key App Features

### ✅ Currently Implemented
1. **User Authentication**: Sign up, login, account management
2. **Pet Profiles**: Create and manage detailed pet information
3. **Care Plans**: Set up feeding schedules and medication reminders
4. **Photo Upload**: Add photos to pet profiles
5. **Dashboard**: View all pets and care plan summaries

### 🚧 In Development
1. **Local Notifications**: Reminders for feeding and medication times
2. **QR Code Sharing**: Share pet profiles with sitters and family
3. **Role-Based Access**: Different permission levels for different users

### 🔮 Future Features
1. **Lost & Found**: Generate missing pet posters
2. **Weight Tracking**: Monitor pet health over time
3. **Professional Integration**: Connect with vets, trainers, and groomers

---

## 🚀 How to Navigate the Code

### For Beginners:
1. **Start with `main.dart`** - understand how the app starts
2. **Look at `app/app.dart`** - see how screens are connected
3. **Explore `features/`** - each folder is a separate feature
4. **Check `presentation/pages/`** - these are the actual screens users see

### For Development:
1. **Domain models** define your data structure
2. **Repositories** handle data storage and retrieval
3. **Providers** manage app state and business logic
4. **Pages and widgets** create the user interface

---

## 💡 Key Concepts for Beginners

### 🏗️ **Feature-Based Organization**
Instead of organizing by file type, Petfolio organizes by feature. This makes it easier to find and modify related code.

### 🔄 **State Management**
Riverpod helps manage app data. When you change something in one part of the app, other parts automatically update.

### 🧩 **Widget-Based UI**
Flutter uses "widgets" - small, reusable UI components that you combine to build screens.

### 🔥 **Firebase Integration**
Firebase provides backend services so you don't need to build your own server.

### 📱 **Cross-Platform**
One codebase works on iOS, Android, and web - no need to write separate apps.

---

## 🎉 What Makes This Architecture Good

1. **🧩 Modular**: Each feature is independent and can be developed separately
2. **🔄 Maintainable**: Easy to find and fix bugs
3. **📈 Scalable**: Easy to add new features
4. **🧪 Testable**: Each layer can be tested independently
5. **👥 Team-Friendly**: Multiple developers can work on different features

---

This architecture tour should help you understand how Petfolio is organized and where to find different parts of the code. Remember: the key is that everything is organized by feature, making it easy to understand and modify specific parts of the app without affecting others!
