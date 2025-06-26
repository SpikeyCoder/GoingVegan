# GoingVegan

This is a SwiftUI application for iOS that helps users discover vegan recipes and restaurants.

## Features

*   **Recipe Discovery:** Browse a list of vegan recipes.
*   **Restaurant Finder:** Find vegan-friendly restaurants on a map.
*   **User Authentication:** Secure sign-in with Apple and Google.
*   **Date Picker:** A custom multi-date picker component.

## Architecture

The application is built with SwiftUI and utilizes several key components:

*   **SwiftUI:** The core framework for building the user interface.
*   **Firebase:** Used for user authentication services (Google Sign-In).
*   **Core Data:** For local data persistence.
*   **MapKit:** To display restaurant locations.

The project is structured into several modules:

*   `GoingVeganApp.swift`: The main entry point of the application.
*   `ContentView.swift`: The root view of the application.
*   `SignIn/`: Contains all the views and view models for handling user authentication.
*   `Recipes/`: Contains the views for displaying recipe lists and details.
*   `Restaurants/`: Contains the map views for finding restaurants.
*   `MDP Components/`: Reusable UI components for a multi-date picker.

## Getting Started

To run this project, you will need Xcode and an Apple Developer account.

1.  Clone the repository.
2.  Open the `GoingVegan.xcodeproj` file in Xcode.
3.  Set up your Firebase project and add your `GoogleService-Info.plist` file to the `GoingVegan` directory.
4.  Configure your signing certificates in Xcode.
5.  Build and run the application on a simulator or a physical device.
