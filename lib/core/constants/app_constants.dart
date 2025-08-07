class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String socketUrl = 'ws://localhost:8080';
  
  // App Configuration
  static const String appName = 'Thryfted';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Image Configuration
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Network timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}

class Endpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String socialLogin = '/auth/social';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  
  // User endpoints
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String changePassword = '/users/change-password';
  
  // Listing endpoints (for future implementation)
  static const String listings = '/listings';
  static const String createListing = '/listings';
  static const String searchListings = '/listings/search';
  
  // Message endpoints (for future implementation)
  static const String messages = '/messages';
  static const String conversations = '/messages/conversations';
}