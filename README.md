# 📋 Taskati

**Taskati** is a modern and simple Flutter task management application designed to help users create, manage, organize, and track their daily tasks easily.

The app provides a clean and user-friendly interface with authentication, task management, search, profile customization, dark mode, and local data storage.

---

## ✨ Features

### 🔐 Authentication

* User Registration
* User Login
* Email validation
* Password validation
* Confirm password validation
* Prevent duplicate email registration
* Login session management
* Logout functionality
* Loading state during login

### 📝 Task Management

* Add new tasks
* Edit existing tasks
* Delete tasks
* Mark tasks as completed
* View pending tasks
* View completed tasks
* Task counter for Pending and Done tasks
* Empty state when there are no tasks
* Task validation

### 🔍 Search

* Search tasks by title
* Quickly find tasks from the Home screen
* Dynamic task filtering

### 👤 Profile

* Display user information
* Display name and email
* Change profile picture
* Pick image from Gallery
* Take profile picture using Camera
* Save profile picture locally

### 🌙 Theme

* Light Mode
* Dark Mode
* Switch between themes from the Home screen
* Switch between themes from the Profile screen

### 💾 Local Storage

The application uses **Hive** for local data storage.

Hive is used to store:

* User accounts
* Tasks
* Completed tasks
* Login session
* Profile pictures

### 🎨 UI / UX

* Clean and modern interface
* Responsive layouts
* Reusable custom form fields
* Validation messages
* Confirmation dialogs
* Empty states
* Loading states
* Consistent colors and components
* Dark mode support

---

## 🛠️ Technologies Used

* **Flutter**
* **Dart**
* **Hive**
* **Hive Flutter**
* **Image Picker**
* **Permission Handler**
* **Material Design**

---

## 📦 Packages

Main packages used in the project:

```yaml
dependencies:
  flutter:
    sdk: flutter

  hive:
  hive_flutter:
  image_picker:
  permission_handler:
```

---

## 🏗️ Project Structure

```text
lib/
│
├── auth/
│   ├── login_screen.dart
│   └── register_screen.dart
│
├── home/
│   └── home_screen.dart
│
├── add_task/
│   └── add_task.dart
│
├── done/
│   └── done_tasks.dart
│
├── profile/
│   └── profile_screen.dart
│
├── session/
│   └── session_controller.dart
│
├── theme/
│   └── theme_controller.dart
│
├── widgets/
│   └── custom_field.dart
│
├── app_validate.dart
│
└── main.dart
```

---

## 🔄 App Flow

```text
Start App
    │
    ▼
Check Login Session
    │
    ├── Logged In ──────► Home Screen
    │
    └── Not Logged In
              │
              ▼
         Login Screen
              │
              ├── Login
              │
              └── Register
                       │
                       ▼
                 Create Account
                       │
                       ▼
                    Login
                       │
                       ▼
                  Home Screen
```

---

## 🗃️ Data Storage

Taskati uses Hive boxes to manage local application data.

### Users Box

```text
users
```

Stores:

```text
name
email
password
profileImage
```

### Tasks Box

```text
myTask
```

Stores:

```text
task
description
isDone
```

### Completed Tasks Box

```text
doneTask
```

Stores completed tasks.

### Session Box

```text
session
```

Stores:

```text
isLoggedIn
userName
userEmail
```

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/Khaledwaleed11/taskati.git
```

### 2. Navigate to the project

```bash
cd taskati
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the application

```bash
flutter run
```

---

## 📱 Application Screens

The application contains:

* Login Screen
* Register Screen
* Home Screen
* Add Task Screen
* Edit Task Screen
* Done Tasks Screen
* Profile Screen
* Splash / Loading Experience

---

## 🔒 Validation

Taskati includes a centralized validation class called `AppValidator`.

It handles validation for:

* Email
* Password
* Confirm Password
* Name
* Phone Number
* Username
* Required fields

This makes validation reusable across different screens.

---

## 🎯 Future Improvements

Possible future improvements include:

* Firebase Authentication
* Cloud database synchronization
* Push notifications
* Task deadlines
* Task priorities
* Task categories
* Reminder notifications
* Cloud backup
* Multiple user devices synchronization
* Task statistics and analytics

---
## 📱 Screenshots

### 🔐 Login
<img width="720" height="1600" alt="login_screen" src="https://github.com/user-attachments/assets/6407a7c1-38ac-4dd8-9a63-8fb831e43b62" />

### 📝 Register
<img width="720" height="1600" alt="register_screen" src="https://github.com/user-attachments/assets/60b2c199-a9b0-4646-a39d-e88afbf4a002" />

### 🏠 Home
<img width="720" height="1600" alt="home_screen" src="https://github.com/user-attachments/assets/b70efae4-a054-473f-ad0b-08539d8931ad" />

### 👤 Profile
<img width="720" height="1600" alt="profile_screen" src="https://github.com/user-attachments/assets/6fc7662e-0ce5-47ef-82a4-54f65efea315" />

### ➕ Add Task
<img width="720" height="1600" alt="add_screen" src="https://github.com/user-attachments/assets/b8360de7-8710-4951-9135-e118a568c7db" />

### ✅ Done Tasks
<img width="720" height="1600" alt="done_screen" src="https://github.com/user-attachments/assets/5c0fc6e8-9996-49f4-801e-239630efae3d" />

### 🌙 Dark Theme
<img width="720" height="1600" alt="dark_theme2" src="https://github.com/user-attachments/assets/cbf3a97b-6912-4091-bd6b-01f4f7d30a42" />

### 🚀 Splash Screen
<img width="1080" height="2400" alt="splash_screen" src="https://github.com/user-attachments/assets/0f0c89a6-47d3-4228-aaf5-b59aceecc36b" />

### ✏️ Update Task
<img width="720" height="1600" alt="update_screen" src="https://github.com/user-attachments/assets/e5504a61-969a-4831-9acf-b2d239a84083" />

## 👨‍💻 Developer

**Khaled Waleed**

Flutter Developer

---

## 📄 License

This project is created for learning and development purposes.
