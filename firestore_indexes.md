# Firestore Query Optimization & Composite Indexes Guide

This document defines the composite indexes required for **ANHIRE** to perform complex queries (sorting and filtering) and details query optimizations to stay within Firestore's free tier (50,000 reads/day).

---

## 1. Required Composite Indexes

When running queries that filter by one field (e.g. `userId` or `collegeName`) and sort by another (e.g. `attemptedAt` or `readinessScore`), Firestore requires **Composite Indexes**.

Configure the following composite indexes in the Firebase Console (Firestore Database -> Indexes -> Composite -> Add Index):

### Index 1: Aptitude Results Date Sorting
- **Collection ID:** `aptitude_results`
- **Fields:**
  1. `userId` (Ascending)
  2. `attemptedAt` (Descending)
- **Query Supported:**
  `db.collection('aptitude_results').where('userId', '==', uid).orderBy('attemptedAt', 'desc')`

### Index 2: Interview Results Date Sorting
- **Collection ID:** `interview_results`
- **Fields:**
  1. `userId` (Ascending)
  2. `attemptedAt` (Descending)
- **Query Supported:**
  `db.collection('interview_results').where('userId', '==', uid).orderBy('attemptedAt', 'desc')`

### Index 3: Resume Reports Date Sorting
- **Collection ID:** `resume_reports`
- **Fields:**
  1. `userId` (Ascending)
  2. `analyzedAt` (Descending)
- **Query Supported:**
  `db.collection('resume_reports').where('userId', '==', uid).orderBy('analyzedAt', 'desc')`

### Index 4: Leaderboard College Ranks
- **Collection ID:** `leaderboard`
- **Fields:**
  1. `collegeName` (Ascending)
  2. `readinessScore` (Descending)
- **Query Supported:**
  `db.collection('leaderboard').where('collegeName', '==', college).orderBy('readinessScore', 'desc')`

---

## 2. Free-Tier Optimization Strategies

### A. Read-Through Caching via Hive
Instead of querying Firestore on every screen build, ANHIRE implements a local caching layer:
1. When a screen loads (e.g., Dashboard), the app immediately reads the cached JSON data from **Hive** (0ms latency, 0 database reads).
2. The app then initiates a background fetch. If Firestore returns updated data, it writes it to Hive and refreshes the UI.
3. This cuts down database reads by up to **80%** during repetitive app usage.

### B. Firestore Query Limits & Pagination
- The student leaderboard query uses `.limit(10)` to load only the top 10 users initially.
- When listing all registered students in the Admin Panel, pagination is implemented using query cursor hooks (`startAfterDocument`), downloading only 20 records at a time as the admin scrolls. This prevents downloading the entire database at once.

### C. Client-Side Evaluations
To preserve database writes and CPU usage:
- ATS resume scoring and mock interview keyword checks are calculated on-device in Dart.
- Only the finalized results are uploaded to Firestore.

---

## 3. Creating Indexes Automatically
When running the app in debug mode, if a query fails due to a missing index, a link will be printed in the console:
`https://console.firebase.google.com/project/.../database/firestore/indexes?...`
Tap this link to automatically open the Firebase Console with the exact fields pre-filled, then tap **Create Index**.
