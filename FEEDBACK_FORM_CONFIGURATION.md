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

**Important**: The current implementation uses an environment variable for the GitHub token. In a production environment, you should:

1. **Use a backend proxy**: Create a backend service that handles GitHub API calls to keep the token secure
2. **Never commit tokens**: Ensure tokens are never committed to source control
3. **Use GitHub Apps**: Consider using GitHub Apps for more secure and scalable authentication
4. **Rate limiting**: Implement rate limiting to prevent abuse

## User Experience

The feedback form:
- Does not reveal to users that submissions go to GitHub
- Uses generic language like "submit feedback" and "your submission"
- Provides a clean, branded interface matching the app's design
- Categorizes feedback as either "Feature Request" or "Bug Report"
- Automatically labels GitHub issues based on feedback type

## Testing

To test the feedback form without a valid token, the app will show a configuration error message to the user.
