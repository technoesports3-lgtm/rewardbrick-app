// ============================================
// SAMPLE IMPLEMENTATION GUIDE
// How to use the new design system in your screens
// ============================================

// FILE: lib/screens/sample_components.dart
// This is a reference for how to build screens using the new design system

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme_design_system.dart';

// ============================================
// 1. REUSABLE BUTTON COMPONENT
// ============================================

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final double width;

  const PrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        decoration: buttonPrimary,
        padding: EdgeInsets.symmetric(vertical: spacing12),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(bgWhite),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: bgWhite,
                  ),
                ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const SecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: buttonSecondary,
        padding: EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing12,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
      ),
    );
  }
}

// ============================================
// 2. OFFER CARD COMPONENT
// ============================================

class OfferCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final num rewardAmount;
  final String category;
  final VoidCallback onClaim;
  final double? height;

  const OfferCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.rewardAmount,
    required this.category,
    required this.onClaim,
    this.height = 280,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: offerCard,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(radiusLarge),
                  topRight: Radius.circular(radiusLarge),
                ),
                child: Image.network(
                  imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: primaryLightBlue.withOpacity(0.3),
                    child: Icon(
                      Icons.image_not_supported,
                      color: primaryDarkBlue,
                    ),
                  ),
                ),
              ),
              // Category Tag
              Positioned(
                top: spacing8,
                right: spacing8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing8,
                    vertical: spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: primarySkyBlue,
                    borderRadius: BorderRadius.circular(radiusSmall),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: bgWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content Section
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: heading3,
                  ),
                  SizedBox(height: spacing4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: bodySmall.copyWith(color: textMedium),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹$rewardAmount',
                        style: heading2.copyWith(color: successGreen),
                      ),
                      PrimaryButton(
                        label: 'Claim',
                        onPressed: onClaim,
                        width: 100,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// 3. NEOMORPHIC CONTAINER COMPONENT
// ============================================

class NeomorphicContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool isPressed;

  const NeomorphicContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = radiusXL,
    this.isPressed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isPressed ? neomorphicPressed : neomorphicRaised,
      padding: padding,
      child: child,
    );
  }
}

// ============================================
// 4. INPUT FIELD COMPONENT
// ============================================

class CustomInputField extends StatefulWidget {
  final String hintText;
  final String? label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomInputField({
    Key? key,
    required this.hintText,
    this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
          SizedBox(height: spacing8),
        ],
        Container(
          decoration: inputField,
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            focusNode: _focusNode,
            validator: widget.validator,
            style: bodyMedium.copyWith(color: textDark),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: bodyMedium.copyWith(color: textHint),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: spacing16,
                vertical: spacing12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// 5. BALANCE DISPLAY COMPONENT
// ============================================

class BalanceCard extends StatelessWidget {
  final num balance;
  final String currency;
  final String label;

  const BalanceCard({
    Key? key,
    required this.balance,
    this.currency = '₹',
    this.label = 'Wallet Balance',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeomorphicContainer(
      child: Column(
        children: [
          Text(
            label,
            style: bodyMedium.copyWith(color: textMedium),
          ),
          SizedBox(height: spacing12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currency,
                style: heading2.copyWith(color: primarySkyBlue),
              ),
              SizedBox(width: spacing8),
              Text(
                '$balance',
                style: heading1.copyWith(color: successGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================
// 6. LOADING SKELETON COMPONENT
// ============================================

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    Key? key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 10,
  }) : super(key: key);

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        color: primaryLightBlue.withOpacity(0.1),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment(-1.0, 0.0),
            end: Alignment(1.0, 0.0),
            colors: [
              primaryLightBlue.withOpacity(0),
              primaryLightBlue.withOpacity(0.3),
              primaryLightBlue.withOpacity(0),
            ],
            stops: [0.0, 0.5, 1.0],
            transform: GradientRotation(_controller.value * 6.3),
          ).createShader(bounds);
        },
        child: Container(
          color: primaryLightBlue.withOpacity(0.1),
        ),
      ),
    );
  }
}

// ============================================
// 7. EXAMPLE: HOW TO USE IN A SCREEN
// ============================================

/*
Example: Building a Home Screen with the components

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(spacing20),
          children: [
            // Greeting
            Text(
              'Hello, User!',
              style: heading1,
            ),
            SizedBox(height: spacing20),

            // Balance Card
            BalanceCard(
              balance: 150,
              label: 'Wallet Balance',
            ),
            SizedBox(height: spacing24),

            // Offers Section
            Text(
              'Available Offers',
              style: heading2,
            ),
            SizedBox(height: spacing16),

            // Offer Cards Grid
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: spacing12,
                mainAxisSpacing: spacing12,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => OfferCard(
                title: 'Survey Title',
                description: 'Short description',
                imageUrl: 'https://...',
                rewardAmount: 50,
                category: 'Survey',
                onClaim: () {
                  print('Claimed!');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

// ============================================
// 8. STYLING TIPS
// ============================================

/*
Color Usage Tips:

1. BACKGROUNDS: Use bgLight or bgWhite
   - bgLight: Default screen background
   - bgWhite: Card backgrounds

2. TEXT: Use text color variants
   - textDark: Headings & important text
   - textMedium: Body text
   - textLight: Secondary text
   - textHint: Placeholder text

3. ACCENTS: 
   - Primary buttons: Use buttonPrimary (sky blue)
   - Secondary buttons: Use buttonSecondary (creamy)
   - Status: Use successGreen, warningOrange, errorRed

4. SHADOWS:
   - Cards: offerCard (includes shadow)
   - Buttons: buttonPrimary/Secondary (includes shadow)
   - Custom: Use softShadow, mediumShadow, deepShadow lists

5. SPACING:
   - Always use the spacing constants (spacing8, spacing16, etc.)
   - Never hardcode pixel values!

6. BORDER RADIUS:
   - Buttons: radiusMedium (12px)
   - Cards: radiusLarge (16px)
   - Small elements: radiusSmall (8px)
*/

// ============================================
// 9. RESPONSIVE DESIGN TIPS
// ============================================

/*
Make components responsive:

// Get screen width
double screenWidth = MediaQuery.of(context).sizeWidth;

// Adapt columns based on screen size
int columns = screenWidth > 600 ? 3 : 2;

// Adapt font sizes
double fontSize = screenWidth > 600 ? 18 : 14;

// Adapt padding
double padding = screenWidth > 600 ? 24 : 16;

// Test on multiple screen sizes:
// - Phone: 400x800
// - Tablet: 600x1200
// - Desktop: 1200x800 (landscape)
*/

// ============================================
// DONE! You now have:
// ✅ Reusable button components
// ✅ Offer card component
// ✅ Neomorphic containers
// ✅ Custom input fields
// ✅ Balance display
// ✅ Loading skeletons
// ✅ Example usage
// ✅ Styling tips
// ============================================
