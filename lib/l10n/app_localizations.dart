import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Thryfted'**
  String get appName;

  /// App tagline/subtitle
  ///
  /// In en, this message translates to:
  /// **'Your sustainable fashion marketplace'**
  String get appTagline;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get navSell;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get navProfile;

  /// No description provided for @welcomeToThryfted.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Thryfted'**
  String get welcomeToThryfted;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms and Conditions'**
  String get acceptTerms;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmMessage;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @favoritesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Items you love'**
  String get favoritesSubtitle;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get orderHistory;

  /// No description provided for @orderHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your purchases'**
  String get orderHistorySubtitle;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get myListings;

  /// No description provided for @myListingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Items you\'re selling'**
  String get myListingsSubtitle;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @walletSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Earnings and balance'**
  String get walletSubtitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account preferences'**
  String get settingsSubtitle;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @helpAndSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get help'**
  String get helpAndSupportSubtitle;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmail;

  /// No description provided for @emailVerified.
  ///
  /// In en, this message translates to:
  /// **'Email verified'**
  String get emailVerified;

  /// No description provided for @phoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone verified'**
  String get phoneVerified;

  /// No description provided for @sellerVerified.
  ///
  /// In en, this message translates to:
  /// **'Seller verified'**
  String get sellerVerified;

  /// No description provided for @noRating.
  ///
  /// In en, this message translates to:
  /// **'No rating'**
  String get noRating;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get homeTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find your next favorite piece'**
  String get homeSubtitle;

  /// No description provided for @featuredItems.
  ///
  /// In en, this message translates to:
  /// **'Featured Items'**
  String get featuredItems;

  /// No description provided for @newArrivals.
  ///
  /// In en, this message translates to:
  /// **'New Arrivals'**
  String get newArrivals;

  /// No description provided for @trending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get trending;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// Welcome message with user name
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {userName}! 👋'**
  String welcomeBack(String userName);

  /// No description provided for @discoverMessage.
  ///
  /// In en, this message translates to:
  /// **'Discover amazing secondhand fashion finds'**
  String get discoverMessage;

  /// No description provided for @marketplaceComingSoon.
  ///
  /// In en, this message translates to:
  /// **'🛍️ Marketplace coming soon!'**
  String get marketplaceComingSoon;

  /// No description provided for @marketplaceFeatures.
  ///
  /// In en, this message translates to:
  /// **'Here you\'ll discover:\n\n• Personalized item recommendations\n• Items from people you follow\n• Featured listings\n• Trending categories\n• Local finds near you'**
  String get marketplaceFeatures;

  /// Placeholder text for items
  ///
  /// In en, this message translates to:
  /// **'Item {number}'**
  String itemPlaceholder(int number);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for items, brands, users...'**
  String get searchHint;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @popularSearches.
  ///
  /// In en, this message translates to:
  /// **'Popular Searches'**
  String get popularSearches;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @condition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get condition;

  /// No description provided for @priceRange.
  ///
  /// In en, this message translates to:
  /// **'Price Range'**
  String get priceRange;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @noResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search terms'**
  String get noResultsMessage;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @sellYourItems.
  ///
  /// In en, this message translates to:
  /// **'Sell Your Items'**
  String get sellYourItems;

  /// No description provided for @sellDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn your closet into cash'**
  String get sellDescription;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @addPhotosDescription.
  ///
  /// In en, this message translates to:
  /// **'Add up to 8 photos'**
  String get addPhotosDescription;

  /// No description provided for @itemTitle.
  ///
  /// In en, this message translates to:
  /// **'Item Title'**
  String get itemTitle;

  /// No description provided for @itemDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get itemDescription;

  /// No description provided for @itemPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get itemPrice;

  /// No description provided for @itemBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get itemBrand;

  /// No description provided for @itemSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get itemSize;

  /// No description provided for @itemColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get itemColor;

  /// No description provided for @itemCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get itemCondition;

  /// No description provided for @itemCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get itemCategory;

  /// No description provided for @publishListing.
  ///
  /// In en, this message translates to:
  /// **'Publish Listing'**
  String get publishListing;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draftSaved;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @noMessagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Start buying or selling to chat with other users'**
  String get noMessagesDescription;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Last seen timestamp
  ///
  /// In en, this message translates to:
  /// **'Last seen {time}'**
  String lastSeen(String time);

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @buyNow.
  ///
  /// In en, this message translates to:
  /// **'Buy Now'**
  String get buyNow;

  /// No description provided for @makeOffer.
  ///
  /// In en, this message translates to:
  /// **'Make Offer'**
  String get makeOffer;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @shipping.
  ///
  /// In en, this message translates to:
  /// **'Shipping'**
  String get shipping;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @taxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get taxes;

  /// No description provided for @shippingCost.
  ///
  /// In en, this message translates to:
  /// **'Shipping Cost'**
  String get shippingCost;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @purchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @errorGeneral.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorGeneral;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get errorNetwork;

  /// No description provided for @errorAuth.
  ///
  /// In en, this message translates to:
  /// **'Authentication error. Please sign in again.'**
  String get errorAuth;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get errorNotFound;

  /// No description provided for @errorPermission.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get errorPermission;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get phoneInvalid;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Time ago in minutes (singular)
  ///
  /// In en, this message translates to:
  /// **'{count} minute ago'**
  String minuteAgo(int count);

  /// Time ago in minutes (plural)
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// Time ago in hours (singular)
  ///
  /// In en, this message translates to:
  /// **'{count} hour ago'**
  String hourAgo(int count);

  /// Time ago in hours (plural)
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// Time ago in days (singular)
  ///
  /// In en, this message translates to:
  /// **'{count} day ago'**
  String dayAgo(int count);

  /// Time ago in days (plural)
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @searchForItems.
  ///
  /// In en, this message translates to:
  /// **'Search for clothes, brands, and more...'**
  String get searchForItems;

  /// No description provided for @trendingSearches.
  ///
  /// In en, this message translates to:
  /// **'Trending searches'**
  String get trendingSearches;

  /// No description provided for @browseByCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Browse by category'**
  String get browseByCategoryTitle;

  /// No description provided for @startSearching.
  ///
  /// In en, this message translates to:
  /// **'Start searching!'**
  String get startSearching;

  /// No description provided for @startSearchingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the search bar above to find amazing secondhand fashion items'**
  String get startSearchingSubtitle;

  /// No description provided for @women.
  ///
  /// In en, this message translates to:
  /// **'Women'**
  String get women;

  /// No description provided for @men.
  ///
  /// In en, this message translates to:
  /// **'Men'**
  String get men;

  /// No description provided for @kids.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get kids;

  /// No description provided for @shoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get shoes;

  /// No description provided for @accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessories;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @listAnItem.
  ///
  /// In en, this message translates to:
  /// **'List an item'**
  String get listAnItem;

  /// No description provided for @listAnItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take photos and create your listing in minutes'**
  String get listAnItemSubtitle;

  /// No description provided for @startSelling.
  ///
  /// In en, this message translates to:
  /// **'Start selling'**
  String get startSelling;

  /// No description provided for @turnWardrobeIntoCash.
  ///
  /// In en, this message translates to:
  /// **'Turn your wardrobe into cash'**
  String get turnWardrobeIntoCash;

  /// No description provided for @sellingTips.
  ///
  /// In en, this message translates to:
  /// **'Selling tips'**
  String get sellingTips;

  /// No description provided for @takeGreatPhotos.
  ///
  /// In en, this message translates to:
  /// **'Take great photos'**
  String get takeGreatPhotos;

  /// No description provided for @takeGreatPhotosSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Good lighting and clear images sell faster'**
  String get takeGreatPhotosSubtitle;

  /// No description provided for @priceCompetitively.
  ///
  /// In en, this message translates to:
  /// **'Price competitively'**
  String get priceCompetitively;

  /// No description provided for @priceCompetitivelySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Research similar items to set the right price'**
  String get priceCompetitivelySubtitle;

  /// No description provided for @writeDetailedDescriptions.
  ///
  /// In en, this message translates to:
  /// **'Write detailed descriptions'**
  String get writeDetailedDescriptions;

  /// No description provided for @writeDetailedDescriptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Include size, condition, and brand information'**
  String get writeDetailedDescriptionsSubtitle;

  /// No description provided for @respondQuickly.
  ///
  /// In en, this message translates to:
  /// **'Respond quickly'**
  String get respondQuickly;

  /// No description provided for @respondQuicklySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick responses increase your chances of selling'**
  String get respondQuicklySubtitle;

  /// No description provided for @noListingsYet.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get noListingsYet;

  /// No description provided for @createFirstListing.
  ///
  /// In en, this message translates to:
  /// **'Create your first listing to start selling'**
  String get createFirstListing;

  /// No description provided for @createListing.
  ///
  /// In en, this message translates to:
  /// **'Create Listing'**
  String get createListing;

  /// No description provided for @createListingMessage.
  ///
  /// In en, this message translates to:
  /// **'The listing creation feature will be implemented soon. This will include photo upload, item details, and pricing.'**
  String get createListingMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @searchConversations.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get searchConversations;

  /// No description provided for @isItemAvailable.
  ///
  /// In en, this message translates to:
  /// **'Is this item still available?'**
  String get isItemAvailable;

  /// No description provided for @thanksForDelivery.
  ///
  /// In en, this message translates to:
  /// **'Thanks for the quick delivery!'**
  String get thanksForDelivery;

  /// No description provided for @sendMorePhotos.
  ///
  /// In en, this message translates to:
  /// **'Could you send more photos?'**
  String get sendMorePhotos;

  /// No description provided for @noMoreMessages.
  ///
  /// In en, this message translates to:
  /// **'No more messages'**
  String get noMoreMessages;

  /// No description provided for @startBuyingOrSelling.
  ///
  /// In en, this message translates to:
  /// **'Start buying or selling to begin conversations with other users'**
  String get startBuyingOrSelling;

  /// No description provided for @startShopping.
  ///
  /// In en, this message translates to:
  /// **'Start shopping'**
  String get startShopping;

  /// Chat dialog title
  ///
  /// In en, this message translates to:
  /// **'Chat with {userName}'**
  String chatWith(String userName);

  /// No description provided for @messagingFeatureMessage.
  ///
  /// In en, this message translates to:
  /// **'The messaging feature will be implemented soon. This will include real-time chat, image sharing, and push notifications.'**
  String get messagingFeatureMessage;

  /// No description provided for @yourActivity.
  ///
  /// In en, this message translates to:
  /// **'Your activity'**
  String get yourActivity;

  /// No description provided for @itemsSold.
  ///
  /// In en, this message translates to:
  /// **'Items sold'**
  String get itemsSold;

  /// No description provided for @itemsBought.
  ///
  /// In en, this message translates to:
  /// **'Items bought'**
  String get itemsBought;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @verificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get verificationStatus;

  /// No description provided for @profileComplete.
  ///
  /// In en, this message translates to:
  /// **'Profile Complete'**
  String get profileComplete;

  /// No description provided for @connectedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Connected Accounts'**
  String get connectedAccounts;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @shareProfile.
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfile;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @featureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'This feature is being developed and will be available in a future update.'**
  String get featureInDevelopment;

  /// Member registration date
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// Last activity timestamp
  ///
  /// In en, this message translates to:
  /// **'Last active {time}'**
  String lastActive(String time);

  /// No description provided for @sellerRating.
  ///
  /// In en, this message translates to:
  /// **'seller rating'**
  String get sellerRating;

  /// No description provided for @emailVerification.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get emailVerification;

  /// No description provided for @phoneVerification.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification'**
  String get phoneVerification;

  /// No description provided for @sellerVerification.
  ///
  /// In en, this message translates to:
  /// **'Seller Verification'**
  String get sellerVerification;

  /// No description provided for @profileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile Completion'**
  String get profileCompletion;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get completeProfile;

  /// No description provided for @buildTrust.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to build trust with buyers and sellers'**
  String get buildTrust;

  /// No description provided for @addFirstName.
  ///
  /// In en, this message translates to:
  /// **'Add first name'**
  String get addFirstName;

  /// No description provided for @addLastName.
  ///
  /// In en, this message translates to:
  /// **'Add last name'**
  String get addLastName;

  /// No description provided for @addPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Add phone number'**
  String get addPhoneNumber;

  /// No description provided for @addProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Add profile photo'**
  String get addProfilePhoto;

  /// No description provided for @startBuyingSelling.
  ///
  /// In en, this message translates to:
  /// **'Start buying or selling to build your marketplace reputation!'**
  String get startBuyingSelling;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @manageAlerts.
  ///
  /// In en, this message translates to:
  /// **'Manage your alerts'**
  String get manageAlerts;

  /// No description provided for @privacySafety.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Safety'**
  String get privacySafety;

  /// No description provided for @accountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account security settings'**
  String get accountSecurity;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @helpImprove.
  ///
  /// In en, this message translates to:
  /// **'Help us improve Thryfted'**
  String get helpImprove;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersionInfo.
  ///
  /// In en, this message translates to:
  /// **'App version and info'**
  String get appVersionInfo;

  /// No description provided for @newUser.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newUser;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get editProfileSubtitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get usernameHint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get phoneNumberHint;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @updatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get updatingProfile;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @profileUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateError;

  /// No description provided for @shareProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfileTitle;

  /// Text shared when sharing profile
  ///
  /// In en, this message translates to:
  /// **'Check out my profile on Thryfted! 👋\n\n{displayName}\n{stats}\n\nJoin me on Thryfted - your sustainable fashion marketplace!'**
  String shareProfileText(String displayName, String stats);

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification link to your email address. Click the link to verify your account.'**
  String get verifyEmailMessage;

  /// No description provided for @verifyEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Email'**
  String get verifyEmailButton;

  /// No description provided for @verifyEmailSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent successfully'**
  String get verifyEmailSuccess;

  /// No description provided for @verifyEmailError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification email'**
  String get verifyEmailError;

  /// No description provided for @verifyPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Phone Verification'**
  String get verifyPhoneTitle;

  /// No description provided for @verifyPhoneMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to receive a verification code via SMS.'**
  String get verifyPhoneMessage;

  /// No description provided for @verifyPhoneButton.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get verifyPhoneButton;

  /// No description provided for @verifyPhoneSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent successfully'**
  String get verifyPhoneSuccess;

  /// No description provided for @verifyPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Failed to send verification code'**
  String get verifyPhoneError;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterVerificationCode;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get verificationCode;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get verifyCode;

  /// No description provided for @verifySellerTitle.
  ///
  /// In en, this message translates to:
  /// **'Seller Verification'**
  String get verifySellerTitle;

  /// No description provided for @verifySellerMessage.
  ///
  /// In en, this message translates to:
  /// **'To become a verified seller, you need to:\n\n• Complete your profile with first name, last name, and photo\n• Verify your email address\n• Verify your phone number\n• Provide additional identity verification'**
  String get verifySellerMessage;

  /// No description provided for @verifySellerButton.
  ///
  /// In en, this message translates to:
  /// **'Start Verification'**
  String get verifySellerButton;

  /// No description provided for @sellerVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Seller verification is pending review'**
  String get sellerVerificationPending;

  /// No description provided for @sellerVerificationComplete.
  ///
  /// In en, this message translates to:
  /// **'You are a verified seller'**
  String get sellerVerificationComplete;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationUsernameLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters long'**
  String get validationUsernameLength;

  /// No description provided for @validationUsernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Username can only contain letters, numbers, and underscores'**
  String get validationUsernameInvalid;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get validationPhoneInvalid;

  /// No description provided for @sendOffer.
  ///
  /// In en, this message translates to:
  /// **'Send Offer'**
  String get sendOffer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
