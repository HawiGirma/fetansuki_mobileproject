# System Documentation - Fetansuki Mobile Project

## 1. Project Overview
Fetansuki is a mobile application developed using Flutter, designed to help small business owners (specifically likely shops or kiosks) manage their inventory, sales (receipts), and credit records. The application features user authentication, a dashboard for business analytics, inventory management, and credit tracking.

## 2. Technical Architecture
The application follows a **Clean Architecture** principle, separating code into layers to ensure maintainability, testability, and scalability.

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod (with Code Generation)
- **Navigation**: GoRouter
- **Backend**: Firebase (Authentication & Firestore Database)
- **Design System**: Custom styling with support for Light/Dark modes (implied by typical setups) and Localization (Amharic/English).

### Architecture Layers (per feature):
1.  **Presentation Layer**:
    -   **Pages/Screens**: The UI views shown to the user.
    -   **Widgets**: Reusable UI components.
    -   **Providers/Controllers**: State management logic linking UI to Domain.
2.  **Domain Layer** (Business Logic):
    -   **Entities**: Pure Dart classes representing data objects.
    -   **Repositories (Interfaces)**: Abstract definitions of data operations.
    -   **Use Cases**: Specific business rules/actions (e.g., `LoginUseCase`).
3.  **Data Layer** (implementation):
    -   **Models**: Data Transfer Objects (DTOs) handling JSON/Firestore serialization.
    -   **Repositories (Implementation)**: Concrete implementations of Domain repositories.
    -   **Data Sources**: Direct interactions with APIs or Databases (e.g., Firestore).

## 3. Directory Structure (`lib/`)
The project is organized by **Feature**:

-   `core/`: Shared utilities, error handling, constants, and global widgets.
-   `features/`:
    -   `auth/`: Authentication (Login, Signup, User management).
    -   `dashboard/`: Home screen, analytics, and summary widgets.
    -   `stock/`: Inventory management (Add/Update/Delete products).
    -   `credit/`: Customer credit tracking and management.
    -   `receipt/`: Sales recording and receipt generation.
    -   `settings/`: App settings (Language, Theme).
    -   `main_nav/`: Bottom navigation handler.
    -   `notifications/`: App notifications.
    -   `splash/`: Initial splash screen logic.
-   `main.dart`: Application entry point and configuration.

## 4. Database Structure (Firebase Firestore)
The application uses a NoSQL document-based database. Below are the primary collections and their document schemas.

### 4.1 Collection: `users`
Stores user profile information.
-   **Document ID**: User UID (from Authentication)
-   **Fields**:
    -   `id` (string): Unique identifier.
    -   `email` (string): User email address.
    -   `name` (string): User display name.

### 4.2 Collection: `stock_items`
Stores inventory products.
-   **Document ID**: Auto-generated string
-   **Fields**:
    -   `id` (string): Unique identifier.
    -   `user_id` (string): References the owner (`users` collection).
    -   `name` (string): Product name.
    -   `image_url` (string): URL to the product image (likely Firebase Storage).
    -   `price` (number): Unit price.
    -   `quantity` (string/number): Available stock count.
    -   `description` (string): Optional product details.
    -   `created_at` (timestamp): Record creation time.
    -   `updated_at` (timestamp): Record update time.

### 4.3 Collection: `receipts`
Stores sales transactions and receipts.
-   **Document ID**: Auto-generated string
-   **Fields**:
    -   `id` (string): Unique identifier.
    -   `sale_id` (string): Linked sale identifier.
    -   `user_id` (string): References the seller (`users` collection).
    -   `product_name` (string): Name of item sold.
    -   `unit_price` (number): Price at time of sale.
    -   `quantity` (number): Amount sold.
    -   `buyer_address` (string): Customer address/location.
    -   `buyer_name` (string, optional): Customer name.
    -   `buyer_phone` (string, optional): Customer contact.
    -   `subtotal` (number): Price * Quantity.
    -   `vat_amount` (number): Calculated tax.
    -   `total` (number): Final amount charged.
    -   `payment_type` (string): e.g., 'Cash', 'Credit'.
    -   `timestamp` (timestamp): Date of sale.

### 4.4 Collection: `credits`
Stores records of money owed by customers.
-   **Document ID**: Auto-generated string
-   **Fields**:
    -   `id` (string): Unique identifier.
    -   `user_id` (string): References the shop owner.
    -   `name` (string): Customer name.
    -   `amount` (string): Monetary amount owed (mapped from quantity in code, typically).
    -   `status` (string): e.g., 'pending', 'paid'.
    -   `image_url` (string, optional): Customer or record image.
    -   `due_date` (timestamp): When payment is expected.
    -   `updated_at` (timestamp): Last modification time.

## 5. Key Workflows
1.  **Authentication**: Users sign in via Email/Password or Google. Account data is synced to the `users` collection.
2.  **Inventory**: Users add items to `stock_items`. The app fetches this list to display available products.
3.  **Sales**: When a sale is made:
    -   A `Receipt` record is created in `receipts`.
    -   If Payment Type is 'Credit', a `Credit` record is created in `credits`.
    -   (Ideally) Stock quantity is deducted from `stock_items`.
4.  **Analytics**: The Dashboard aggregates data from `receipts` (Total Sales) and `credits` (Active Debts) to show business health.
