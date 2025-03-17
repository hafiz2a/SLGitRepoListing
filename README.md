

# GitHub Repository Viewer Assignment

## Project Overview
This project follows the **MVVM (Model-View-ViewModel) pattern** with **Clean Architecture**, ensuring a modular and scalable approach to iOS app development. The app is divided into three key modules:

- **Networking Module** - Handles API requests and responses.
- **CoreData Module** - Manages local data storage using Core Data.
- **UI Component Module** - Contains reusable UI components.

## Project Architecture
The application is structured into the following layers:

- **View (UI Layer)**: Contains RepositoryListView, RepositoryDetailView, RepositoryCollectionTVC, and other UI components.
- **ViewController**: Initializes and manages views.
- **ViewModel (Business Logic Layer)**: Handles business logic and interacts with networking and database layers.
- **Model (Data Layer)**: Represents structured data used within the app.
- **Networking Module**: Fetches data from APIs.
- **CoreData Module**: Caches and retrieves data locally.

## Dependency Injection & Initialization
To use the **Networking Module** and **CoreData Module**, initialize instances as follows:

```swift
let networkService = NetworkService(authToken: TEMP_SAMPLE_GITHUB_TOKEN)
let coreDataService = CoreDataService(context: ConfiguareCoreData.shared.context)
```

> **Note**: `TEMP_SAMPLE_GITHUB_TOKEN` is required to fetch API data concurrently. Without it, you may encounter an *"API rate limit exceeded"* error.

### ViewModel Initialization
To ensure proper **dependency injection**, initialize the ViewModel as follows:

```swift
// Initialize ViewModel with dependencies
let viewModel = RepositoryVM(networkService: networkService, coreDataService: coreDataService)

// Inject ViewModel into ViewController
let repositoryListVC = RepositoryListVC(viewModel: viewModel)
```

## Features

### 1. Repository List (**RepositoryListVC**)
- Implements a **custom circular collection view** that provides an infinite scrolling effect with only 5 visible items.
- Uses **lazy loading** to fetch repositories in batches of **10 items**.
- Fetches commit history **concurrently in the background** using **DispatchGroup** for all visible cells only.
- Stores fetched commit data in **CoreData** to optimize future data retrieval.
- Users can select a repository to view its details.

### 2. Repository Details (**RepositoryDetailVC**)
- Displays detailed repository information.
- Checks **local CoreData first** for commit history.
- If commits are unavailable locally, an **API call fetches them and updates the database**.
- Presented as a **popup with a smooth cross-dissolve animation**.

## Concurrency & Performance Optimizations

- **Lazy Loading**: Efficiently fetches data to prevent unnecessary API calls.
- **DispatchGroup**: Handles multiple network requests concurrently, improving performance.
- **CoreData Caching**: Reduces redundant network requests and speeds up data retrieval.

## Special Features
- **MVVM with Clean Architecture** - Ensures separation of concerns and testability.
- **Core Data Persistence** - Stores fetched repository commits locally for offline access.
- **Efficient API Requests** - Uses **DispatchGroup** to handle multiple network requests asynchronously.

## Testing
Each layer in the architecture is designed for easy **unit testing**. The ViewModel can be tested independently using mock services:

```swift
let mockNetworkService = MockNetworkService()
let mockCoreDataService = MockCoreDataService()
let viewModel = RepositoryVM(networkService: mockNetworkService, coreDataService: mockCoreDataService)
```

This approach ensures that **network calls and Core Data operations do not interfere with business logic testing**.

## Conclusion
This project structure provides a **clean, scalable, and maintainable architecture** while ensuring a **smooth user experience and testability**.

