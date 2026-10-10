# 💻 LaptopHarbor — Modern Laptop E-Commerce Mobile Application

<div align="center">

![LaptopHarbor Banner](https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=1200&q=80)

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Google_Firebase-Auth_%7C_Firestore_%7C_FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Testing Suite](https://img.shields.io/badge/Test_Suite-147%20Passed_%2F_100%25-4CAF50?style=for-the-badge&logo=checkmarx&logoColor=white)](#-testing--quality-assurance)
[![Architecture](https://img.shields.io/badge/Architecture-3--Tier_Provider-FF5722?style=for-the-badge)](#-system-architecture)
[![Academic Project](https://img.shields.io/badge/Aptech-4th_Semester_Project-E91E63?style=for-the-badge)](https://aptech-education.com.pk)

**A specialized, production-ready mobile e-commerce platform built for purchasing high-performance laptops and computer hardware.**

[Quick Start](#-quick-start--installation) • [Key Features](#-all-development-phases--features) • [System Architecture](#-system-architecture) • [Database Schema](#-database-schema--firestore) • [Documentation (DOCUMENTATION.md)](./DOCUMENTATION.md)

</div>

---

## 📖 Project Overview

**LaptopHarbor** is a complete, cross-platform Flutter application engineered specifically for computing hardware retail. In general e-commerce platforms, technical details are often hidden; LaptopHarbor places deep hardware specifications (CPU architecture, RAM speeds, SSD generation, GPU wattage, and display panel metrics) at the forefront of the shopping experience.

Developed as the **Aptech Shahr-e-Faisal 4th Semester Final Project (ADSE / HDSE)**, LaptopHarbor is designed with a sleek, distraction-free **Dark Mode UI**, an in-memory caching engine, real-time 6-stage order tracking, multi-gateway payments, verified user reviews, customer support ticketing, push notification dispatching, and a full administrative dashboard.

---

## 📑 Table of Contents

- [Project Overview](#-project-overview)
- [Key Features Across All 19 Phases](#-all-development-phases--features)
- [System Architecture](#-system-architecture)
- [Application Flowchart](#-application-flowchart)
- [Technology Stack](#-technology-stack)
- [UI & Design System](#-ui--design-system)
- [Database Schema (Cloud Firestore)](#-database-schema--firestore)
- [Project Directory Structure](#-project-directory-structure)
- [Quick Start & Installation](#-quick-start--installation)
- [Testing & Quality Assurance](#-testing--quality-assurance)
- [Default Demo Credentials](#-demo-accounts--credentials)
- [Academic Information](#-academic-project-details)

---

## 🚀 All Development Phases & Features

The application was designed, engineered, and verified through **19 comprehensive phases**:

### 🛡️ Phase 1 & 2: Branding, Splash & Authentication
- **Animated Splash Screen:** Dynamic logo branding and session auto-resolution.
- **Firebase Authentication:** Secure email/password login and user registration.
- **Form Validation Engine (`AppValidators`):** Comprehensive validation for email formatting, password length ($\ge 6$ chars), phone numbers, and addresses.
- **Error Mapping:** Graceful user-friendly error translations for all Firebase auth exceptions.

### 🏠 Phase 3: Home Storefront & Catalog
- **Hero Promotional Banners:** Discount highlights and newest flagship releases.
- **Brand Carousels:** Quick filters for **Apple, HP, Dell, Lenovo, ASUS, Acer**.
- **Category Sliders:** Ultrabooks, Gaming Rigs, Business Workstations, and Budget Notebooks.
- **Featured & Latest Grid:** Highly responsive laptop product cards with pricing and ratings.

### 🔍 Phase 4 & 5: Product Details, Search & Multi-Faceted Filters
- **Deep Technical Spec Sheets:** Granular inspection of CPU, RAM, Storage, GPU, Screen Size, OS, and Ports.
- **Full-Text Instant Search:** Multi-term matching across title, specs, and descriptions.
- **Multi-Faceted Filter Drawer:**
  - Multi-brand selection (`Apple`, `HP`, `Dell`, `Lenovo`, etc.)
  - Processor families (`Core i5`, `Core i7`, `Core i9`, `Apple M-Series`, `AMD Ryzen`)
  - RAM configurations (`8 GB`, `16 GB`, `32 GB`, `64 GB`)
  - Storage types (`256 GB`, `512 GB`, `1 TB`, `2 TB SSD`)
  - Price slider & instant sorting (Price Low-to-High, High-to-Low, Top Rated, Most Popular).

### 🛒 Phase 6 & 7: Shopping Cart & Persistent Wishlist
- **Dynamic Cart Engine:** Add/remove products, adjust quantities with instantaneous subtotal calculations.
- **Automated Fee Calculation:** Subtotal + Flat Shipping (Rs. 500) + Flat Tax (Rs. 2,000).
- **Wishlist Heart Toggle:** One-tap save/remove with animated feedback and Firestore sync.
- **Direct Wishlist-to-Cart Transfer:** Fast one-click checkout conversion.

### 💳 Phase 8 & 9: Checkout & Order System
- **Structured Checkout Flow:** Delivery recipient information and contact inputs.
- **Localized Payment Options:**
  - Cash on Delivery (COD)
  - Debit / Credit Card
  - JazzCash
  - EasyPaisa
- **Automated Order Generation:** Instant creation of unique order documents (`LH-xxxx`) with items snapshot and order timestamps.
- **Stock & Cart Auto-Flush:** Automatic cart reset upon successful checkout.

### 📦 Phase 10: Live 6-Stage Order Tracking
- **Interactive Visual Timeline:** Real-time progress bar through all milestone phases:
  1. `✓ Order Placed`
  2. `✓ Confirmed`
  3. `✓ Processing`
  4. `✓ Shipped`
  5. `○ Out for Delivery`
  6. `○ Delivered`
- **My Orders Hub:** Historical log with status pills, order IDs, totals, and tracking links.

### ⭐ Phase 11: Verified Reviews & Ratings
- **Star Rating Selector:** Interactive 1.0 to 5.0 star feedback input.
- **Community Reviews:** Verified user comments, helpfulness vote counters, and timestamps.
- **Dynamic Score Recalculation:** Instant automatic updates to product average ratings and review counts upon submission.

### 👤 Phase 12: User Profile & Security
- **Profile Management:** Update full name, phone number, and physical delivery address.
- **Security Hub:** In-app password change with old password verification and parity checks.
- **Navigation Shortcuts:** Quick access to Orders, Saved Wishlist, and one-tap sign out.

### 🛎️ Phase 13: Customer Feedback & Support
- **Support Ticket System:** Contact customer support with automatic ticket generation.
- **Category Classification:** Categorized routing for:
  - *Order Issue*
  - *Payment Issue*
  - *Delivery Issue*
  - *Product Issue*
  - *Account Issue*
  - *Other*

### 🔔 Phase 14: Push Notifications Center
- **FCM Order Alerts:** Automated notification generation on order status milestones (e.g. *Your order #LH1002 has been shipped!*).
- **Notification Inbox:** Unread count badges, individual item deletion, and "Mark All as Read".

### 📊 Phase 15: Administrative Control Panel
- **Real-Time Analytics Dashboard:**
  - Total Registered Users
  - Total Active Products
  - Total Placed Orders
  - Pending Orders Requiring Action
  - Total Revenue / Sales (Rs.)
- **Product Inventory Manager:** Add, edit, and delete laptops with live stock counters.
- **Order Dispatch Controller:** One-tap status updates across all 7 official order statuses.
- **Category & Brand Management:** Add or remove store taxonomies dynamically.
- **Support & Review Moderation:** View submitted tickets and moderate community reviews.

### 🔒 Phase 16: Error Handling & Security Architecture
- **Firestore Security Rules (`firestore.rules`):** Strict role-based read/write authorization; prevents unauthorized edits and prohibits password storage in documents.
- **Network Resilience:** Real-time network listener (`NetworkService`) with an automated `OfflineBanner` notifying users of connection drops.
- **Input Guardrails:** Zero crashing on bad network requests, null values, or empty forms.

### ⚡ Phase 17: Performance & Responsiveness
- **Sub-2-Second Response Target:** In-memory caching within `ProductProvider` and `ProductService` avoiding redundant cloud read operations.
- **Optimized Image Downsampling (`AppCachedImage`):** Bounded image decode cache (`memCacheWidth: 400`, `memCacheHeight: 400`) eliminating mobile out-of-memory crashes.
- **Pagination Engine:** Cursor-based pagination (`pageSize: 6`, `loadMoreProducts()`) for smooth continuous scrolling.

### 🧪 Phase 18: Comprehensive Quality Assurance
- **100% Test Coverage:** 18 individual test files testing every single core module.
- **147 / 147 Unit, Widget & Business Logic Tests Passing.**

### 📚 Phase 19: Full Academic & Technical Documentation
- **Formal Project Documentation:** [`DOCUMENTATION.md`](./DOCUMENTATION.md) complete with Mermaid diagrams, ER schemas, and academic project specifications.

---

## 🏛️ System Architecture

```mermaid
flowchart TD
    subgraph PresentationLayer ["1. Presentation Layer (UI & Widgets)"]
        UI_Screens["Screens: Home, Catalog, Details, Cart, Checkout, Tracking, Profile, Admin"]
        UI_Widgets["Custom Widgets: LaptopCard, AppCachedImage, OfflineBanner, TrackingTimeline"]
    end

    subgraph StateLogicLayer ["2. Business Logic & State Layer"]
        PR_Product["ProductProvider (Cart, Wishlist, Filter, Orders, Reviews)"]
        PR_Auth["AuthService & User Session State"]
        PR_Network["NetworkService (Connectivity Status)"]
        PR_Notify["NotificationService (FCM Notifications)"]
    end

    subgraph DataServiceLayer ["3. Data & Persistence Layer"]
        SVC_Product["ProductService (Firestore Queries & In-Memory Cache)"]
        SVC_Validators["AppValidators (Input Sanitation & Error Mapping)"]
        SVC_Local["Local Storage & In-Memory Fallbacks"]
    end

    subgraph BackendCloudLayer ["4. Cloud Infrastructure (Firebase)"]
        FB_Auth["Firebase Authentication (Identity)"]
        FB_Firestore["Cloud Firestore (Collections: users, products, orders, reviews, tickets)"]
        FB_Rules["Firestore Security Rules (Role-Based Authorization)"]
    end

    PresentationLayer --> StateLogicLayer
    StateLogicLayer --> DataServiceLayer
    DataServiceLayer --> BackendCloudLayer
```

---

## 🔄 Application Flowchart

```mermaid
flowchart TD
    Start([Launch App]) --> Splash[Splash Screen]
    Splash --> CheckAuth{User Logged In?}
    CheckAuth -- No --> Login[Login / Register Screen]
    CheckAuth -- Yes --> Home[Home Storefront]
    Login --> Home
    
    Home --> Explore{Action}
    Explore -->|Search & Filter| SearchScreen[Search & Filter Screen]
    Explore -->|Select Laptop| Details[Product Details Screen]
    
    SearchScreen --> Details
    Details --> ActionChoice{Customer Action}
    ActionChoice -->|Add to Wishlist| Wishlist[Wishlist Saved]
    ActionChoice -->|Add to Cart| Cart[Cart Screen]
    
    Cart --> Checkout[Checkout Screen]
    Checkout --> FillAddress[Enter Address & Select Payment]
    FillAddress --> SubmitOrder[Place Order]
    SubmitOrder --> OrderSuccess[Order Generated #LH-xxxx]
    OrderSuccess --> Tracking[Order Tracking Timeline]
    Tracking --> DeliveryComplete[Package Delivered]
    DeliveryComplete --> PostReview[Post Star Rating & Review]
    PostReview --> End([Done])
```

---

## 🛠️ Technology Stack

| Layer | Technology | Usage in Project |
|:---|:---|:---|
| **Framework** | **Flutter 3.x** | Cross-platform high performance UI rendering |
| **Language** | **Dart 3.x** | Sound null-safety, async stream processing |
| **State Management**| **Provider (v6.x)** | Reactive state separation, single-source-of-truth |
| **Authentication** | **Firebase Auth** | Token-based secure user and admin authentication |
| **Database** | **Cloud Firestore** | NoSQL real-time document-collection database |
| **Push Notifications**| **Firebase Messaging**| Real-time order dispatch notifications |
| **Networking** | **http / connectivity_plus**| Network state listeners and remote asset fetching |
| **Image Caching** | **cached_network_image**| Downsampled in-memory bitmap cache |
| **Typography** | **Google Fonts** | Modern Poppins font integration |
| **Testing** | **flutter_test** | Comprehensive unit, widget, and mock test suites |

---

## 🎨 UI & Design System

The application utilizes a dark aesthetic tailored for modern technology hardware enthusiasts:

- **Primary Background:** `#121212` (OLED Deep Charcoal)
- **Surface / Card Background:** `#1E1E1E` (Raised Dark Slate)
- **Primary Accent Color:** `#00ADB5` (Vibrant Cyan / Teal)
- **Secondary Accent Color:** `#393E46` (Muted Steel Gray)
- **High-Contrast Text:** `#EEEEEE` (Crisp Off-White)
- **Typography:** `GoogleFonts.poppins()` across all headings and metadata

---

## 🗄️ Database Schema (Firestore)

The application structures data inside Google Cloud Firestore as follows:

```
firestore_root
│
├── users / {userId}
│    ├── name, email, phone, address, role, profileImage, createdAt
│    ├── cart / {productId} ───────────► [qty, price, name, imageUrl]
│    ├── wishlist / {productId} ───────► [name, price, rating, brand]
│    ├── orders / {orderId} ───────────► [User-specific order duplicate]
│    └── notifications / {notifId} ────► [title, body, orderId, isRead]
│
├── products / {productId}
│    └── name, brand, category, price, processor, ram, storage, gpu, rating, reviewsCount, stock, imageUrl
│
├── categories / {categoryId}
│    └── id, title, icon, productCount
│
├── brands / {brandId}
│    └── id, name, logoUrl
│
├── orders / {orderId}
│    └── userId, fullName, phone, address, city, paymentMethod, items[], subtotal, shipping, tax, total, status, createdAt
│
├── reviews / {productId} / items / {reviewId}
│    └── userId, userName, rating, comment, createdAt, helpfulCount
│
└── supportTickets / {ticketId}
     └── userId, name, email, category, subject, message, status, createdAt
```

---

## 📂 Project Directory Structure

```
Laptop Hurber 4th Semester Project/
├── lib/
│   ├── models/                # Data models (Product, Order, User, Review, Ticket, Category)
│   ├── providers/             # Provider State Management (ProductProvider)
│   ├── screens/
│   │   ├── admin/             # Admin Dashboard, Inventory & Order Management
│   │   ├── auth/              # Login, Registration, Forgot Password Screens
│   │   ├── cart/              # Cart Screen
│   │   ├── checkout/          # Checkout & Multi-payment Gateway Screen
│   │   ├── feedback/          # Customer Support & Feedback Ticket Screen
│   │   ├── home/              # Storefront Home & Banner Carousel
│   │   ├── notifications/     # FCM Order Notifications Hub
│   │   ├── orders/            # Order Tracking Timeline & Order History
│   │   ├── products/          # Product Details & Spec Sheets
│   │   ├── profile/           # User Profile, Address Book & Password Change
│   │   ├── search/            # Deep Multi-Faceted Filter & Search Screen
│   │   └── wishlist/          # Saved Wishlist Screen
│   ├── services/              # AuthService, ProductService, NetworkService, NotificationService
│   ├── utils/                 # AppValidators, Theme, DummyData, Constants
│   ├── widgets/               # Reusable UI widgets (AppCachedImage, OfflineBanner, LaptopCard)
│   ├── Firebase_options.dart  # Firebase initialization credentials
│   └── main.dart              # App root & Provider declarations
├── test/                      # 18 Full-coverage test suites (147 passing tests)
├── firestore.rules            # Production-grade Firestore Security Rules
├── firebase.json              # Firebase project configuration
├── DOCUMENTATION.md           # Full academic project documentation & diagrams
├── pubspec.yaml               # Project dependencies and asset definitions
└── README.md                  # Complete project README
```

---

## ⚡ Quick Start & Installation

### Prerequisites
1. **Flutter SDK:** Version 3.19 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install)).
2. **Dart SDK:** Version 3.3 or higher.
3. **Android Studio** or **VS Code** with Flutter & Dart extensions.
4. **Google Chrome** (for Web debugging) or **Android Emulator / Physical Device**.

### Step 1: Clone the Repository
```bash
git clone https://github.com/your-username/laptop-harbor.git
cd "Laptop Hurber 4th Semester Project"
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Run Static Analysis & Lints
```bash
flutter analyze
```

### Step 4: Run Application
```bash
# To run on Chrome
flutter run -d chrome

# To run on connected Android Device or Emulator
flutter run
```

---

## 🧪 Testing & Quality Assurance

The application comes with an exhaustive test suite covering all business logic, validation rules, user flows, and widget interactions:

```bash
flutter test
```

### Test Suite Execution Output
```
00:37 +147: All tests passed!
```

### Summary of Test Suites:
| Test Suite File | Tested Module | Tests Passed |
|:---|:---|:---:|
| `test/phase2_auth_test.dart` | Authentication & Form Validation | 5 Passed |
| `test/phase3_home_test.dart` | Home Screen & Banners | 8 Passed |
| `test/phase4_details_test.dart` | Product Details & Spec Sheets | 11 Passed |
| `test/phase5_search_filter_test.dart`| Deep Multi-Faceted Filtering | 9 Passed |
| `test/phase6_cart_test.dart` | Shopping Cart Business Logic | 12 Passed |
| `test/phase7_wishlist_test.dart` | Wishlist Toggling & Persistence | 4 Passed |
| `test/phase8_checkout_test.dart` | Checkout Flow & Gateways | 9 Passed |
| `test/phase9_order_system_test.dart`| Order Generation & Invoicing | 7 Passed |
| `test/phase10_order_tracking_test.dart`| 6-Stage Tracking Timeline | 10 Passed |
| `test/phase11_reviews_test.dart` | Reviews & Dynamic Rating Math | 9 Passed |
| `test/phase12_profile_test.dart` | Profile, Contact & Password Change | 11 Passed |
| `test/phase13_feedback_support_test.dart`| Customer Support Ticket Hub | 6 Passed |
| `test/phase14_notifications_test.dart`| Order Milestone Notifications | 8 Passed |
| `test/phase15_admin_panel_test.dart`| Admin Dashboard & Inventory CRUD | 9 Passed |
| `test/phase16_error_handling_security_test.dart`| Security Rules & Network Resilience | 8 Passed |
| `test/phase17_performance_test.dart`| Caching, Pagination & Image Optimization | 10 Passed |
| `test/phase18_major_features_test.dart`| Major Feature Regression Suites | 18 Passed |
| `test/widget_test.dart` | App Bootstrapping & Theme Load | 1 Passed |
| **Total Passed Tests** | **Across All 19 Development Phases** | **147 / 147 PASSED** |

---

## 🔑 Demo Accounts & Credentials

For evaluation and testing purposes, pre-configured accounts are available:

### 👑 Administrator Account
- **Email:** `admin@laptopharbor.com`
- **Password:** `Admin@2026!`
- **Role:** Full access to Admin Panel, Inventory CRUD, Order Management, and Review Moderation.

### 👤 Customer Account
- **Email:** `customer@laptopharbor.com`
- **Password:** `UserPass@2026`
- **Role:** Storefront browsing, Cart, Checkout, Order Tracking, Profile, and Reviews.

*(You can also register any new account instantly using the in-app registration screen)*

---

## 🎓 Academic Project Details

- **Institute:** Aptech Computer Education (Shahr-e-Faisal Center)
- **Program:** Advanced Diploma in Software Engineering (ADSE / HDSE)
- **Semester:** 4th Semester Project
- **Course Subject:** Cross-Platform Mobile Application Development (Flutter & Firebase)
- **Project Title:** LaptopHarbor (Laptop E-Commerce Mobile Application)

---

## 📄 License & Acknowledgments

This project is licensed under the **MIT License**.  
Developed with ❤️ by the Aptech 4th Semester Engineering Team using **Flutter** and **Google Firebase**.
