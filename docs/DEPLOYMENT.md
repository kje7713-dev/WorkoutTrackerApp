# Deployment Guide

This document outlines the deployment process for WorkoutTrackerApp to TestFlight and the App Store.

## Prerequisites

Before deploying, ensure you have:

1. **Apple Developer Account** with Admin or App Manager role
2. **App Store Connect Access** with necessary permissions
3. **GitHub Repository Access** with write permissions
4. **Required Secrets** configured in GitHub (see below)

## Required GitHub Secrets

Configure the following secrets in your GitHub repository settings:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `ASC_KEY_ID` | App Store Connect API Key ID | App Store Connect → Users and Access → Keys |
| `ASC_ISSUER_ID` | App Store Connect Issuer ID | App Store Connect → Users and Access → Keys |
| `ASC_KEY` | App Store Connect API Key (base64) | Download .p8 file, base64 encode it |
| `APPLE_ID` | Apple Developer Account Email | Your Apple ID email |
| `APPLE_TEAM_ID` | Apple Developer Team ID | developer.apple.com → Membership |
| `APP_IDENTIFIER` | App Bundle Identifier | com.kje7713.WorkoutTrackerApp |
| `MATCH_GIT_URL` | Git URL for certificates repository | Your private repo for certs |
| `MATCH_GIT_TOKEN` | GitHub Personal Access Token | GitHub → Settings → Developer settings |
| `MATCH_PASSWORD` | Password for certificate encryption | Choose a secure password |
| `IOS_SCHEME` | Xcode scheme name | WorkoutTrackerApp |

### Setting Up App Store Connect API Key

1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Go to Users and Access → Keys
3. Click the "+" button to create a new key
4. Name it (e.g., "CI/CD Key")
5. Select "Admin" or "App Manager" access
6. Download the .p8 file (save it securely!)
7. Note the Key ID and Issuer ID
8. Base64 encode the key: `base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy`
9. Paste into GitHub Secrets

### Setting Up Code Signing (Match)

1. Create a private GitHub repository for certificates (e.g., `ios-certificates`)
2. Generate a Personal Access Token with `repo` scope
3. Run locally once to initialize:
   ```bash
   bundle exec fastlane match init
   bundle exec fastlane match appstore
   ```

## Deployment Methods

### Method 1: GitHub Actions (Recommended)

#### Manual Deployment

1. Go to GitHub repository → Actions tab
2. Select "iOS TestFlight" workflow
3. Click "Run workflow"
4. Select the branch (usually `main`)
5. Click "Run workflow"

The workflow will:
- Generate Xcode project
- Build the app in Release mode
- Sign with App Store certificates
- Upload to TestFlight
- Submit to Internal Testers group

#### Monitoring Progress

- Watch the Actions tab for real-time progress
- Check logs if any step fails
- Download build logs artifacts if needed

### Method 2: Codemagic

Codemagic is configured to automatically build on specific branches.

1. Push to the designated branch (check `codemagic.yaml`)
2. Codemagic will automatically trigger
3. Monitor build at [codemagic.io](https://codemagic.io)

### Method 3: Local Build (Advanced)

For local builds with Fastlane:

```bash
# Ensure you have all prerequisites
bundle install
xcodegen generate

# Set required environment variables
export APPLE_TEAM_ID="3W77JDM5X2"
export APP_IDENTIFIER="com.kje7713.WorkoutTrackerApp"
export IOS_SCHEME="WorkoutTrackerApp"
# ... set other variables

# Run Fastlane
bundle exec fastlane beta
```

## TestFlight Distribution

### Internal Testing

Internal testers are automatically added from the "Internal Testers" group in App Store Connect.

To add internal testers:
1. Go to App Store Connect → TestFlight
2. Select your app
3. Go to Internal Testing → Internal Testers
4. Add testers with their Apple IDs

### External Testing

For external testing:
1. Go to App Store Connect → TestFlight
2. Create a new External Testing group
3. Add testers by email (they'll receive invites)
4. Submit build for external testing (requires App Review)

## App Store Submission

### Preparation Checklist

- [ ] All features tested on TestFlight
- [ ] App Store metadata complete (descriptions, keywords, screenshots)
- [ ] Privacy policy URL is live and accessible
- [ ] Support URL is functional
- [ ] App icons are finalized (all sizes)
- [ ] Screenshots captured for all device sizes
- [ ] Release notes written
- [ ] App Store review information prepared
- [ ] Export compliance information ready

### Submission Steps

1. **Prepare Build**
   - Deploy to TestFlight as usual
   - Test thoroughly with internal testers

2. **Complete App Store Connect Information**
   - Go to App Store Connect → My Apps → Your App
   - Fill in all required fields:
     - App Information
     - Pricing and Availability
     - App Privacy (privacy manifest)
     - Prepare for Submission

3. **Add Build to Release**
   - Select the build from TestFlight
   - Answer export compliance questions
   - Add What's New text

4. **Submit for Review**
   - Review all information
   - Submit for App Review
   - Wait for review (typically 24-48 hours)

5. **Release**
   - Choose automatic or manual release
   - Monitor for any issues post-launch

## Version Management

### Version Numbers

- **Marketing Version** (`CFBundleShortVersionString`): User-facing version (e.g., "1.0", "1.1")
  - Update in `project.yml` under `MARKETING_VERSION`
  
- **Build Number** (`CFBundleVersion`): Internal build identifier
  - Automatically set to timestamp format: `YYYYMMDDHHMMSS`
  - Managed by Fastlane during build

### Incrementing Versions

For a new release:

1. Update `MARKETING_VERSION` in `project.yml`
   ```yaml
   MARKETING_VERSION: "1.1"
   ```

2. Update `CHANGELOG.md` with release notes

3. Commit changes and push

4. Trigger deployment workflow

Build number will be automatically incremented.

## Rollback Procedure

If you need to roll back a release:

1. **TestFlight**: Previous builds remain available; direct users to older build
2. **App Store**: Submit a new version with fixes as soon as possible
3. **Emergency**: Contact Apple Developer Support for critical issues

## Monitoring Post-Release

After release, monitor:

- **App Store Connect**: Download numbers, crashes, ratings/reviews
- **TestFlight Feedback**: Feedback from testers
- **GitHub Issues**: User-reported bugs
- **Support Email**: Direct user feedback

## Troubleshooting

### Common Issues

#### Build Fails - Code Signing

- Verify certificates in Match repository
- Check that `MATCH_PASSWORD` is correct
- Re-run `fastlane match` to regenerate if needed

#### Upload Fails - Invalid IPA

- Check that app icon includes all required sizes
- Verify Info.plist is valid
- Ensure build architecture is correct

#### TestFlight Stuck "Processing"

- Usually takes 5-30 minutes
- Check for email from Apple about compliance
- If > 1 hour, contact Apple Support

#### Version Already Exists

- Build number must be unique
- Timestamp-based build numbers prevent this
- If it happens, wait 1 minute and retry

### Getting Help

- Check [Fastlane Documentation](https://docs.fastlane.tools/)
- Review [App Store Connect Help](https://help.apple.com/app-store-connect/)
- Open GitHub issue for project-specific problems

## Release Checklist

Before each release:

- [ ] Update version number in `project.yml`
- [ ] Update `CHANGELOG.md`
- [ ] Run all tests locally
- [ ] Test on physical device
- [ ] Update App Store metadata if needed
- [ ] Prepare release notes
- [ ] Trigger deployment
- [ ] Monitor build progress
- [ ] Test on TestFlight
- [ ] Submit to App Store (if production release)

---

Last updated: December 2024
