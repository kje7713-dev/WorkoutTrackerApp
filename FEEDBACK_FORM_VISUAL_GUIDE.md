# Feedback Form Visual Guide

## Overview
This document describes the visual design and user flow for the new Feedback Form feature.

## Navigation Flow

### Home Screen
The Home Screen now includes a new "FEEDBACK" button:

```
┌─────────────────────────────────────────┐
│                                         │
│         SAVAGE BY DESIGN                │
│   WE ARE WHAT WE REPEATEDLY DO          │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │ ▍ BLOCKS                          │  │ (Electric Green accent bar)
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │   BLOCK HISTORY                   │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │   DATA MANAGEMENT                 │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │   FEEDBACK                        │  │ ← NEW
│  └───────────────────────────────────┘  │
│                                         │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │   USER GUIDE                      │  │
│  └───────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

## Feedback Form Screen

### Initial State
```
┌─────────────────────────────────────────┐
│  ←  FEEDBACK                            │
├─────────────────────────────────────────┤
│                                         │
│  FEEDBACK                               │
│  Help us improve your experience        │
│                                         │
│  TYPE                                   │
│  ┌─────────────────┬─────────────────┐  │
│  │ Feature Request │   Bug Report    │  │ (Segmented Control)
│  └─────────────────┴─────────────────┘  │
│                                         │
│  TITLE                                  │
│  ┌───────────────────────────────────┐  │
│  │ Brief summary                     │  │
│  └───────────────────────────────────┘  │
│                                         │
│  DESCRIPTION                            │
│  ┌───────────────────────────────────┐  │
│  │                                   │  │
│  │                                   │  │
│  │                                   │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │           SUBMIT                  │  │ (Disabled - gray)
│  └───────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

### Filled State (Ready to Submit)
```
┌─────────────────────────────────────────┐
│  ←  FEEDBACK                            │
├─────────────────────────────────────────┤
│                                         │
│  FEEDBACK                               │
│  Help us improve your experience        │
│                                         │
│  TYPE                                   │
│  ┌─────────────────┬─────────────────┐  │
│  │ Feature Request │   Bug Report    │  │
│  └─────────────────┴─────────────────┘  │
│         ^                               │
│         └─ Selected (Electric Green)    │
│                                         │
│  TITLE                                  │
│  ┌───────────────────────────────────┐  │
│  │ Add rest timer between sets      │  │
│  └───────────────────────────────────┘  │
│                                         │
│  DESCRIPTION                            │
│  ┌───────────────────────────────────┐  │
│  │ It would be helpful to have      │  │
│  │ an automatic timer that counts   │  │
│  │ rest periods between sets...     │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │           SUBMIT                  │  │ (Enabled - Black/Steel Gray)
│  └───────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

### Submitting State
```
┌─────────────────────────────────────────┐
│  ←  FEEDBACK                            │
├─────────────────────────────────────────┤
│                                         │
│  FEEDBACK                               │
│  Help us improve your experience        │
│                                         │
│  TYPE                                   │
│  ┌─────────────────┬─────────────────┐  │
│  │ Feature Request │   Bug Report    │  │
│  └─────────────────┴─────────────────┘  │
│                                         │
│  TITLE                                  │
│  ┌───────────────────────────────────┐  │
│  │ Add rest timer between sets      │  │
│  └───────────────────────────────────┘  │
│                                         │
│  DESCRIPTION                            │
│  ┌───────────────────────────────────┐  │
│  │ It would be helpful to have      │  │
│  │ an automatic timer that counts   │  │
│  │ rest periods between sets...     │  │
│  └───────────────────────────────────┘  │
│                                         │
│  ┌───────────────────────────────────┐  │
│  │   ⊚   SUBMITTING...               │  │ (Loading spinner)
│  └───────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
```

### Success Alert
```
┌─────────────────────────────────────────┐
│                                         │
│         ┌─────────────────────┐         │
│         │                     │         │
│         │     Success!        │         │
│         │                     │         │
│         │ Thank you for your  │         │
│         │ feedback! We've     │         │
│         │ received your       │         │
│         │ submission.         │         │
│         │                     │         │
│         │      ┌──────┐       │         │
│         │      │  OK  │       │         │ ← Dismisses to Home
│         │      └──────┘       │         │
│         └─────────────────────┘         │
│                                         │
└─────────────────────────────────────────┘
```

## Design Specifications

### Colors
- **Background**: 
  - Light mode: White (#FFFFFF)
  - Dark mode: Savage Black (#0D0D0D)
  
- **Primary Text**: 
  - Light mode: Black (#000000)
  - Dark mode: Off-White (#F5F5F5)
  
- **Muted Text**: Gray (#B2B2B2)

- **Accent/Success**: Electric Green (#00E676)

- **Button Background**:
  - Light mode: Black (#000000)
  - Dark mode: Steel Gray (#1A1A1B)

- **Text Field Background**:
  - Light mode: #F2F2F7
  - Dark mode: #1A1A1B

- **Text Field Border**:
  - Light mode: #E5E5EA
  - Dark mode: #2D2D2E

### Typography
- **Headers**: System font, Heavy weight, size 32, tracking 1.5
- **Subheaders**: System font, Medium weight, size 16
- **Labels**: System font, Semibold weight, size 14, tracking 1.2
- **Buttons**: System font, Semibold weight, size 16, tracking 1.5, UPPERCASE

### Spacing
- Horizontal padding: 20px
- Vertical spacing between sections: 24px
- Label to field spacing: 8px
- Text field padding: 12px
- Button height: 48px

### Animations
- Button disabled state: Opacity 0.5, gray background
- Loading state: Circular progress indicator
- Success/Error alerts: System native modal presentation

## User Experience Flow

1. **Discovery**: User navigates to Home Screen and sees "FEEDBACK" button
2. **Access**: User taps "FEEDBACK" to navigate to form
3. **Input**: User selects feedback type (Feature Request/Bug Report)
4. **Compose**: User enters title and description
5. **Submit**: User taps "SUBMIT" button
6. **Processing**: Loading indicator shows while submitting
7. **Confirmation**: Success alert appears with thank you message
8. **Return**: User taps "OK" and returns to Home Screen

## Error Handling

### Network Error
```
┌─────────────────────────────────────────┐
│         ┌─────────────────────┐         │
│         │       Error         │         │
│         │                     │         │
│         │ Unable to submit    │         │
│         │ feedback. Please    │         │
│         │ check your          │         │
│         │ connection and try  │         │
│         │ again.              │         │
│         │                     │         │
│         │      ┌──────┐       │         │
│         │      │  OK  │       │         │
│         │      └──────┘       │         │
│         └─────────────────────┘         │
└─────────────────────────────────────────┘
```

### Configuration Error
```
┌─────────────────────────────────────────┐
│         ┌─────────────────────┐         │
│         │       Error         │         │
│         │                     │         │
│         │ Configuration error.│         │
│         │ Please try again    │         │
│         │ later.              │         │
│         │                     │         │
│         │      ┌──────┐       │         │
│         │      │  OK  │       │         │
│         │      └──────┘       │         │
│         └─────────────────────┘         │
└─────────────────────────────────────────┘
```

## Privacy Considerations

The feedback form:
- Does NOT mention GitHub in the UI
- Uses generic language ("submit feedback", "your submission")
- Does NOT display the issue URL to users
- Does NOT reveal the repository location
- Provides a seamless, integrated experience that feels like a first-party feature

## Backend Integration

The form submits to:
- **Endpoint**: GitHub REST API v3 (issues endpoint)
- **Repository**: kje7713-dev/WorkoutTrackerApp
- **Authentication**: GitHub Personal Access Token (via environment variable)
- **Issue Labels**: 
  - Feature Request → "enhancement" label
  - Bug Report → "bug" label

## Future Enhancements

Potential improvements for future iterations:
1. Backend proxy service for secure token handling
2. Attachment support (screenshots, logs)
3. Email notification option for user
4. Feedback history view
5. Voting on existing feedback
6. Status tracking for submitted feedback
