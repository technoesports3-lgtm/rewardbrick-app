# RewardBrick App - Quick Reference & Action Items

## 📌 Files Created For You

| File | Purpose | Action |
|------|---------|--------|
| `lib/theme_design_system.dart` | Complete design system with colors, components, shadows | Import & use in main.dart |
| `BACKEND_SETUP_PROMPT.md` | Complete backend setup guide with all 21 API endpoints | Give to backend dev OR follow it yourself |
| `DEVELOPMENT_GUIDE.md` | Comprehensive development roadmap with phases | Read carefully before starting |
| `/memories/repo/rewardbrick_app_plan.md` | High-level project plan | Reference throughout development |

---

## 🎨 Design Quick Reference

```dart
// Primary Colors
primarySkyBlue    = Color(0xFF87CEEB)    ← Main color
accentCreamy      = Color(0xFFF5E6D3)    ← Accent
bgLight           = Color(0xFFFAF8F3)    ← Background
textDark          = Color(0xFF2C3E50)    ← Text

// Quick Usage
Container(
  decoration: neomorphicRaised,  // Soft UI shadow effect
  padding: EdgeInsets.all(spacing16),
  child: yourWidget,
)

Button(
  decoration: buttonPrimary,  // Sky blue gradient button
  child: Text("Click", style: heading3),
)
```

---

## 🔄 Core Features Breakdown

### 1. Home Tab - Offer Wall
- Featured offers carousel
- Category shortcuts (Surveys, Games, Offerwalls, Ads)
- Search & filter
- Infinite scroll through offers
- Click to view offer details or complete

### 2. Offers Tab - Browse
- Grid/List view toggle
- Filter by category, reward, difficulty
- Sort options (newest, highest reward, easiest)
- Offer cards with complete info

### 3. Wallet Tab - Withdraw
- Show balance
- Withdrawal methods:
  - Instant UPI (50-10K INR)
  - PayPal (100-50K INR)
  - Gift Cards (10-5K INR)
  - Talktime (varies)
- Withdrawal history
- Pending requests

### 4. Profile Tab - User Hub
- User stats (coins earned, redeemed, offers, referrals)
- Profile editing
- Settings
- Help/Support
- Logout

### 5. Games Section
- Game cards
- Play game
- Earn rewards
- Daily challenge system

### 6. Surveys Section
- Survey list
- Qualification rate
- Survey link
- Completion tracking

### 7. Ads
- Banner ads (bottom of home)
- Interstitial ads (between navigation)
- Rewarded ads (watch video → earn coins)

---

## 🛠 Backend API Endpoints (22 Total)

### Must Have (Priority 1)
1. `POST /users/register` - Create account
2. `POST /users/login` - Login
3. `GET /users/profile/:userId` - Get profile & balance
4. `GET /offers/featured` - Homepage offers
5. `GET /offers/list` - All offers with filters
6. `POST /offers/:offerId/claim` - Complete offer
7. `GET /wallet/balance/:userId` - Current coins
8. `POST /users/withdraw` - Request withdrawal

### Should Have (Priority 2)
9. `GET /wallet/transaction-history/:userId` - See history
10. `GET /withdrawals/history/:userId` - Withdrawal status
11. `POST /users/daily-bonus` - Daily reward
12. `GET /offers/categories` - Category list
13. `GET /withdrawals/options` - Available methods
14. `GET /withdrawals/pending/:userId` - Pending requests

### Nice to Have (Priority 3)
15. `GET /surveys/list` - Available surveys
16. `POST /surveys/:surveyId/complete` - Complete survey
17. `GET /games/list` - Available games
18. `POST /games/:gameId/reward` - Game reward
19. `PUT /users/profile/edit` - Update profile
20. `GET /users/stats/:userId` - User statistics
21. `PUT /users/settings` - Settings update
22. `GET /users/leaderboard` - Lifetime coin rankings and your rank

---

## 📦 External Services to Register

### Backend Admin Panel
- Open `/admin` on the deployed backend after setting `ADMIN_PANEL_PASSWORD`.
- Manage users, coin adjustments, offer cards, provider rewards/secrets, withdrawals, and the admin audit log.
- See `../rewardbrick-backend/ADMIN_PANEL.md` for setup and deployment notes.

### Critical (Week 1)
- [ ] Google AdMob - Banner & Rewarded Ads
- [ ] MongoDB Atlas - Free tier database
- [ ] Render.com - Free backend hosting
- [ ] Firebase (already set up)

### Important (Week 2)
- [ ] AdMantum - Affiliate offers (App ID: 52007)
- [ ] CPX Research - Survey offers (already configured)
- [ ] Razorpay OR PayU - UPI payments
- [ ] PayPal - PayPal payments

### Optional (Week 3+)
- [ ] Survey platforms (SurveySparrow, Qualtrics)
- [ ] Game providers (AppLift, Mintegral)
- [ ] Talktime APIs (Airtel, Jio, etc.)
- [ ] Gift card APIs (Amazon, Google Play)

---

## 🚀 Start Here (First 3 Days)

### Day 1: Setup & Planning
- [ ] Read `DEVELOPMENT_GUIDE.md` completely
- [ ] Set up MongoDB Atlas account (free)
- [ ] Set up Render.com account
- [ ] Set up Google AdMob account
- [ ] Gather all API keys & credentials

### Day 2: Frontend Design
- [ ] Copy `theme_design_system.dart` to your theme
- [ ] Update `main.dart` to use new theme
- [ ] Redesign auth screen (login/signup)
- [ ] Create reusable button component
- [ ] Create reusable card component

### Day 3: Backend Foundation
- [ ] Create Node.js + TypeScript project
- [ ] Set up MongoDB connection
- [ ] Implement JWT authentication
- [ ] Create database schemas (8 collections)
- [ ] Start implementing first 5 API endpoints

---

## 💡 Pro Tips

1. **Test Backend First** - Use Postman to test all endpoints before connecting Flutter
2. **Start with Mock Data** - Use dummy offers/surveys while testing
3. **Build Component by Component** - Don't try to do everything at once
4. **Test on Real Device** - Ads & payments need real device testing
5. **Keep Secrets Safe** - Use .env files, never commit API keys
6. **Document Your Changes** - Add comments explaining logic
7. **Make Small Commits** - Git commits frequently with clear messages
8. **Backup Regularly** - MongoDB Atlas auto-backups, but backup your code too

---

## ⚠️ Common Mistakes to Avoid

❌ **Don't**:
- Copy the current blue design (copyright issue)
- Use Telugu in code
- Store sensitive data in SharedPreferences
- Forget to validate inputs on backend
- Mix API keys with code
- Skip error handling
- Test only on iOS/Android simulator
- Ignore rate limiting on backend
- Use hardcoded URLs in frontend
- Deploy without security audit

✅ **Do**:
- Use environment variables
- Implement proper error pages
- Cache images locally
- Test on real devices
- Use HTTPS everywhere
- Implement rate limiting
- Add comprehensive logging
- Write clean, documented code
- Follow Flutter best practices
- Get security review before launch

---

## 📊 Project Timeline Estimate

| Phase | Duration | What's Included |
|-------|----------|---|
| **Phase 1: Foundation** | Week 1-2 | Design system, Backend setup, Basic screens |
| **Phase 2: Core Features** | Week 3-4 | Offers, Wallet, Profile working |
| **Phase 3: Advanced** | Week 5-6 | Games, Surveys, Ads integration |
| **Phase 4: Polish** | Week 7-8 | Optimization, Testing, Bug fixes |
| **Total** | ~2 months | Full launch-ready app |

---

## 🎯 Success Criteria

Your app is ready when:
- ✅ All core features work (Home, Offers, Wallet, Profile)
- ✅ Users can earn & withdraw money
- ✅ Ads display correctly
- ✅ Design is consistent (Sky blue + Creamy theme)
- ✅ Backend handles 100+ concurrent users
- ✅ No bugs reported in testing
- ✅ Security audit passed
- ✅ Privacy policy & Terms displayed
- ✅ Error handling graceful
- ✅ App launches within 3 seconds

---

## 🆘 Quick Troubleshooting

### App Won't Build
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Firebase Issues
- Check google-services.json in android/app/
- Verify Firebase project settings match

### API Not Responding
- Check internet connection
- Verify backend is running
- Check API endpoint URLs in api_service.dart
- Use Postman to test endpoint directly

### Ads Not Showing
- Check AdMob App ID in google_mobile_ads
- Use test ad IDs during development
- Check device is online
- Verify ads are enabled in AdMob console

### Payment Issues
- Test with test payment gateways first
- Check API keys are correct
- Verify webhook URLs in payment dashboard
- Check transaction logs in backend

---

## 📞 Quick Communication Reminders

**When asking for help, provide:**
1. What you're trying to do
2. What you've tried
3. What error you got
4. Which file/code is involved
5. What you expect should happen

**Example:**
```
"I'm trying to display offers on home screen. 
Used _loadOffers() from api_service. 
Getting error: '_offers' is empty. 
In dashboard_screen.dart line 85.
Should show 10+ offer cards but showing nothing.
```

---

## ✨ Now You're Ready!

You have:
✅ Complete design system
✅ Backend setup guide
✅ Development roadmap
✅ Feature checklist
✅ API documentation
✅ Quick reference

**Next Step**: Pick one task from "Start Here (First 3 Days)" and begin!

**Remember**: Quality over speed. Build it right, not fast. 🚀
