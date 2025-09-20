# GitHub Actions Setup Guide

## Required Secrets

To enable Firebase App Distribution in the GitHub Actions workflow, you need to configure the following secrets in your GitHub repository:

### 1. Go to Repository Settings
1. Navigate to your GitHub repository
2. Click on **Settings** tab
3. In the left sidebar, click on **Secrets and variables** → **Actions**

### 2. Add Required Secrets

#### FIREBASE_APP_ID
- **Description**: Your Firebase project's Android app ID
- **How to find it**:
  1. Go to [Firebase Console](https://console.firebase.google.com/)
  2. Select your project
  3. Click on the gear icon (⚙️) → **Project settings**
  4. Scroll down to **Your apps** section
  5. Find your Android app and copy the **App ID** (format: `1:123456789:android:abcdef123456`)

#### FIREBASE_TOKEN
- **Description**: Firebase CLI token for authentication
- **How to generate**:
  1. Install Firebase CLI: `npm install -g firebase-tools`
  2. Login: `firebase login:ci`
  3. Copy the generated token
  4. Add it as a secret named `FIREBASE_TOKEN`

### 3. Add Secrets to Repository
1. Click **New repository secret**
2. Enter the secret name (e.g., `FIREBASE_APP_ID`)
3. Enter the secret value
4. Click **Add secret**
5. Repeat for `FIREBASE_TOKEN`

## Workflow Behavior

- **With secrets configured**: The workflow will automatically upload release APKs to Firebase App Distribution
- **Without secrets**: The workflow will skip Firebase upload and show a message indicating secrets are not configured
- **Partial secrets**: The workflow will skip Firebase upload if either secret is missing

## Testing the Setup

1. Push a commit to the `main` branch
2. Check the Actions tab in your GitHub repository
3. Verify that the workflow completes successfully
4. If Firebase upload is enabled, check Firebase App Distribution for the uploaded APK

## Troubleshooting

### Common Issues

1. **"Context access might be invalid"**: This usually means the secret is not configured or is empty
2. **Firebase upload fails**: Check that both `FIREBASE_APP_ID` and `FIREBASE_TOKEN` are correctly set
3. **Token expired**: Firebase tokens can expire; regenerate using `firebase login:ci`

### Verification Steps

1. Verify secrets are configured: Go to Settings → Secrets and variables → Actions
2. Check secret names match exactly: `FIREBASE_APP_ID` and `FIREBASE_TOKEN`
3. Ensure secret values are not empty
4. Test Firebase CLI locally: `firebase projects:list`
