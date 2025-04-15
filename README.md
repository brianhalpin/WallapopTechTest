# Marvel Heroes iOS Application Feature

This document outlines the technical decisions and architectural approach taken for implementing the Marvel Heroes list and detail feature.

## Core Architecture: MVVM with Layered Data Fetching

The application primarily follows the **Model-View-ViewModel (MVVM)** architecture pattern combined with a layered approach for data fetching.

* **Model:** Represents the data structures fetched from the API (e.g., `CharacterDataModel`, `CharacterDataContainer`).
* **View:**
    * `ListHeroesViewController` (UIKit): Manages the setup of UI components (`UITableView`, `UISearchController`), binds UI elements to the ViewModel's state using **Combine**, and forwards user interactions (selection, scrolling, search input) to the ViewModel.
    * `HeroDetailView` (**SwiftUI**): Displays detailed information about a selected hero. Hosted within a `UIHostingController` for integration with the UIKit navigation flow.
* **ViewModel (`ListHeroesViewModel`):** Contains the presentation logic and state (`heroes`, `isLoading`, `error`, `searchText`). It fetches data via Use Cases, processes user input, handles pagination logic, manages search filtering, and exposes state changes via **Combine** `@Published` properties for the View (ViewController) to observe. If this were a greenfield project, obviously the ViewController wouldn't be included with a true MVVM structure.

* **Data Layer:** A layered approach with protocol-based dependency injection ensures separation of concerns and high testability:
    * **`APIClient`:** Responsible for raw network communication with the Marvel API using **async/await**, handling URL construction, request parameters (including authentication), and JSON decoding.

## Key Technologies & Decisions

* **Swift Concurrency (`async/await`):** Adopted for network operations (`APIClient`) and throughout the data fetching layers up to the `ListHeroesViewModel`. This replaces older patterns like completion handlers or heavy `DispatchQueue` usage, resulting in asynchronous code that is significantly cleaner, easier to read and maintain, and less prone to errors with closure callbacks. UI updates triggered by asynchronous operations are safely dispatched to the main thread using `Task { @MainActor in ... }` or `await MainActor.run`.
* **Combine Framework:** Used for reactive programming, primarily to bind the `ListHeroesViewController`'s UI elements and state to the `@Published` properties of the `ListHeroesViewModel`. This creates a declarative flow for UI updates based on state changes.
* **SwiftUI:** Chosen for the `HeroDetailView` to leverage modern Apple UI framework practices. SwiftUI's declarative nature and features like live Previews accelerate UI development and testing.
* **Kingfisher:** Integrated via Swift Package Manager for efficient downloading, caching, and display of hero images in both the `ListHeroesTableViewCell` (UIKit) and `HeroDetailView` (SwiftUI).
* **Dependency Injection & Factories:** The `ListHeroesFactory` simplifies the creation of the `ListHeroesViewController` and injects the necessary dependencies (`ListHeroesViewModel` with its `GetHeroesUseCase`). Protocols are used extensively throughout the data layer and for injecting the Use Case into the ViewModel, facilitating mocking and unit testing.

## Features Implemented

* **Hero Detail View:** Navigates to a SwiftUI view showing more details (name, image, description) for a selected hero. Data is passed from the list, avoiding an additional network request.
* **Infinite Scrolling / Pagination:** Automatically fetches the next batch of heroes when the user scrolls near the bottom of the list. Logic is handled within the `ListHeroesViewModel`.
* **Search Functionality:** Includes a `UISearchController` allowing users to filter the list of heroes by name. Filtering logic is debounced and handled within the `ListHeroesViewModel`.

## Code Quality & Conventions

* **Constants:** Defined `APIConstants` to centralize API keys and endpoints (Note: See Security Considerations). Used enums or static constants within relevant classes (e.g., `ListHeroesView`) to avoid magic numbers/strings for layout values or identifiers.
* **Readability:** Focused on clear naming, separation of concerns (MVVM, data layers), and leveraging modern Swift features like `async/await` to improve code clarity.
* **Organization:** Grouped files logically (e.g., by feature or layer).

## Testing

* **Unit Tests:** Implemented unit tests focusing on the `ListHeroesViewModel` and the data layer components (`GetHeroesUseCase`, `MarvelRepository`, `MarvelDataSource`). Mocks were created using protocols to isolate units under test.
* **SwiftUI Previews:** Utilized SwiftUI Previews for the `HeroDetailView`, including a helper extension on `CharacterDataModel` to load sample data from a local JSON file (`CharacterPreviewData.json`) and a sample image for rapid UI development and verification.

## Requirements

* **Minimum iOS Version:** Set to **iOS 15.0**. This is primarily required for the usage of `async/await` and some SwiftUI View modifiers.

## Security Considerations

* **API Keys:** The current implementation likely stores API keys in `APIConstants`. **This is insecure for client-side applications, especially the private key.** For production, keys should *not* be embedded directly in the app binary.
