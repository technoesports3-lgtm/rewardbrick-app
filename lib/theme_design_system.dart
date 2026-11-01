import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// RewardBrick brand palette inspired by the logo.

// ============================================
// COLOR PALETTE
// ============================================

// Primary Colors (Logo Blue)
const Color primarySkyBlue = Color(0xFF1769D2);
const Color primaryLightBlue = Color(0xFFB9D9FF);
const Color primaryDarkBlue = Color(0xFF0847A6);

// Accent Colors (Logo Yellow and Brick Red)
const Color accentCreamy = Color(0xFFFFF0B8);
const Color accentPeach = Color(0xFFFFCC32);
const Color accentCoral = Color(0xFFE8452E);

// Background Colors
const Color bgLight = Color(0xFFFFFAEA);
const Color bgSoft = Color(0xFFFFF3D0);
const Color bgWhite = Color(0xFFFFFFFF); // Pure White

// Status Colors
const Color successGreen = Color(0xFF4CAF50); // Success
const Color warningOrange = Color(0xFFFFC107); // Warning
const Color errorRed = Color(0xFFE8452E); // Error
const Color infoBlue = Color(0xFF2196F3); // Info

// Text Colors
const Color textDark = Color(0xFF202A3A); // Dark text
const Color textMedium = Color(0xFF546E7A); // Medium text
const Color textLight = Color(0xFF90A4AE); // Light text
const Color textHint = Color(0xFFBDBDBD); // Hint text

// Shadow & Highlight (for Neomorphism)
const Color shadowColor = Color(0xFFD0D5DD); // Soft shadow
const Color highlightColor = Color(0xFFFFFFFF); // Soft highlight

// ============================================
// NEOMORPHISM STYLING (Soft UI)
// ============================================

/*
Neomorphism is achieved with:
1. Soft shadows on light backgrounds
2. Subtle color gradients
3. Rounded corners (12-20px)
4. Light, muted colors
5. Minimal contrast
*/

// Pressed Button Style (Inset shadow)
BoxDecoration neomorphicPressed = BoxDecoration(
  color: bgLight,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Color(0xFF000000).withOpacity(0.1),
      blurRadius: 15,
      offset: Offset(5, 5),
    ),
    BoxShadow(
      color: highlightColor,
      blurRadius: 15,
      offset: Offset(-5, -5),
    ),
  ],
);

// Raised Button Style (Outer shadow)
BoxDecoration neomorphicRaised = BoxDecoration(
  color: bgLight,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: shadowColor.withOpacity(0.3),
      blurRadius: 20,
      offset: Offset(8, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: highlightColor,
      blurRadius: 20,
      offset: Offset(-8, -8),
      spreadRadius: 0,
    ),
  ],
);

// ============================================
// COMPONENT STYLES
// ============================================

// Card Style (Raised)
BoxDecoration offerCard = BoxDecoration(
  color: bgWhite,
  borderRadius: BorderRadius.circular(20),
  boxShadow: [
    BoxShadow(
      color: shadowColor.withOpacity(0.2),
      blurRadius: 15,
      offset: Offset(4, 4),
    ),
    BoxShadow(
      color: highlightColor,
      blurRadius: 15,
      offset: Offset(-4, -4),
    ),
  ],
);

// Button Styles
BoxDecoration buttonPrimary = BoxDecoration(
  gradient: LinearGradient(
    colors: [primarySkyBlue, primaryLightBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  borderRadius: BorderRadius.circular(14),
  boxShadow: [
    BoxShadow(
      color: primaryDarkBlue.withOpacity(0.3),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ],
);

BoxDecoration buttonSecondary = BoxDecoration(
  color: accentCreamy,
  borderRadius: BorderRadius.circular(14),
  boxShadow: [
    BoxShadow(
      color: accentCoral.withOpacity(0.2),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ],
);

// Input Field Style
BoxDecoration inputField = BoxDecoration(
  color: bgLight,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: primaryLightBlue.withOpacity(0.5)),
  boxShadow: [
    BoxShadow(
      color: shadowColor.withOpacity(0.08),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ],
);

// ============================================
// TYPOGRAPHY
// ============================================

// Headings
TextStyle heading1 = GoogleFonts.poppins(
  fontSize: 32,
  fontWeight: FontWeight.w800,
  color: textDark,
  height: 1.2,
);

TextStyle heading2 = GoogleFonts.poppins(
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: textDark,
  height: 1.3,
);

TextStyle heading3 = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: textDark,
  height: 1.4,
);

// Body Text
TextStyle bodyLarge = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: textMedium,
  height: 1.5,
);

TextStyle bodyMedium = GoogleFonts.poppins(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: textMedium,
  height: 1.5,
);

TextStyle bodySmall = GoogleFonts.poppins(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: textLight,
  height: 1.5,
);

// ============================================
// SPACING
// ============================================

const double spacing4 = 4;
const double spacing8 = 8;
const double spacing12 = 12;
const double spacing16 = 16;
const double spacing20 = 20;
const double spacing24 = 24;
const double spacing28 = 28;
const double spacing32 = 32;

// ============================================
// BORDER RADIUS
// ============================================

const double radiusSmall = 8;
const double radiusMedium = 12;
const double radiusLarge = 16;
const double radiusXL = 20;
const double radiusCircle = 50;

// ============================================
// CUSTOM THEMES
// ============================================

// Light Theme (Default)
ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: primarySkyBlue,
  scaffoldBackgroundColor: bgLight,
  colorScheme: ColorScheme.light(
    primary: primarySkyBlue,
    secondary: accentPeach,
    surface: bgWhite,
    background: bgLight,
    error: errorRed,
  ),
  textTheme: TextTheme(
    displayLarge: heading1,
    displayMedium: heading2,
    titleLarge: heading3,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    labelSmall: bodySmall,
  ),
  iconTheme: IconThemeData(
    color: primarySkyBlue,
    size: 24,
  ),
);

// ============================================
// SHADOWS & EFFECTS
// ============================================

// Soft Shadow (Elevation 1)
List<BoxShadow> softShadow = [
  BoxShadow(
    color: shadowColor.withOpacity(0.1),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
];

// Medium Shadow (Elevation 2)
List<BoxShadow> mediumShadow = [
  BoxShadow(
    color: shadowColor.withOpacity(0.15),
    blurRadius: 15,
    offset: Offset(0, 4),
  ),
];

// Deep Shadow (Elevation 3)
List<BoxShadow> deepShadow = [
  BoxShadow(
    color: shadowColor.withOpacity(0.2),
    blurRadius: 25,
    offset: Offset(0, 8),
  ),
];

// Neumorphic Inset Effect
List<BoxShadow> insetEffect = [
  BoxShadow(
    color: shadowColor.withOpacity(0.25),
    blurRadius: 15,
    offset: Offset(3, 3),
  ),
  BoxShadow(
    color: highlightColor,
    blurRadius: 15,
    offset: Offset(-3, -3),
  ),
];

// ============================================
// ANIMATION DURATIONS
// ============================================

const Duration fastAnimation = Duration(milliseconds: 200);
const Duration normalAnimation = Duration(milliseconds: 300);
const Duration slowAnimation = Duration(milliseconds: 500);
const Duration verySlowAnimation = Duration(milliseconds: 800);

// ============================================
// GRADIENTS
// ============================================

LinearGradient skyToCreamy = LinearGradient(
  colors: [primarySkyBlue, accentCreamy],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

LinearGradient creamyToSky = LinearGradient(
  colors: [accentCreamy, primarySkyBlue],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ============================================
// USAGE EXAMPLES
// ============================================

/*
1. BUTTON:
Container(
  decoration: buttonPrimary,
  child: InkWell(
    onTap: () {},
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing20,
        vertical: spacing12,
      ),
      child: Text(
        "Earn Now",
        style: TextStyle(
          color: bgWhite,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
  ),
)

2. OFFER CARD:
Container(
  decoration: offerCard,
  padding: EdgeInsets.all(spacing16),
  child: Column(
    children: [
      Image.network(offerImageUrl, fit: BoxFit.cover),
      SizedBox(height: spacing12),
      Text("Offer Title", style: heading3),
      SizedBox(height: spacing8),
      Text("Offer Description", style: bodyMedium),
      SizedBox(height: spacing16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("₹${rewardAmount}", style: heading2.copyWith(color: successGreen)),
          Container(
            decoration: buttonSecondary,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing12, vertical: spacing8),
              child: Text("Claim", style: bodyMedium.copyWith(color: textDark)),
            ),
          ),
        ],
      ),
    ],
  ),
)

3. NEOMORPHIC CONTAINER:
Container(
  decoration: neomorphicRaised,
  padding: EdgeInsets.all(spacing20),
  child: // Your content here
)

4. INPUT FIELD:
TextField(
  decoration: InputDecoration(
    hintText: "Enter UPI ID",
    border: InputBorder.none,
    filled: true,
    fillColor: bgLight,
    contentPadding: EdgeInsets.all(spacing16),
  ),
)
*/

// ============================================
// COLOR CONTRAST NOTES
// ============================================

/*
Accessibility Checklist:
- Text on sky blue background: Use textDark (0xFF2C3E50) for AA compliance
- Buttons: Ensure contrast ratio 4.5:1 minimum
- Links: Use primary/accent colors with underline
- Disabled states: Use textHint with reduced opacity
- Alerts: Use status colors (green/orange/red) with icons
*/
