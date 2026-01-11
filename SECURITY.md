# Security Policy

## Reporting a Vulnerability

We take the security of WorkoutTrackerApp seriously. If you discover a security vulnerability, please report it responsibly.

### How to Report

**Please do NOT open a public issue for security vulnerabilities.**

Instead, please report security issues by:

1. Emailing security concerns to: savagesbydesignhq@gmail.com
2. Opening a private security advisory on GitHub

For general inquiries, visit: savagesbydesign.com

### What to Include

When reporting a vulnerability, please include:

- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact
- Suggested fix (if you have one)
- Your contact information

### Response Time

- We will acknowledge receipt of your vulnerability report within 48 hours
- We will send a more detailed response within 5 business days indicating next steps
- We will keep you informed about the progress towards fixing the issue

### Security Updates

Security fixes will be released as soon as possible after verification. Critical vulnerabilities will be prioritized for immediate release.

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Security Best Practices

### For Users

- Keep your app updated to the latest version
- Use a secure device passcode
- Enable device encryption (iOS default)
- Review app permissions regularly

### For Developers

- Never commit secrets or API keys to the repository
- Use environment variables for sensitive configuration
- Follow secure coding practices
- Keep dependencies updated
- Review code for security issues before submitting PRs
- Use the AppLogger for production logging (no sensitive data)

## Known Security Considerations

### Data Storage

- All workout data is stored locally on the device in JSON format
- Data is stored in the app's sandboxed Documents directory
- No data is transmitted to external servers
- Data is subject to iOS device encryption

### Permissions

The app currently requests no special permissions. If future versions require permissions (e.g., HealthKit, Photos), these will be documented and justified.

### Third-Party Dependencies

The app currently has minimal external dependencies:
- Fastlane (build automation only, not included in app)
- No runtime third-party libraries

Future additions will be carefully vetted for security.

## Privacy

See our [Privacy Policy](https://kje7713-dev.github.io/WorkoutTrackerApp/privacy) for details on data collection and usage.

## Acknowledgments

We appreciate the security research community's efforts in helping keep WorkoutTrackerApp secure.

---

Last updated: December 2024
