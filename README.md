# Mini TaskHub - Personal Task Tracker

## Project Description

Mini TaskHub is a simple yet effective personal task tracking application built with Flutter and powered by Supabase for authentication and data storage. This application allows users to register, log in, manage their tasks (add, mark as complete, delete), and provides a clean, responsive user interface.

## Features

- **User Authentication**: Secure email/password authentication using Supabase.
- **Task Management**: Add new tasks, mark tasks as completed, and delete tasks.
- **Responsive UI**: Designed to adapt to various screen sizes.
- **State Management**: Utilizes `provider` for efficient state management.
- **Theming**: Custom light theme with Google Fonts integration.
- **Basic Animations**: Subtle transitions for a better user experience.

## Technologies Used

- **Flutter**: UI Toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase.
- **Supabase**: Open-source Firebase alternative providing a PostgreSQL database, Authentication, instant APIs, and Realtime subscriptions.
- **Provider**: A simple yet powerful state management solution for Flutter.
- **Google Fonts**: For custom typography.

## Setup Instructions

Follow these steps to get the Mini TaskHub project up and running on your local machine.

### 1. Clone the Repository

```bash
git clone <repository_url>
cd mini_taskhub
```

### 2. Install Flutter Dependencies

Navigate to the project directory and run `flutter pub get` to install all required dependencies:

```bash
flutter pub get
```

### 3. Supabase Setup

Mini TaskHub uses Supabase for backend services. You need to set up a Supabase project and configure it with the app.

#### a. Create a Supabase Project

1. Go to [Supabase](https://supabase.com/) and sign up or log in.
2. Click on "New project" to create a new project.
3. Choose an organization, enter a project name, set a strong database password, and select a region.

#### b. Get Supabase URL and Anon Key

1. Once your project is created, navigate to "Project Settings" > "API" in your Supabase dashboard.
2. Copy your `Project URL` and `Anon Key`.

#### c. Configure Supabase in Flutter App

1. Open `lib/main.dart` in your Flutter project.
2. Replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` with your actual Supabase project URL and Anon Key:

   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

#### d. Set up Supabase Database Table

1. In your Supabase dashboard, navigate to "Table Editor".
2. Click "New table" and create a table named `tasks` with the following columns:

   - `id`: `int8`, Primary Key, `Is Identity` checked, Default Value `nextval('tasks_id_seq'::regclass)`
   - `title`: `text`, Not Null
   - `is_completed`: `boolean`, Default Value `false`
   - `created_at`: `timestamptz`, Default Value `now()`
   - `user_id`: `uuid`, Not Null, Foreign Key to `auth.users` (`id`)

3. Set up Row Level Security (RLS) for the `tasks` table:
   - Enable RLS.
   - Create a new policy for `SELECT` operations:
     - **Name**: `Allow users to view their own tasks`
     - **FROM**: `Public`
     - **FOR**: `SELECT`
     - **USING Expression**: `auth.uid() = user_id`
   - Create a new policy for `INSERT` operations:
     - **Name**: `Allow users to insert their own tasks`
     - **FROM**: `Public`
     - **FOR**: `INSERT`
     - **WITH CHECK Expression**: `auth.uid() = user_id`
   - Create a new policy for `UPDATE` operations:
     - **Name**: `Allow users to update their own tasks`
     - **FROM**: `Public`
     - **FOR**: `UPDATE`
     - **USING Expression**: `auth.uid() = user_id`
   - Create a new policy for `DELETE` operations:
     - **Name**: `Allow users to delete their own tasks`
     - **FROM**: `Public`
     - **FOR**: `DELETE`
     - **USING Expression**: `auth.uid() = user_id`

### 4. Run the Application

Connect a device or start an emulator, then run the app:

```bash
flutter run
```

## Hot Reload vs. Hot Restart

Flutter offers two powerful features for rapid development: Hot Reload and Hot Restart.

- **Hot Reload**: This feature injects updated source code into the running app. It rebuilds the widget tree, allowing you to quickly see changes to the UI and logic without losing the current state of your application. It's ideal for making small UI tweaks or fixing minor bugs.

- **Hot Restart**: This feature fully restarts the application, discarding the current state and rebuilding the entire application from scratch. It's necessary when you make changes that affect the application's state or structure, such as modifying `main()` function, `initState()` methods, or global variables. Hot Restart is slower than Hot Reload but ensures a clean slate for significant code changes.

## Folder Structure

```
mini_taskhub/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   └── theme.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── auth_service.dart
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── task_tile.dart
│   │   └── task_model.dart
│   ├── services/
│   │   └── supabase_service.dart
│   └── utils/
│       └── validators.dart
├── test/
│   └── task_model_test.dart
├── pubspec.yaml
└── README.md
```

## Testing

To run the unit tests for the `Task` model, use the following command:

```bash
flutter test test/task_model_test.dart
```

## Author

Manus AI
