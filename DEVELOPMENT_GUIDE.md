# RewardBrick App - Complete Development Guide

## 🎯 Project Summary

You're building an **Offer Wall + Surveys + Games + Ads App** with:
- ✅ Reward points system
- ✅ Multiple earning methods (offers, surveys, games, ads)
- ✅ Withdrawal system (UPI, PayPal, Gift Cards, Talktime)
- ✅ User profile & referral system
- ✅ Beautiful neomorphic design (Sky Blue + Creamy colors)

---

## 📁 Current Project Structure

```
rewardbrick_app/
├── lib/
│   ├── main.dart                    (Entry point)
│   ├── theme_design_system.dart     (NEW: Design colors & components)
│   ├── screens/
│   │   ├── auth_screen.dart         (Login/Signup)
│   │   ├── dashboard_screen.dart    (Home with offers)
│   │   ├── content_webview_screen.dart (Webview for offers)
│   │   └── offer_detail_screen.dart (Offer details)
│   ├── services/
│   │   ├── api_service.dart         (API calls)
│   │   └── ad_service.dart          (Google Ads)
│   └── assets/
│       └── illustrations/
├── pubspec.yaml                      (Dependencies)
├── BACKEND_SETUP_PROMPT.md          (NEW: Backend guide)
└── README.md (this file)
```

---

## 🎨 Design Direction

### Color Scheme (Neomorphism Style)
```
Primary:      Sky Blue (#87CEEB) + Light Sky Blue (#B0E0E6)
Accent:       Creamy (#F5E6D3) + Peach (#FFD4B4)
Background:   Soft Cream (#FAF8F3)
Text:         Dark Gray (#2C3E50)
Success:      Green (#4CAF50)
Error:        Red (#E91E63)
```

### Design System
- ✅ Soft UI (Neomorphism) - Subtle shadows & highlights
- ✅ Rounded corners (12-20px)
- ✅ Light, muted colors
- ✅ Gradient accents
- ✅ No harsh contrast
- ✅ Accessible typography (Google Fonts - Poppins)

**File Created**: `lib/theme_design_system.dart` - Copy this to your ThemeData!

---

## 🛠 What You Need From External Sources

### 1. **Offer Providers** (You must have/setup API keys)

| Provider | What | Sign Up |
|----------|------|---------|
| **AdMantum** | Affiliate offers | https://admantum.com (App ID: 52007) |
| **CPX Research** | Survey offers | Already configured |
| **Google AdMob** | Banner/Video ads | Google Play Console |
| **Survey Providers** | Surveys | SurveySparrow, Qualtrics, etc. |
| **Game Providers** | Playable games | AppLift, Mintegral, etc. |

### 2. **Payment Gateways** (For withdrawals)

| Method | Provider | Requirements |
|--------|----------|---|
| **UPI** | Razorpay / PayU | Business account + API keys |
| **PayPal** | PayPal | PayPal Business account |
| **Gift Cards** | Amazon / Google Play | B2B API integration |
| **Talktime** | Airtel / Jio | Telecom API access |

### 3. **Backend Database** (You must setup)
- MongoDB Atlas (or your own MongoDB)
- Collections as defined in BACKEND_SETUP_PROMPT.md

### 4. **Backend Server** (You must deploy)
- Node.js + Express + TypeScript
- Currently on Render: https://rewardbrick-api.onrender.com
- All endpoints listed in BACKEND_SETUP_PROMPT.md

---

## 📋 Implementation Checklist (Priority Order)

### Phase 1: Core Foundation (Week 1-2)

#### Frontend
- [ ] Update main.dart with new theme colors
- [ ] Import theme_design_system.dart
- [ ] Redesign auth_screen.dart with new colors
- [ ] Redesign dashboard header with neomorphic cards
- [ ] Create reusable button components
- [ ] Create reusable card components
- [ ] Remove all Telugu comments from code
- [ ] Fix any TypeScript references to Dart

#### Backend
- [ ] Set up Node.js + Express + TypeScript project
- [ ] Configure MongoDB connection
- [ ] Implement JWT authentication
- [ ] Implement all 21 API endpoints (see BACKEND_SETUP_PROMPT.md)
- [ ] Set up rate limiting
- [ ] Add input validation (Joi)
- [ ] Add error handling

### Phase 2: Core Features (Week 3-4)

#### Frontend - Home Tab
- [ ] Redesign offer carousel with new colors
- [ ] Create reusable offer card component
- [ ] Implement offer loading states (skeletons)
- [ ] Add offer search functionality
- [ ] Implement infinite scroll for offers
- [ ] Add loading indicators

#### Frontend - Wallet Tab
- [ ] Design wallet balance display (neomorphic)
- [ ] Create withdrawal options grid
- [ ] Design UPI withdrawal form
- [ ] Design PayPal withdrawal form
- [ ] Implement withdrawal history view
- [ ] Add pending withdrawal status

#### Frontend - Profile Tab
- [ ] Create user stats display
- [ ] Add profile edit form
- [ ] Add settings panel
- [ ] Add referral system display
- [ ] Add help/support links

#### Backend
- [ ] Integrate AdMantum API for real offers
- [ ] Integrate CPX Research for surveys
- [ ] Implement withdrawal logic
- [ ] Set up payment gateway webhooks
- [ ] Create transaction logging

### Phase 3: Advanced Features (Week 5-6)

#### Frontend - Games Section
- [ ] Create games list screen
- [ ] Embed game offers (webview or SDK)
- [ ] Implement game reward claiming
- [ ] Add daily challenge system

#### Frontend - Surveys Section
- [ ] Create survey list screen
- [ ] Implement survey flow integration
- [ ] Add completion tracking
- [ ] Show reward status

#### Frontend - Ads Integration
- [ ] Implement banner ads (bottom)
- [ ] Implement interstitial ads (between screens)
- [ ] Implement rewarded ads (reward on completion)
- [ ] Add ad frequency management
- [ ] Test with AdMob test IDs

#### Backend
- [ ] Set up survey API integrations
- [ ] Set up game provider integrations
- [ ] Implement reward logging for ads
- [ ] Add analytics tracking

### Phase 4: Polish & Optimization (Week 7-8)

#### Frontend
- [ ] Add smooth animations between screens
- [ ] Implement offline support (cache)
- [ ] Add push notifications
- [ ] Optimize images & assets
- [ ] Test on various screen sizes
- [ ] Add error screens
- [ ] Add empty states
- [ ] Improve loading performance

#### Backend
- [ ] Add comprehensive logging
- [ ] Set up monitoring & alerts
- [ ] Optimize database queries
- [ ] Add API documentation (Swagger)
- [ ] Security audit
- [ ] Performance testing

---

## 💻 Flutter Packages Already Installed

```dart
✅ firebase_core         - Firebase initialization
✅ firebase_auth         - Authentication (optional - use your backend)
✅ google_mobile_ads     - Google Ads
✅ webview_flutter       - Show offers in webview
✅ shared_preferences    - Store user data locally
✅ google_fonts          - Typography
✅ animate_do            - Animations
✅ dio                   - HTTP requests
✅ url_launcher          - Open external URLs
✅ device_info_plus      - Device info
✅ google_sign_in        - Google login (optional)
✅ flutter_secure_storage - Secure token storage
✅ http                  - HTTP library
```

### Additional Packages You May Need

```yaml
# For better UI
flutter_staggered_grid_view: ^0.7.0    # Staggered grid for offers
shimmer: ^3.0.0                         # Shimmer loading effects
cached_network_image: ^3.3.0            # Cache images
smooth_page_indicator: ^1.1.0           # Page indicators

# For state management
provider: ^6.0.0                        # State management
riverpod: ^2.4.0                        # Alternative state management

# For local notifications
flutter_local_notifications: ^14.1.1    # Push notifications
workmanager: ^0.5.1                     # Background tasks

# For date/time
intl: ^0.19.0                           # Internationalization

# For forms
formz: ^0.7.0                           # Form validation
```

---

## 🚀 Getting Started (Step by Step)

### Step 1: Update Design System (TODAY)
```bash
# The theme_design_system.dart file is already created
# Now update your main.dart to use it:

import 'theme_design_system.dart';

// In RewardBrickApp:
@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: 'RewardBrick',
    debugShowCheckedModeBanner: false,
    theme: appTheme,  // Use the new theme!
    home: isAuthenticated ? const DashboardScreen() : const AuthScreen(),
  );
}
```

### Step 2: Create Backend Project
```bash
# Create a new Node.js project
mkdir rewardbrick-backend
cd rewardbrick-backend

# Initialize & install dependencies
npm init -y
npm install express typescript
npm install -D @types/express @types/node ts-node

# Create necessary files
npx tsc --init

# Copy the endpoints from BACKEND_SETUP_PROMPT.md
# and implement them!
```

### Step 3: Start Building Screens
- Begin with the auth screen redesign
- Then dashboard/home screen
- Then wallet screen
- Refer to theme_design_system.dart for colors/components

### Step 4: Connect to Backend
- Update api_service.dart with your backend URL
- Test each endpoint with Postman first
- Then integrate into Flutter screens

### Step 5: Set Up External APIs
- Register on AdMantum, CPX Research
- Set up Google AdMob
- Configure payment gateways
- Add API keys to .env files

---

## 📱 Screen Wireframes (Based on Screenshots)

### Home Screen
```
┌─────────────────────────┐
│ Hello, User      [💰 0]  │  (Greeting + Balance)
├─────────────────────────┤
│   Featured Offers        │  (Carousel banner)
├─────────────────────────┤
│ Choose Your Lane         │  (Category buttons)
│ [📊 Surveys] [🎮 Games] │
├─────────────────────────┤
│ Available Offers         │  (Grid/List)
│ [Card] [Card] [Card]    │
│ [Card] [Card] [Card]    │
└─────────────────────────┘
```

### Wallet Screen
```
┌─────────────────────────┐
│ Balance: ₹ 124.00        │
├─────────────────────────┤
│ Redeem Store            │
│ [UPI] [Gift] [Talk] [PP] │
├─────────────────────────┤
│ Recent Withdrawals      │
│ ✓ ₹100 → UPI (Done)    │
│ ⏳ ₹50 → PayPal (Pending) │
└─────────────────────────┘
```

### Profile Screen
```
┌─────────────────────────┐
│ Techno E-sports         │  (User info)
│ techno...@gmail.com     │
├─────────────────────────┤
│ Stats                   │
│ [Earned] [Redeemed]    │
│ [Offers] [Referrals]   │
├─────────────────────────┤
│ [Edit Profile]          │
│ [Settings]              │
│ [Help]                  │
│ [Logout]                │
└─────────────────────────┘
```

---

## 🔐 Important Notes

### Security
- ✅ Never expose API keys in frontend code
- ✅ Use environment variables (.env)
- ✅ Hash passwords in backend (bcrypt)
- ✅ Validate all inputs
- ✅ Use HTTPS only
- ✅ Implement rate limiting on backend

### Performance
- ✅ Cache images locally
- ✅ Implement pagination for offers
- ✅ Use lazy loading
- ✅ Optimize bundle size
- ✅ Test on low-end devices

### Compliance
- ✅ Follow GDPR if EU users
- ✅ Add privacy policy
- ✅ Add terms & conditions
- ✅ Transparent about data usage
- ✅ Allow data deletion

---

## 📚 Resources & Links

### Design
- Neomorphism Guide: https://neumorphism.io/
- Google Fonts: https://fonts.google.com/
- Color Palettes: https://coolors.co/

### Flutter
- Official Docs: https://flutter.dev/docs
- Pub.dev (Packages): https://pub.dev/
- Flutter Community: https://flutter.dev/community

### Backend (TypeScript/Node.js)
- Express.js: https://expressjs.com/
- MongoDB: https://www.mongodb.com/docs/
- TypeScript: https://www.typescriptlang.org/docs/

### APIs
- AdMantum: https://admantum.com/publisher/
- Google AdMob: https://admob.google.com/
- Razorpay: https://razorpay.com/docs/
- PayPal: https://developer.paypal.com/

---

## 📞 What to Do When Stuck

1. **Check the design system** → `lib/theme_design_system.dart`
2. **Check the backend prompt** → `BACKEND_SETUP_PROMPT.md`
3. **Check the development plan** → Memory file (repo level)
4. **Search on Stack Overflow** → Search with language/package name
5. **Ask me for clarification** → I'm here to help!

---

## ✅ Next Immediate Steps

1. **Start with Theme Update** (Copy theme to main.dart)
2. **Redesign Auth Screen** (Use new colors from design system)
3. **Create Backend Project** (Follow BACKEND_SETUP_PROMPT.md)
4. **Set up MongoDB** (Use MongoDB Atlas - free tier)
5. **Deploy Backend** (Use Render.com - free tier)
6. **Test API Endpoints** (Use Postman to verify each endpoint)
7. **Connect Frontend to Backend** (Update api_service.dart URLs)

---

**Remember**: 
- Build core features first
- Then add polish
- Test everything before moving on
- Keep code clean and well-commented
- No Telugu in code comments!

Good luck! Let me know when you're ready to start. We'll take it step by step. 🚀
