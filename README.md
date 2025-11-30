# 💬 ChatApp - Real-Time Messaging Application

---

## ✨ Features

### 🔐 Authentication
- **Google Sign-In** - Quick and secure one-tap Google authentication
- **Firebase Authentication** - Robust user session management
- **Auto Login** - Persistent sessions across app restarts
- **Secure Logout** - Complete session termination

### 💬 Messaging
- **Real-Time Chat** - Instant message delivery using Firestore streams
- **One-on-One Conversations** - Private messaging between users
- **Message History** - Persistent chat history stored in cloud
- **Timestamp Display** - See when messages were sent


### 👥 User Management
- **User Discovery** - Browse and find other registered users
- **User Profiles** - View detailed user information
- **Profile Pictures** - Display user avatars from Google accounts
- **Online Status** - See user availability

### 👤 Profile Features
- **View Profile** - See your account details
- **Profile Information** - Display name, email, and profile picture
- **Account Management** - Easy access to settings

### 🎨 UI/UX
- **Dark Theme** - Beautiful, eye-friendly dark mode design
- **Material Design 3** - Modern UI components
- **Responsive Layout** - Works on all screen sizes
- **Smooth Animations** - Polished transitions
- **Intuitive Navigation** - Bottom navigation bar for easy access

---


## 🔄 App Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP START                                │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
                 ┌────────────────────────┐
                 │   Firebase Initialize   │
                 └────────────┬───────────┘
                              │
                              ▼
                 ┌────────────────────────┐
                 │  Check Auth State      │
                 │  (AuthProvider)        │
                 └────────────┬───────────┘
                              │
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
    ┌──────────────────┐           ┌──────────────────┐
    │  Not Logged In   │           │   Logged In      │
    └────────┬─────────┘           └────────┬─────────┘
             │                              │
             ▼                              │
    ┌──────────────────┐                    │
    │   Login Screen   │                    │
    │  ┌────────────┐  │                    │
    │  │  Google    │  │                    │
    │  │  Sign-In   │  │                    │
    │  └──────┬─────┘  │                    │
    └─────────┼────────┘                    │
              │                             │
              │  ┌──────────────────────────┘
              │  │
              ▼  ▼
    ┌─────────────────────────────────────────────────────────────┐
    │                      HOME SCREEN                             │
    │  ┌─────────────────────────────────────────────────────┐    │
    │  │                    App Bar                           │    │
    │  │  [Chats Title]                    [Logout Button]   │    │
    │  └─────────────────────────────────────────────────────┘    │
    │                                                              │
    │  ┌─────────────────────────────────────────────────────┐    │
    │  │              Recent Chats List                       │    │
    │  │  ┌─────────────────────────────────────────────┐    │    │
    │  │  │ [Avatar] User Name                          │    │    │
    │  │  │          Last message preview...        → │    │    │
    │  │  └─────────────────────────────────────────────┘    │    │
    │  │  ┌─────────────────────────────────────────────┐    │    │
    │  │  │ [Avatar] User Name                          │    │    │
    │  │  │          Last message preview...        → │    │    │
    │  │  └─────────────────────────────────────────────┘    │    │
    │  └─────────────────────────────────────────────────────┘    │
    │                                                              │
    │  ┌─────────────────────────────────────────────────────┐    │
    │  │              Bottom Navigation Bar                   │    │
    │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐ │    │
    │  │  │  Home   │  │  Users  │  │Favorites│  │ Profile │ │    │
    │  │  │   🏠    │  │   👥    │  │    ⭐   │  │   👤    │ │    │
    │  │  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘ │    │
    │  └───────┼────────────┼────────────┼────────────┼──────┘    │
    └──────────┼────────────┼────────────┼────────────┼───────────┘
               │            │            │            │
               ▼            ▼            ▼            ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │  Chat List   │ │  Users List  │ │  Favorites   │ │   Profile    │
    │   Screen     │ │   Screen     │ │   Screen     │ │   Screen     │
    └──────┬───────┘ └──────┬───────┘ └──────────────┘ └──────────────┘
           │                │
           │                ▼
           │      ┌──────────────────┐
           │      │   User Profile   │
           │      │     Screen       │
           │      │  ┌────────────┐  │
           │      │  │ Start Chat │  │
           │      │  └─────┬──────┘  │
           │      └────────┼─────────┘
           │               │
           └───────┬───────┘
                   │
                   ▼
    ┌─────────────────────────────────────────────────────────────┐
    │                      CHAT SCREEN                             │
    │  ┌─────────────────────────────────────────────────────┐    │
    │  │ [←] [Avatar] User Name                              │    │
    │  └─────────────────────────────────────────────────────┘    │
    │                                                              │
    │  ┌─────────────────────────────────────────────────────┐    │
    │  │                 Messages Area                        │    │
    │  │                                                      │    │
    │  │  ┌──────────────────┐                               │    │
    │  │  │ Received Message │  ← Other User                 │    │
    │  │  │ [timestamp]      │                               │    │
    │  │  └──────────────────┘                               │    │
    │  │                                                      │    │
    │  │                      ┌──────────────────┐           │    │
    │  │        You →        │  Sent Message    │           │    │
    │  │                      │  [timestamp] ✓✓  │           │    │
    │  │                      └──────────────────┘           │    │
    │  │                                                      │    │
    │  └─────────────────────────────────────────────────────┘    │
    │                                                              │
    │  ┌─────────────────────────────────────────────────────┐    │
    │  │ [  Type a message...                    ] [  ➤  ]  │    │
    │  └─────────────────────────────────────────────────────┘    │
    └─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         FLUTTER APP                              │
│                                                                  │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐      │
│  │   Screens    │◄──►│   Providers  │◄──►│   Services   │      │
│  │              │    │              │    │              │      │
│  │ • Login      │    │ • AuthProv   │    │ • ChatServ   │      │
│  │ • Home       │    │   ider       │    │   ice        │      │
│  │ • Chat       │    │              │    │              │      │
│  │ • Profile    │    │              │    │              │      │
│  └──────────────┘    └──────────────┘    └──────┬───────┘      │
│                                                  │               │
└──────────────────────────────────────────────────┼───────────────┘
                                                   │
                                                   ▼
┌─────────────────────────────────────────────────────────────────┐
│                         FIREBASE                                 │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐                    │
│  │  Authentication  │  │ Cloud Firestore  │                    │
│  │                  │  │                  │                    │
│  │  • Google Auth   │  │  • users/        │                    │
│  │  • User Sessions │  │  • chats/        │                    │
│  │                  │  │    └─messages/   │                    │
│  └──────────────────┘  └──────────────────┘                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🗄️ Database Structure

### Firestore Collections

```
📁 Firestore Database
│
├── 📂 users/
│   └── 📄 {userId}
│       ├── uid: string
│       ├── name: string
│       ├── email: string
│       └── photoURL: string
│
└── 📂 chats/
    └── 📄 {chatRoomId}
        ├── users: [userId1, userId2]
        ├── lastMessage: string
        ├── lastMessageTime: timestamp
        │
        └── 📂 messages/
            └── 📄 {messageId}
                ├── senderId: string
                ├── senderEmail: string
                ├── receiverId: string
                ├── message: string
                ├── timestamp: timestamp
                └── isSeen: boolean
```

#
## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.5+** | Cross-platform UI framework |
| **Dart 3.5+** | Programming language |
| **Firebase Auth** | User authentication (Google Sign-In) |
| **Cloud Firestore** | Real-time NoSQL database |
| **Provider** | State management |
| **Google Sign-In** | OAuth 2.0 authentication |

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.32.0
  firebase_auth: ^4.17.5
  cloud_firestore: ^4.17.5
  
  # Authentication
  google_sign_in: ^6.2.2
  google_identity_services_web: ^0.3.3+1
  
  # State Management
  provider: ^6.1.5
  
  # UI Components
  google_nav_bar: ^5.0.7
  cupertino_icons: ^1.0.8
  
  # Utilities
  shared_preferences: ^2.5.3
  intl: ^0.20.2
  device_preview: ^1.2.0
```

---


