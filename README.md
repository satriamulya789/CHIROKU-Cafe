# ☕ CHIROKU Café Management System

[![Flutter Version](https://img.shields.io/badge/Flutter-v3.8.0+-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)](https://supabase.com)
[![GetX](https://img.shields.io/badge/State%20Management-GetX-8039E8?logo=getx)](https://pub.dev/packages/get)

**CHIROKU Café** is a modern Point of Sale (POS) and Management System built with Flutter. It streamlines cafe operations including order management, inventory tracking, financial reporting, and thermal printing for receipts.

---

## ✨ Features

- **🔐 Dual Role Access**: Separate interfaces for **Admin** and **Cashier**.
- **🛒 Smart POS**: Real-time cart management with stock validation.
- **📊 Admin Dashboard**: High-level reports and transaction history.
- **🖨️ Thermal Printer Integration**: Support for Bluetooth thermal printers with real-time discovery.
- **🏷️ Discount & Promo**: Manage active discounts directly from the dashboard.
- **💳 QRIS Payment**: Integrated QRIS payment setup.
- **🔔 Push Notifications**: Stay updated with order status and system alerts.

---

## 👥 User Roles & Credentials

The system supports two primary roles with different access levels:

### 👨‍💼 Admin
The Admin has full control over the system, including user management, menu management, and financial reporting.
- **Email**: `adminchirokucafe@gmail.com`
- **Password**: `Admin@123`

### 🧑‍🍳 Cashier
Cashiers focus on taking orders and processing payments. 
- **Registration**: New cashiers can register an account directly through the **Sign Up** screen in the application.

---

## 📱 Minimal Device Requirements

| Requirement | Android | iOS |
|-------------|---------|-----|
| **OS Version** | Android 7.0 (Nougat) or higher | iOS 12.0 or higher |
| **RAM** | 2 GB Minimum | 2 GB Minimum |
| **Hardware** | Bluetooth 4.0+ (for Printing) | Bluetooth 4.0+ (for Printing) |
| **Permissions** | Camera, Location, Bluetooth Scan & Connect | Camera, Bluetooth |

---

## 🛠️ Getting Started

### 1. Clone the Project
```bash
git clone https://github.com/satriamulya789/CHIROKU-Cafe.git
cd CHIROKU-Cafe
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Environment Variables
Create a `.env` file in the root directory and add your Supabase credentials:
```env
SUPABASE_URL=YOUR_SUPABASE_PROJECT_URL
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

---

## ☁️ Supabase Configuration

This project uses Supabase as its backend. You need to setup the following tables in your Supabase project:

1.  **Profiles**: For user role management (Admin/Cashier).
2.  **Categories**: Product categorization.
3.  **Menus**: Database for food and beverages including stock management.
4.  **Tables**: Management of cafe table availability.
5.  **Discounts**: Active promotion rules.
6.  **Transactions**: Sales records and order history.
7.  **Cart Items**: Persistent cart for active sessions.

> **Note**: Ensure RLS (Row Level Security) is configured appropriately for each role.

---

## 🤝 Contribution

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

## 📬 Contact

**Satria Mulya** - [satriamulya789](https://github.com/satriamulya789)  
Project Link: [https://github.com/satriamulya789/CHIROKU-Cafe](https://github.com/satriamulya789/CHIROKU-Cafe)
