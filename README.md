# app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.



# 🧑‍🤝‍🧑 Friendly App - Social Feed with Flutter & Supabase

A social media-style Flutter application backed by Supabase. This app allows users to:

- ✅ Post status updates
- 👀 View a feed of friends' activities
- ❤️ Like and 💬 comment on posts
- 🚩 Report inappropriate content for moderation

## 🚀 Features

- **User Authentication** (Supabase Auth)
- **Post Creation & Editing**
- **Real-time Feed of Friends' Posts**
- **Like and Comment System**
- **Post Deletion**
- **Content Reporting**
- **Image Upload with Posts**

---

## 🛠️ Tech Stack

| Layer        | Technology          |
|--------------|----------------------|
| Frontend     | Flutter              |
| Backend      | Supabase (PostgreSQL + Auth + Storage) |
| Database     | Supabase PostgreSQL  |
| Realtime     | Supabase Subscriptions |

---


## 🧩 Project Structure

lib/
├── main.dart
├── pages/
│ ├── login_page.dart
│ ├── signup_page.dart
│ ├── feed_page.dart
│ ├── create_post_page.dart
│ ├── edit_post_page.dart
│ └── comments_page.dart
├── widgets/
│ ├── post_card.dart
│ └── comment_tile.dart
└── services/
└── supabase_service.dart


## ⚙️ Setup Instructions

1. **Clone the repository**:

   ```bash
   git clone https://github.com/yourusername/friendly-app-flutter.git
   cd friendly-app-flutter
Install dependencies:

flutter pub get
Set up Supabase project:
Create a new project at https://supabase.com
Create the following tables:
posts
likes
comments
reports
Enable Row-Level Security (RLS) and add necessary policies
Enable authentication (Email + Password)
Configure Supabase Storage for image uploads

Run the app:
flutter run
🔐 Supabase Table Schema (Basic Overview)
posts
Column	Type
id	UUID
user_id	UUID
content	Text
image_url	Text
created_at	Timestamp

likes
Column	Type
id	UUID
post_id	UUID
user_id	UUID

comments
Column	Type
id	UUID
post_id	UUID
user_id	UUID
content	Text
created_at	Timestamp

reports
Column	Type
id	UUID
post_id	UUID
user_id	UUID
reason	Text
created_at	Timestamp



