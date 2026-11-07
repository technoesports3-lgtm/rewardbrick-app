# RewardBrick Backend - TypeScript Setup Instructions

**Copy this entire section and give it to your backend developer, OR use it as a guide for your Node.js + Express + TypeScript backend**

---

## Project Overview
- **App**: RewardBrick - Offer Wall + Surveys + Games + Ads
- **Backend**: TypeScript on Render (Node.js + Express + MongoDB)
- **Current URL**: https://rewardbrick-api.onrender.com/api/v1
- **Database**: MongoDB (recommended)

---

## Database Schema (MongoDB)

### User Collection
```javascript
{
  _id: ObjectId,
  full_name: String,
  email: String (unique),
  password: String (hashed with bcrypt),
  wallet_balance: Number (in coins/chillars),
  referral_code: String (unique),
  referral_count: Number,
  device_id: String,
  created_at: Date,
  updated_at: Date,
  settings: {
    language: String,
    notification_enabled: Boolean,
    two_factor_enabled: Boolean
  },
  status: String (active, suspended, deleted)
}
```

### Offers Collection
```javascript
{
  _id: ObjectId,
  title: String,
  description: String,
  category: String (surveys, games, offerwalls, ads),
  provider: String (admantum, cpx, google, custom),
  reward_amount: Number,
  difficulty: String (easy, medium, hard),
  time_required: Number (in minutes),
  completion_rate: Number (percentage),
  offer_url: String,
  image_url: String,
  is_active: Boolean,
  expiry_date: Date,
  max_completions: Number,
  current_completions: Number,
  created_at: Date,
  updated_at: Date
}
```

### User Offers (Tracking who completed what)
```javascript
{
  _id: ObjectId,
  user_id: ObjectId (reference to User),
  offer_id: ObjectId (reference to Offers),
  status: String (pending, completed, claimed),
  coins_earned: Number,
  claimed_at: Date,
  completed_at: Date,
  created_at: Date
}
```

### Withdrawals Collection
```javascript
{
  _id: ObjectId,
  user_id: ObjectId (reference to User),
  amount_coins: Number,
  method: String (upi, paypal, gift_card, talktime),
  upi_id: String (optional),
  paypal_email: String (optional),
  gift_card_code: String (optional),
  status: String (pending, processing, completed, failed),
  reference_id: String,
  created_at: Date,
  completed_at: Date,
  failure_reason: String (optional)
}
```

### Transactions Collection
```javascript
{
  _id: ObjectId,
  user_id: ObjectId,
  type: String (credit, debit),
  amount: Number,
  reason: String (offer_completion, daily_bonus, withdrawal, referral),
  reference_id: String,
  balance_before: Number,
  balance_after: Number,
  created_at: Date
}
```

---

## Required NPM Packages (TypeScript)

```bash
npm install express
npm install -D typescript @types/express @types/node
npm install mongoose
npm install dotenv
npm install bcryptjs
npm install jsonwebtoken @types/jsonwebtoken
npm install cors
npm install axios
npm install joi
npm install multer
```

---

## Environment Variables (.env)

```
NODE_ENV=production
PORT=5000
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_secret_key_here_very_long_and_random
JWT_EXPIRE=7d

ADMANTUM_API_KEY=your_admantum_key
CPX_API_KEY=your_cpx_key
GOOGLE_ADS_CLIENT_ID=your_google_ads_id

SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password
SMTP_FROM=noreply@rewardbrick.com

RAZORPAY_KEY=your_razorpay_key
RAZORPAY_SECRET=your_razorpay_secret

UPI_GATEWAY_API_KEY=if_using_payment_gateway
```

---

## API Endpoints - REQUIRED IMPLEMENTATION

### Authentication Endpoints

#### 1. Register User
```
POST /api/v1/users/register
Body: {
  full_name: String,
  email: String,
  password: String,
  device_id: String
}
Response: {
  success: Boolean,
  message: String,
  data: { user_id, email, full_name, wallet_balance }
}
```

#### 2. Login
```
POST /api/v1/users/login
Body: {
  email: String,
  password: String
}
Response: {
  success: Boolean,
  token: JWT,
  data: { user_id, email, full_name, wallet_balance }
}
```

#### 3. Get User Profile
```
GET /api/v1/users/profile/:userId
Headers: { Authorization: Bearer TOKEN }
Response: {
  success: Boolean,
  user: {
    _id,
    full_name,
    email,
    wallet_balance,
    referral_code,
    referral_count,
    created_at
  }
}
```

---

### Offers Endpoints

#### 4. Get Featured Offers (Homepage)
```
GET /api/v1/offers/featured?limit=10&offset=0
Response: {
  success: Boolean,
  offers: [
    {
      _id,
      title,
      description,
      category,
      reward_amount,
      difficulty,
      time_required,
      image_url,
      completion_rate
    }
  ],
  total: Number
}
```

#### 5. Get All Offers (With Filters)
```
GET /api/v1/offers/list?category=surveys&difficulty=easy&sort=reward&limit=20&offset=0
Query Params:
  - category: surveys|games|offerwalls|ads
  - difficulty: easy|medium|hard
  - sort: reward|new|popular|completion_rate
  - min_reward: Number
  - max_reward: Number
  - limit: Number (default 20, max 100)
  - offset: Number (pagination)

Response: {
  success: Boolean,
  offers: [...],
  total: Number,
  filters_applied: {}
}
```

#### 6. Get Offer Categories
```
GET /api/v1/offers/categories
Response: {
  success: Boolean,
  categories: [
    { name: "surveys", count: 25, icon: "..." },
    { name: "games", count: 15, icon: "..." }
  ]
}
```

#### 7. Claim/Complete Offer
```
POST /api/v1/offers/:offerId/claim
Headers: { Authorization: Bearer TOKEN }
Body: { user_id: String }
Response: {
  success: Boolean,
  message: String,
  coins_earned: Number,
  new_balance: Number
}
```

---

### Wallet & Withdrawal Endpoints

#### 8. Get Wallet Balance
```
GET /api/v1/wallet/balance/:userId
Response: {
  success: Boolean,
  balance: Number,
  total_earned: Number,
  total_redeemed: Number,
  pending_withdrawals: Number
}
```

#### 9. Get Transaction History
```
GET /api/v1/wallet/transaction-history/:userId?limit=20&offset=0
Response: {
  success: Boolean,
  transactions: [
    {
      _id,
      type: "credit"|"debit",
      amount: Number,
      reason: String,
      balance_after: Number,
      created_at: Date
    }
  ],
  total: Number
}
```

#### Paged wallet activity
```
GET /api/v1/users/activity/:userId?limit=30&offset=0
Response: {
  status: "success",
  activity: [{ activity_type, activity_id, created_at, amount_coins, title, status, voucher_reference }],
  has_more: Boolean
}
```

#### 10. Get Withdrawal Options
```
GET /api/v1/withdrawals/options
Response: {
  success: Boolean,
  methods: [
    {
      name: "Instant UPI",
      min_amount: 50,
      max_amount: 10000,
      processing_time: "Instant"
    },
    {
      name: "PayPal",
      min_amount: 100,
      max_amount: 50000,
      processing_time: "2-3 days"
    },
    {
      name: "Gift Cards",
      providers: ["Amazon", "Google Play", "Flipkart"],
      min_amount: 10,
      max_amount: 5000
    }
  ]
}
```

#### 11. Request Withdrawal
```
POST /api/v1/users/withdraw
Headers: { Authorization: Bearer TOKEN }
Body: {
  user_id: String,
  amount_coins: Number,
  method: "upi"|"paypal"|"gift_card"|"talktime",
  upi_id: String (if method is upi),
  paypal_email: String (if method is paypal),
  gift_card_code: String (if method is gift_card)
}
Response: {
  success: Boolean,
  message: String,
  withdrawal_id: String,
  status: "pending",
  estimated_completion: Date
}
```

#### 12. Get Withdrawal History
```
GET /api/v1/withdrawals/history/:userId?limit=20&status=all
Query Params:
  - limit: Number
  - status: all|pending|completed|failed

Response: {
  success: Boolean,
  withdrawals: [
    {
      _id,
      amount_coins,
      method,
      status,
      created_at,
      completed_at,
      reference_id
    }
  ]
}
```

#### 13. Get Pending Withdrawals
```
GET /api/v1/withdrawals/pending/:userId
Response: {
  success: Boolean,
  pending: [
    {
      _id,
      amount_coins,
      method,
      created_at,
      estimated_completion: Date
    }
  ],
  total_pending: Number
}
```

---

### Daily Bonus & Rewards

#### 14. Start a server-verified Daily Bonus session
```
POST /api/v1/users/daily-bonus/session
Headers: { Authorization: Bearer TOKEN }
Body: { userId: String }
Response: {
  status: "success",
  session_id: String,
  verified_ads: Number,
  required_ads: 3,
  reward_coins: 5
}
```

The app must set this session ID as AdMob SSV custom data and the user's ID as SSV user data. The backend credits 5 coins only after three unique, signature-verified callbacks to `/api/v1/tasks/admob-ssv`; never credit a client-side ad callback.

#### 22. Get Leaderboard
```
GET /api/v1/users/leaderboard?userId={userId}&limit=50&offset=0
Response: {
  status: "success",
  entries: [
    {
      rank: Number,
      name: String,
      coins_earned: Number,
      is_current_user: Boolean
    }
  ],
  current_user_rank: Number | null,
  current_user_coins: Number | null,
  total_users: Number,
  has_more: Boolean
}
```
Ranks use lifetime positive coin credits from the transaction ledger. Responses include display names only, never email addresses.

### Coin Reward Conversion
- 10 coins = ₹1.
- Offerwall provider reward settings represent the gross payout basis converted to coins; credit only 25% of that basis to the user (round down), retaining 75% for the business.
- The default AdMantum gross basis is 400 coins (₹40); a verified completion credits 100 coins (₹10) to the user.
- The daily bonus is 5 coins (₹0.50) and is credited only after three AdMob server-side verification callbacks.
- Do not credit a provider's raw USD payout directly as user coins.

---

### Surveys Endpoints (Optional - if integrating)

#### 15. Get Available Surveys
```
GET /api/v1/surveys/list?limit=20&offset=0
Response: {
  success: Boolean,
  surveys: [
    {
      _id,
      title,
      description,
      reward_amount,
      duration_minutes,
      qualification_rate,
      provider: String
    }
  ]
}
```

#### 16. Start Survey Session
```
POST /api/v1/surveys/:surveyId/start
Headers: { Authorization: Bearer TOKEN }
Body: { user_id: String }
Response: {
  success: Boolean,
  survey_url: String,
  session_id: String
}
```

---

### Games Endpoints (Optional)

#### 17. Get Available Games
```
GET /api/v1/games/list
Response: {
  success: Boolean,
  games: [
    {
      _id,
      title,
      description,
      image_url,
      reward_per_session: Number,
      daily_limit: Number
    }
  ]
}
```

#### 18. Claim Game Reward
```
POST /api/v1/games/:gameId/reward
Headers: { Authorization: Bearer TOKEN }
Body: { user_id: String, score: Number }
Response: {
  success: Boolean,
  coins_earned: Number,
  new_balance: Number
}
```

---

### Profile & Settings

#### 19. Update Profile
```
PUT /api/v1/users/profile/edit
Headers: { Authorization: Bearer TOKEN }
Body: {
  full_name: String (optional),
  phone: String (optional),
  language: String (optional)
}
Response: {
  success: Boolean,
  user: { ... }
}
```

#### 20. Update Settings
```
PUT /api/v1/users/settings
Headers: { Authorization: Bearer TOKEN }
Body: {
  notification_enabled: Boolean,
  two_factor_enabled: Boolean,
  language: String
}
Response: {
  success: Boolean,
  settings: { ... }
}
```

#### 21. Get User Stats
```
GET /api/v1/users/stats/:userId
Response: {
  success: Boolean,
  stats: {
    coins_earned: Number,
    coins_redeemed: Number,
    offers_completed: Number,
    offers_tried: Number,
    referrals: Number,
    member_since: Date,
    streak_days: Number
  }
}
```

---

## Important Implementation Notes

1. **Authentication**: Use JWT tokens, store in HttpOnly cookies for security
2. **Password Security**: Hash passwords with bcrypt (rounds: 10)
3. **Rate Limiting**: Implement rate limiting on withdrawal and claim endpoints
4. **Validation**: Use Joi for all input validation
5. **Error Handling**: Proper HTTP status codes (200, 400, 401, 404, 500)
6. **CORS**: Enable CORS for your Flutter app domain
7. **Logging**: Log all withdrawal requests and user transactions
8. **Balance Updates**: Use atomic transactions to prevent race conditions
9. **Webhook Handling**: For payment gateway callbacks (if using external payments)
10. **Testing**: Provide test endpoints with dummy data for mobile testing

---

## Sample Response Format (for all endpoints)

```javascript
Success:
{
  success: true,
  message: "Operation successful",
  status: 200,
  data: { ... }
}

Error:
{
  success: false,
  message: "Descriptive error message",
  status: 400,
  error: "ERROR_CODE"
}
```

---

## Deployment Checklist

- [ ] MongoDB Atlas setup with proper indexes
- [ ] Environment variables configured
- [ ] CORS properly configured for Flutter app
- [ ] Rate limiting implemented
- [ ] Error logging setup
- [ ] API documentation generated
- [ ] Payment gateway integration tested
- [ ] Database backups automated
- [ ] Security headers configured
- [ ] SSL certificate installed

---

**Next Steps**: 
1. Set up Node.js + Express + TypeScript project
2. Configure MongoDB connection
3. Implement authentication middleware
4. Create all above endpoints
5. Test with Postman before integrating with Flutter
6. Deploy to Render.com

For any questions during implementation, refer to this document or reach out for clarification.
