# Course CMS & Chunked Upload Implementation Plan

We will implement a comprehensive Course Content Management System (CMS) in the StuStep Admin Dashboard. This system will allow admins to create courses, organize them into chapters and lessons, upload rich media (large video files and PDF course materials), and link courses/lessons to Firestore-based academic chat groups. It includes a native Web chunked upload service that avoids browser memory crashes.

---

## User Review Required

> [!IMPORTANT]
> **Web-Only Environment & Native API**: Since this dashboard is a web-only Flutter application (lacking mobile/desktop directories), we will use `dart:html` APIs directly to perform chunked file slicing (`Blob.slice`) and file reading (`FileReader`). This avoids loading multi-gigabyte videos into RAM (which crashes browser tabs) and provides native, highly-optimized progress tracking.

> [!TIP]
> **Full Simulation Mode**: The upload and course management services will support a simulation mode (matching the existing `AuthProvider`'s simulation switch). Admins can test chunked uploads, pauses, resumes, retries, and CRUD operations directly in the browser with mock network latency and visual progress indicators, without needing active backend API endpoints.

---

## Proposed Changes

### 1. Data Models (`lib/models/`)

#### [NEW] [course_model.dart](file:///e:/projects/stustep-dashboard/stustep_admin/lib/models/course_model.dart)
Represents a course container.
* Fields: `id`, `title`, `description`, `category`, `instructorId`, `instructorName`, `coverImageUrl`, `totalDuration` (minutes), `totalLessons`, `relatedChatGroupId`, `createdAt`, `updatedAt`.
* Helper functions for JSON mapping (`toMap`, `fromMap`, `copyWith`).

#### [NEW] [chapter_model.dart](file:///e:/projects/stustep-dashboard/stustep_admin/lib/models/chapter_model.dart)
Represents a chapter outline folder inside a course.
* Fields: `id`, `title`, `order`, `createdAt`.
* JSON serialization and copy capability.

#### [NEW] [lesson_model.dart](file:///e:/projects/stustep-dashboard/stustep_admin/lib/models/lesson_model.dart)
Represents an individual educational resource.
* Fields: `id`, `title`, `description`, `type` (e.g., `'video'`, `'pdf'`), `order`, `videoUrl`, `pdfUrl`, `durationSeconds`, `relatedChatGroupId`, `createdAt`, `updatedAt`.
* JSON serialization and copy capability.

---

### 2. Services (`lib/services/`)

#### [NEW] [chunked_upload_service.dart](file:///e:/projects/stustep-dashboard/stustep_admin/lib/services/chunked_upload_service.dart)
Manages binary file uploads in small segments (chunks) to avoid crashing the browser event loop.
* **Native Slicing**: Uses `dart:html.Blob.slice` to split the file indexically without reading the whole file into RAM.
* **Progress Tracking**: Exposes a real-time progress stream/callback (bytes uploaded, speed, percent).
* **Exponential Backoff**: If a network request fails, automatically retries after an increasing delay (e.g., 1s, 2s, 4s, 8s, 16s) up to 5 times.
* **Pause / Resume**: Retains upload offset so uploads can pause and resume from the last successful chunk index.
* **Simulation Mode**: Simulates chunked upload behavior with realistic progress delay, randomized failure, and retry logic.

---

### 3. Providers & App Configuration (`lib/providers/` & `lib/`)

#### [NEW] [courses_provider.dart](file:///e:/projects/stustep-dashboard/stustep_admin/lib/providers/courses_provider.dart)
Extends `ChangeNotifier` to manage CMS states.
* Core state: List of courses, active course, list of chapters for the active course, list of lessons per chapter.
* Active Upload States: Tracks uploading percentage, status (`idle`, `uploading`, `paused`, `completed`, `error`), and upload speed.
* Methods:
  * Course CRUD operations (linked to Firestore `courses` collection or mock list).
  * Chapter CRUD operations (linked to `courses/{courseId}/chapters` subcollection or mock list).
  * Lesson CRUD operations (linked to `courses/{courseId}/chapters/{chapterId}/lessons` subcollection or mock list).
  * Upload management: trigger upload, pause upload, resume upload, cancel upload.
  * Reordering: handles updating orders of chapters and lessons (Firestore drag/drop re-indexing).

#### [MODIFY] [main.dart](file:///e:/projects/stustep-dashboard/stustep_admin/lib/main.dart)
* Add `CoursesProvider` to the `MultiProvider` list at the application root, injecting it beneath `AuthProvider` so it can react to authentication states and simulation mode flags.

---

### 4. UI Screens & Routing (`lib/screens/`)

#### [MODIFY] [dashboard_shell.dart](file:///e:/projects/stustep-dashboard/stustep_admin/lib/screens/dashboard_shell.dart)
* Add a new sidebar entry "Courses CMS" with an appropriate icon (e.g., `Icons.menu_book_rounded`).
* Integrate `CoursesPage` into the indexable page lists `_pages` and titles list `_pageTitles`.

#### [NEW] [courses_page.dart](file:///e:/projects/stustep-dashboard/stustep_admin/lib/screens/pages/courses_page.dart)
The main CMS console layout.
* **Course List View**: Displays all courses as rich glassmorphic cards (showing title, category, number of lessons, linked chat group). Provides an "Add Course" dialog and a "Delete Course" button.
* **Interactive 3-Column CMS Editor** (visible when a course card is selected):
  * **Column 1 (Left - Meta Editor)**: Form to modify course title, description, category, and input cover image URL or simulate a Cloudinary cover image upload. Includes a dropdown to link the course to an existing general chat room.
  * **Column 2 (Center - Curriculum Outline)**: Tree-like list showing Chapters with their child Lessons. Allows reordering using action buttons (move up/down), adding new chapters, and adding lessons inside chapters. Selecting a lesson opens Column 3.
  * **Column 3 (Right - Lesson Details Editor)**: Configures the selected lesson. Includes title and description fields, a dropdown for content type (Video/PDF), progress bars for file uploads (with Pause/Resume/Cancel buttons), duration inputs, and dropdown to link to a lesson-specific chat group.
  * *Navigation Control*: A back button to return from the editor to the main courses list.

---

## Verification Plan

### Automated Tests
* Run static analysis to verify there are no compilation or type errors:
  ```powershell
  flutter analyze
  ```

### Manual Verification
1. **Interactive Demo / Simulation Test**:
   - Run the application in Web Chrome.
   - Access the dashboard in simulation mode (demo admin credentials: `admin@stustep.com` / `admin123`).
   - Go to "Courses CMS". Create a new course, add chapters, add lessons.
   - Select a lesson, select "Video" content type, upload a dummy file, and test the uploading progress bar (observe progress updates, pause, resume, cancel).
   - Verify that modifying details in Column 1 and Column 3 correctly updates the lists in memory.
2. **Layout & Responsiveness Test**:
   - Resize the web browser window to test the three-column layout scaling (collapses cleanly into vertical tabs or scrollable screens on smaller viewport widths).
