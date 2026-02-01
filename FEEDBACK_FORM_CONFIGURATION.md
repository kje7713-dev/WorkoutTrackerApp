# Feedback Form Configuration

## Overview
The app includes a feedback form that allows users to submit feature requests and bug reports. The form submissions are sent via email to savagesbydesignhq@gmail.com using the device's native mail client.

## Configuration

### Email Setup

The feedback form uses iOS's native `MFMailComposeViewController` to send emails. No additional configuration is required.

#### Requirements:
- Device must have Mail app configured with at least one email account
- User must have email sending capability enabled

#### User Experience:
1. User fills out feedback form
2. Taps "SUBMIT" button
3. Native iOS mail composer appears with pre-filled content
4. User reviews and sends email
5. Form resets after successful send

## Email Format

Feedback emails are automatically formatted with:

**Subject:** `[Feature Request]` or `[Bug Report]` followed by the user's title

**Body:**
```
Type: Feature Request (or Bug Report)
Title: [User's title]

Description:
[User's description]

---
Submitted from Savage By Design iOS App
```

**Recipient:** savagesbydesignhq@gmail.com

## Error Handling

The app handles the following scenarios:

1. **Email Not Available**: If the device cannot send email (no Mail app configured), the user sees an error message asking them to check their email settings.

2. **User Cancels**: If the user cancels the mail composer, the form data is retained so they can try again.

3. **Send Successful**: Form is reset after successful send.

## Privacy & Security

- No data is stored on the device beyond the user's active session
- Email is sent through the device's native mail app
- User can review email content before sending
- No backend service or API required
- No authentication tokens needed

## Testing

To test the feedback form:
1. Ensure device/simulator has Mail app configured
2. Navigate to Home Screen → FEEDBACK
3. Fill out the form
4. Tap SUBMIT
5. Verify mail composer appears with correct content
6. Send or cancel to test both flows

## Troubleshooting

**Problem:** "Email is not available on this device"
- **Solution:** Configure Mail app with an email account in iOS Settings

**Problem:** Mail composer doesn't appear
- **Solution:** Check that device has email sending capability enabled

**Problem:** Form doesn't reset after sending
- **Solution:** This is the expected behavior if mail was cancelled; only resets on successful send

