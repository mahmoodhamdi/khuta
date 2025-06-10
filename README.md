# Khuta – AI-Powered ADHD Assessment App 🧠

A modern Flutter application for assessing ADHD symptoms in children using the **Conners' Rating Scale** enhanced with AI recommendations. Khuta empowers parents and teachers to evaluate multiple children, receive personalized AI-powered insights, and generate detailed PDF reports.

## 1. 📱 App Overview

**Khuta** is a mobile application designed to help users screen for ADHD symptoms in children using the clinically validated Conners' Rating Scale, enhanced with advanced AI analysis for personalized recommendations.

Key features include:

- AI-powered assessment analysis using advanced machine learning models
- Personalized recommendations based on individual responses
- Comprehensive, shareable PDF reports for each evaluation
- Secure cloud data storage with end-to-end encryption
- Smart insights to help parents and teachers understand potential next steps

## 2. 🔐 Authentication

- Simple email and password authentication system
- Universal user access—no complex role management
- Complete data isolation—users can only access their own registered children and reports
- Secure local storage of credentials and user data
- full reset password functionality
- full email verification process

## 3. 🧠 How It Works

1. **Sign In / Sign Up:**  
   - Create an account or log in using your email and password
   - Verify your account

2. **Add Child Profile:**  
   Enter basic information about the child to be assessed

3. **ADHD Assessment:**  
   Complete the Conners' Rating Scale questionnaire

4. **Score Analysis:**  
   Receive an immediate calculation of the assessment results

5. **Report Generation:**  
   Get a detailed breakdown of scores and their interpretation

6. **Share Results:**  
   Export and securely share the assessment as a PDF

## 4. 🛠️ Technologies Used

- **Flutter:** Cross-platform mobile development framework
- **SQLite:** Secure local data storage
- **Bloc/Cubit:** State management solution
- **easy_localization:** Internationalization support (English & Arabic)
- **Google Fonts:** Typography with Poppins and Roboto
- **PDF Generator:** Report generation and export capability

## 5. 🎨 UI Design & Colors

Our color palette is carefully chosen to create a calming, accessible experience:

| Color        | Hex Code  | Usage                          | Psychology                        |
|-------------|-----------|--------------------------------|-----------------------------------|
| Soft Blue   | `#5A9BF6` | Buttons & highlights          | Calming, focused attention        |
| Calm Green  | `#A1C398` | Background & success states    | Relaxing, positive reinforcement  |
| Mild Yellow | `#F7D774` | Warnings & alerts             | Gentle attention without alarm    |
| Soft White  | `#FAFAFA` | Main background               | Clean, distraction-free           |
| Dark Gray   | `#333333` | Text & content                | High readability & accessibility  |

## 6. 📝 Typography

Our typeface selection prioritizes readability and accessibility:

- **Poppins:** Used for headings and titles
  - Modern, bold appearance
  - Clear hierarchy

- **Roboto:** Used for body text
  - Excellent readability
  - Clean and professional

- **Open Dyslexic:** Available as an accessibility option
  - Supports users with dyslexia
  - Toggle in app settings

## 7. 📂 Project Structure

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── features/
│   ├── auth/
│   ├── assessment/
│   ├── children/
│   └── reports/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── cubit/
└── main.dart
```

## 8. 📄 License

This project is open-source and available under the MIT License.

```
MIT License

Copyright (c) 2025 Khuta

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software...
```

## 9. 🚀 Future Features

We're constantly working to improve Khuta. Planned enhancements include:

- ☁️ Optional cloud backup functionality
- 📊 Enhanced analytics and visualization in reports
- 📱 Tablet-optimized layouts
- 🔍 Advanced search and filtering options
- 📈 Progress tracking over time
- 📎 File attachments for reports

## Getting Started 🚀

1. Clone the repository
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

## Contributing 🤝

We welcome contributions! Please feel free to submit a Pull Request.

---

For questions or feedback about Khuta, please open an issue in the repository.

### Made with ❤️ for better mental health awareness
