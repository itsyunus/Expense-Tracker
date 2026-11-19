# Student Expense Tracker - Flutter Cross-Platform Client

A cross-platform personal finance tracking application engineered for mobile platforms with an offline-first architecture. Built with Flutter, Riverpod state management, and Hive embedded database storage.

## Architectural Highlights

- Architecture: Clean architecture with unidirectional Riverpod 2 state providers
- Storage Engine: Hive embedded NoSQL key-value database for millisecond-latency local persistence without network dependencies
- Routing: Declarative routing system powered by GoRouter
- Cross-Platform Target: Android, iOS, macOS, and Web

## Features

- Expense & Income Logging: Rapid entry with category tagging, currency conversion, and receipt attachment.
- Category Breakdown: Real-time aggregation of expenditure trends across education, housing, food, and recreation.
- Budget Guardrails: Visual indicators alerting users when spending approaches preconfigured thresholds.
- Offline Synchronization: All mutations commit to local storage immediately.

## Getting Started

```bash
# Clone repository
git clone https://github.com/itsyunus/Expense-Tracker.git
cd Expense-Tracker

# Get Flutter packages
flutter pub get

# Launch on connected device
flutter run
```
