# PetMatchApp-iOS

A SwiftUI-based iOS application for pet matching, built with Clean Architecture principles.

## Architecture

This project follows Clean Architecture patterns with SwiftUI and Combine. The architecture is organized into three main layers:

### Presentation Layer
- SwiftUI views with no business logic
- State-driven UI updates
- User actions forwarded to Interactors

### Business Logic Layer
- Interactors handling business logic
- Centralized AppState for data management
- Native SwiftUI dependency injection

### Data Access Layer
- Repositories for CRUD operations
- Async API using Combine
- Local persistence with SwiftData

## Key Features
* Modern iOS stack with SwiftUI and Combine
* Clean Architecture implementation
* Programmatic navigation with deep linking
* Full test coverage
* Async/await networking
* SwiftData persistence

## Development

The project uses:
* SwiftUI for UI
* Combine for reactive programming
* SwiftData for persistence
* Async/await for networking
* ViewInspector for UI testing

## Getting Started

1. Clone the repository
2. Open the .xcodeproj file
3. Build and run the project

## Requirements
* iOS 15.0+
* Xcode 13.0+
* Swift 5.5+
