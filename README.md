# RewardBrick App

## Integrations

- **Google ads:** Android app placements use AdMob, not AdSense. Debug builds use Google's test app/ad unit IDs. For production, provide `ADMOB_APP_ID`, `ADMOB_REWARDED_AD_UNIT_ID`, and `ADMOB_BANNER_AD_UNIT_ID` from your own AdMob account.
- **Push notifications:** Set the OneSignal app ID at build time with `--dart-define=ONESIGNAL_APP_ID=<your-app-id>`. Users can opt in from Profile → Enable notifications. Configure platform push credentials in OneSignal before sending production pushes.
- **Offer links:** Admin-managed tasks can use auto-detection, force Google Play Store, or force browser routing. Play Store URLs open the Play Store app when available and fall back to the HTTPS listing.
- **Images:** Upload poster/task/affiliate images from the backend admin panel to Cloudinary; the backend signs uploads and never exposes the Cloudinary API secret.

For an Android release, set `ADMOB_APP_ID` in the build environment and pass `--dart-define=ADMOB_REWARDED_AD_UNIT_ID=<id>`, `--dart-define=ADMOB_BANNER_AD_UNIT_ID=<id>`, and `--dart-define=ONESIGNAL_APP_ID=<id>` to `flutter build appbundle`.

The backend integration variables and admin setup are documented in the backend's `ADMIN_PANEL.md`.
