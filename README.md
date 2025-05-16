# 🏨 Fatiel – Hotel Booking & Management App

**Fatiel** is a real-world hotel booking application built with **Flutter** and **Firebase**, supporting multi-role access:  
- 🧑‍💼 Admin  
- 🏨 Hotel Owner  
- 🧳 Visitor  

Admins can manage hotels, approve subscriptions, track earnings, and view dashboards. Visitors can search and book hotels, while hotel owners list and manage their properties (once subscribed).

---

## 🚀 Features

- 🔐 Role-based access: Admin, Hotel Owner, Visitor
- 🏨 Manual hotel subscription system (`isSubscribed`)
- 📊 Admin dashboard with earnings, booking stats, and charts
- 📅 Booking and favorites filtering by hotel subscription status
- ☁️ Cloudinary integration for image uploads
- 🔥 Firebase for Auth, Firestore
- 📱 Flutter + Bloc architecture

---

## 🛠️ Getting Started

### 1. 🔁 Clone the Repository

```bash
git clone https://github.com/creeeasy/hotel-booking-app.git
cd fatiel-app
```

### 2. 📦 Install Dependencies

```bash
flutter pub get
```

### 3. 🔐 Setup `.env` File

Create a `.env` file in the root directory and include the following:

```env
# Cloudinary config
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_secret
CLOUDINARY_UPLOAD_PRESET=your_upload_preset

# Firebase Web
API_KEY_WEB=your_api_key_web
APP_ID_WEB=your_app_id_web
MESSAGING_SENDER_ID=your_sender_id
PROJECT_ID=your_project_id
AUTH_DOMAIN=your_auth_domain
STORAGE_BUCKET=your_storage_bucket
MEASUREMENT_ID=your_measurement_id

# Firebase Android
API_KEY_ANDROID=your_api_key_android
APP_ID_ANDROID=your_app_id_android

# Firebase iOS
API_KEY_IOS=your_api_key_ios
APP_ID_IOS=your_app_id_ios
IOS_BUNDLE_ID=com.example.fatiel
```

> ⚠️ Be sure to keep `.env` out of version control by adding it to `.gitignore`.

### 4. 🧱 Configure Firebase

Ensure your Firebase project is set up correctly for all platforms:

- Add `google-services.json` to `android/app`
- Add `GoogleService-Info.plist` to `ios/Runner`
- Enable Firestore, Authentication, and Storage in Firebase Console

### 5. ▶️ Run the App

#### On Web

```bash
flutter run -d chrome
```

#### On Android

```bash
flutter run -d android
```

#### On iOS

```bash
flutter run -d ios
```

---

## 📁 Project Structure

```
lib/
├── auth/               # Role-based auth logic
├── models/             # Data models (Hotel, Visitor, Booking, etc.)
├── services/           # Firebase + Cloudinary logic
├── pages/              # Admin, Hotel, Visitor UI screens
├── widgets/            # Shared UI components
├── env.dart            # Environment loader (dotenv)
└── main.dart           # App entry
```

---

## 🧠 Notes

- Admins see all data (subscribed + unsubscribed hotels)
- Visitors can only interact with subscribed hotels
- Hotel owners must be subscribed (by admin) to activate room listings

---

## 📮 Contact

Developed by [Alaa Eddine Ourmassi]  
[LinkedIn](https://linkedin.com/in/aeourmassi) • [Email](mailto:aeourmassi@gmail.com)
