# Mini TaskHub v4.1 📝💎

A premium, personal task tracking application built with **Flutter** and **Supabase**, featuring a beautiful "White Card" aesthetic and advanced productivity tools.

## 🚀 Key Features

### 💎 Premium Visuals & UX
- **Reference Match Design**: Clean white cards with subtle color tints and soft, dispersed shadows.
- **Bold Accents**: 
  - 🔵 **Todo**: Professional Blue
  - 🟠 **In Progress**: Energetic Orange/Yellow
  - 🟢 **Done**: Calm Teal/Green
- **Circular Progress**: Modern ring indicators (0%, 50%, 100%) replace standard checkboxes.
- **Micro-Animations**: Uses `flutter_animate` for smooth entry and interaction effects.

### ⚡ Advanced Productivity
- **Drag & Drop Reordering**: Long-press and drag to prioritize tasks within your list.
- **Smart Swipes**: 
  - Swipe **Right** to Start (Blue) or Complete (Green) with text feedback.
  - Swipe **Left** to Delete (Red).
  - **Snackbar Confirmations** for every action.
- **Time Management**: Set **Start** and **End** dates.
- **Missed Task Logic**: Automatically flags tasks strictly past their end date with a bold 🔴 **MISSED** tag.

### 🔒 Secure & Cloud-Sync
- **Supabase Backend**: Real-time database and secure Email/Password authentication.
- **Persistent State**: Logins persist across restarts.

## 🛠️ Setup Instructions

1. **Prerequisites**:
   - Flutter SDK (3.10+)
   - Supabase Project

2. **Database Setup (Critical)**:
   Run the following SQL in your Supabase SQL Editor to enable the v4.1 schema:
   ```sql
   -- Core Table
   create table if not exists tasks (
     id uuid default gen_random_uuid() primary key,
     title text not null,
     description text,
     is_completed boolean default false,
     user_id uuid references auth.users not null,
     status text default 'todo',
     priority text default 'medium',
     start_date timestamp with time zone,
     end_date timestamp with time zone,
     position integer default 0,
     created_at timestamp with time zone default timezone('utc'::text, now()) not null
   );
   
   -- Enable RLS
   alter table tasks enable row level security;
   create policy "Users can view their own tasks" on tasks for select using (auth.uid() = user_id);
   create policy "Users can insert their own tasks" on tasks for insert with check (auth.uid() = user_id);
   create policy "Users can update their own tasks" on tasks for update using (auth.uid() = user_id);
   create policy "Users can delete their own tasks" on tasks for delete using (auth.uid() = user_id);
   ```

3. **Install & Run**:
   ```bash
   flutter pub get
   flutter run
   ```

## 🏗️ Architecture
Built with **Clean Architecture**:
- **Presentation**: `Bloc` (State Management), `Pages`, `Widgets`.
- **Domain**: `Entities`, `UseCases`, `Repositories` (Abstract).
- **Data**: `Models`, `DataSources` (Supabase), `Repositories` (Impl).
- **DI**: `GetIt` for dependency injection.
