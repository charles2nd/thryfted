# Thryfted Documentation

This directory contains all documentation for the Thryfted Flutter app project.

## 📚 Available Documentation

### [HOW-TO-RUN.md](./HOW-TO-RUN.md)
Complete guide for running the Thryfted iOS app on simulator, including:
- **Working Xcode build method** (✅ Tested)
- **App logging and debugging**
- Troubleshooting codesigning issues
- Device management commands
- Clean build procedures

### [CONVEX_SETUP.md](./CONVEX_SETUP.md)
Setup guide for Convex real-time database backend:
- Database schema configuration
- WebSocket integration
- Chat functionality implementation
- Environment configuration

### [../CLAUDE.md](../CLAUDE.md)
Project instructions and development guidelines:
- Flutter project structure
- State management with Riverpod
- Authentication system (Clerk + Firebase)
- Code generation requirements
- Development workflow

## 🚀 Quick Start

1. **Run the app:**
   ```bash
   ./run-app.sh
   ```

2. **View logs:**
   ```bash
   flutter logs --device-id=900D2921-1B10-4D29-8207-C45A082D10AE
   ```

3. **Chat functionality:**
   - Convex backend is configured at: `https://first-mule-995.convex.cloud`
   - Real-time messaging on third tab of the app

## 📱 Project Status

- ✅ **iOS Simulator**: Working via Xcode build
- ❌ **Flutter Run**: Currently broken (codesigning issues)
- ✅ **Convex Backend**: Deployed and configured
- ✅ **Chat Feature**: Implemented with real-time messaging

## 🔧 Development Environment

- **Flutter**: 3.24.3+ with Dart 3.5.3+
- **iOS**: Xcode 16+ required
- **Database**: Convex real-time backend
- **Auth**: Clerk (primary) + Firebase (fallback)
- **State**: Riverpod with code generation

## 📞 Support

For issues or questions:
1. Check the specific documentation files above
2. Run `flutter doctor` for environment issues
3. Use Xcode direct build method for reliability

---

*Updated: December 2024 | Thryfted - Sustainable Fashion Marketplace*