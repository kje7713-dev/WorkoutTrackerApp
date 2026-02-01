# Feedback Form Configuration

## Overview
The app includes a feedback form that allows users to submit feature requests and bug reports. The form submissions are sent to the GitHub repository's issue tracker.

## Configuration

### GitHub Token Setup

To enable the feedback form to create issues, you need to set up a GitHub Personal Access Token:

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate a new token with the `public_repo` scope
3. Set the token as an environment variable or build configuration:

#### For Development:
```bash
export GITHUB_TOKEN="your_token_here"
# Then run the app from the command line
```

#### For Production (Xcode):
1. Edit scheme in Xcode
2. Go to Run → Arguments → Environment Variables
3. Add `GITHUB_TOKEN` with your token value

#### For CI/CD:
Add `GITHUB_TOKEN` to your GitHub Secrets and configure it in your workflow files.

## Security Considerations

**IMPORTANT - Production Security**: The current implementation uses an environment variable for the GitHub token. This approach has significant security limitations:

### Current Implementation (Development Only)
- Uses `GITHUB_TOKEN` environment variable
- Suitable for development and testing
- **NOT recommended for production releases**

### Production Recommendations

1. **Use a backend proxy service (RECOMMENDED)**: 
   - Create a backend API endpoint that accepts feedback submissions
   - Backend service handles GitHub API authentication securely
   - Mobile app only communicates with your backend, never directly with GitHub
   - Enables additional features like rate limiting, spam detection, and analytics

2. **GitHub Apps (Alternative)**:
   - Use GitHub Apps for more secure and scalable authentication
   - Apps can be installed on specific repositories
   - Better audit trail and permission management

3. **Never commit tokens**: 
   - Ensure tokens are never committed to source control
   - Use `.gitignore` for any files containing secrets
   - Regularly rotate tokens

4. **Rate limiting**: 
   - Implement rate limiting to prevent abuse
   - Consider user authentication before allowing feedback submission

5. **Input validation**:
   - Validate and sanitize all user input
   - Implement spam detection mechanisms
   - Consider CAPTCHA for anonymous submissions

### Migration Path to Production

To prepare for production:
1. Create a backend service (e.g., using AWS Lambda, Cloud Functions, or a dedicated server)
2. Implement POST endpoint `/api/feedback` that accepts feedback data
3. Backend authenticates to GitHub using secure token storage
4. Update `GitHubService.swift` to call your backend instead of GitHub directly
5. Remove `GITHUB_TOKEN` environment variable requirement

## User Experience

The feedback form:
- Does not reveal to users that submissions go to GitHub
- Uses generic language like "submit feedback" and "your submission"
- Provides a clean, branded interface matching the app's design
- Categorizes feedback as either "Feature Request" or "Bug Report"
- Automatically labels GitHub issues based on feedback type

## Testing

To test the feedback form without a valid token, the app will show a configuration error message to the user.
