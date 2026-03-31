# Release Distribution

## Goal

Move from installing builds over cable to a tester-friendly flow, and prepare the project for sharing builds with other people.

## Recommended setup

### iOS

Use **TestFlight** as the main distribution channel.

Why:
- No need to collect UDIDs or install through Xcode.
- Best experience for other testers on iPhone.
- This is the natural path toward App Store release.
- Internal testers can receive builds quickly, and external testers can be added later.

### Android

Use **Firebase App Distribution** for internal QA and early testers.

Why:
- Firebase is already configured in the project.
- Easy distribution to small tester groups.
- Good fit for preview builds before Google Play release.

## Current project state

- Flutter app lives in `app/`.
- Firebase is configured for iOS and Android.
- iOS bundle id is `com.denshetkin.budgetto`.
- iOS project currently uses manual signing settings with a provisioning profile name `Budgetto Apple Profile`.
- The current local provisioning profile is device-based and development-oriented, so it is not the profile you want for TestFlight upload.

## Practical rollout plan

### Phase 1: Remove cable from daily workflow

1. In App Store Connect, create the iOS app with bundle id `com.denshetkin.budgetto`.
2. In Xcode, open `app/ios/Runner.xcworkspace`.
3. Replace the current development-style signing setup with App Store distribution signing for archive builds.
4. Create the first archive and upload it to TestFlight.
5. Add yourself as an internal tester in App Store Connect.

Result:
- You install new iOS builds through the TestFlight app instead of cable.

### Phase 2: Share iOS builds with other people

1. Add internal testers if they are part of your App Store Connect team.
2. Add external testers through TestFlight groups.
3. Fill in beta app information once in App Store Connect.
4. After the first beta review, continue sending new builds through TestFlight.

Result:
- Other people can install the app from TestFlight with a link or invite.

### Phase 3: Keep Android simple

1. Build signed Android APK or AAB.
2. Upload it to Firebase App Distribution.
3. Invite testers by email or tester groups.

Result:
- Android testers receive builds without manual installation from your machine.

### Phase 4: Automate later

After the first successful manual iOS upload, add CI/CD:
- GitHub Actions or Codemagic for Flutter build automation.
- Automatic upload to TestFlight for iOS.
- Automatic upload to Firebase App Distribution for Android.

This order is intentional: first prove signing and release flow locally, then automate.

## Best next step

For this project, the best immediate path is:

1. Use TestFlight for iOS right now.
2. Keep Firebase App Distribution for Android testers.
3. Add CI only after the first successful TestFlight upload.

## Local iOS release checklist

- Apple Developer account is active.
- App exists in App Store Connect.
- Bundle id matches `com.denshetkin.budgetto`.
- Signing works for App Store archive, not only for debug run on registered devices.
- Version and build number are incremented before each upload.
- Beta app information is filled in App Store Connect.

## Notes

- TestFlight is better than Firebase as the primary iOS distribution channel.
- Firebase App Distribution is still useful for Android and optional internal workflows.
- If manual signing starts slowing things down, switch iOS release signing to a cleaner automated setup before CI.
