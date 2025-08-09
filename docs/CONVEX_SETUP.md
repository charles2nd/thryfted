# Convex Setup Guide for Thryfted Chat

## Prerequisites

1. **Node.js**: Make sure you have Node.js installed
2. **Convex Account**: Create an account at https://convex.dev

## Step 1: Install Convex CLI

```bash
npm install -g convex
```

## Step 2: Initialize Convex Project

In your project root directory:

```bash
# Initialize Convex
npx convex dev --once

# This will:
# 1. Create a new Convex project
# 2. Give you a project URL
# 3. Generate authentication keys
```

## Step 3: Update Environment Variables

After running `npx convex dev --once`, you'll get a project URL. Update your `.env` file:

```bash
# Replace 'your-project-name' with your actual Convex project name
CONVEX_URL=https://your-project-name.convex.cloud
```

## Step 4: Configure Clerk Authentication

1. In the Convex dashboard (https://dashboard.convex.dev):
   - Go to your project settings
   - Navigate to "Authentication"
   - Add Clerk as an authentication provider
   - Use your Clerk domain: `https://obliging-raptor-71.clerk.accounts.dev`

2. In your Clerk dashboard:
   - Add your Convex project URL to allowed origins
   - Configure JWT template for Convex integration

## Step 5: Deploy Convex Functions

```bash
# Deploy all your Convex functions
npx convex deploy

# This deploys:
# - convex/schema.ts
# - convex/messages.ts  
# - convex/conversations.ts
# - convex/users.ts
```

## Step 6: Test the Integration

1. **Build and run your Flutter app**:
   ```bash
   # From the ios directory
   cd ios
   xcodebuild -workspace Runner.xcworkspace \
     -scheme Runner \
     -configuration Debug \
     -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
     CODE_SIGNING_ALLOWED=NO \
     CODE_SIGNING_REQUIRED=NO \
     CODE_SIGN_IDENTITY="" \
     build

   # Install and launch
   APP_PATH=$(find /Users/charles/Library/Developer/Xcode/DerivedData -name "Runner.app" -type d | head -1)
   xcrun simctl install 900D2921-1B10-4D29-8207-C45A082D10AE "$APP_PATH"
   xcrun simctl launch 900D2921-1B10-4D29-8207-C45A082D10AE com.thryfted.app
   ```

2. **Navigate to Messages tab** (3rd tab) to test the chat functionality

## Step 7: Create Test Data (Optional)

You can create test conversations and messages using the Convex dashboard or by adding test users through your Clerk authentication.

## Troubleshooting

### Common Issues:

1. **WebSocket Connection Failed**:
   - Check your CONVEX_URL in .env
   - Ensure Convex project is deployed
   - Verify network connectivity

2. **Authentication Issues**:
   - Verify Clerk domain in convex.json
   - Check JWT configuration in Clerk
   - Ensure user is properly authenticated

3. **Functions Not Found**:
   - Run `npx convex deploy` again
   - Check function names match in Flutter code
   - Verify schema is deployed

### Debug Commands:

```bash
# Check Convex status
npx convex dev

# View logs
npx convex logs

# Check deployed functions
npx convex functions list
```

## Production Considerations

1. **Environment Variables**: Use production Convex URLs in production builds
2. **Rate Limiting**: Configure appropriate rate limits for your API
3. **Data Validation**: Add server-side validation in Convex functions
4. **Monitoring**: Set up monitoring for your Convex functions
5. **Backup**: Configure data backup strategies

## Chat Features Ready to Use

Once setup is complete, you'll have:

- ✅ Real-time messaging between users
- ✅ Conversation management for item discussions  
- ✅ Typing indicators
- ✅ Unread message counts
- ✅ Offer system for buyers
- ✅ Search functionality
- ✅ Message history
- ✅ User synchronization with Clerk

## Next Steps

After completing the setup:

1. Test the chat functionality
2. Add real item data to create meaningful conversations
3. Customize the UI as needed
4. Add image sharing capabilities
5. Implement push notifications for messages

---

*Need help? Check the [Convex Documentation](https://docs.convex.dev) or the [Clerk Integration Guide](https://docs.convex.dev/auth/clerk)*