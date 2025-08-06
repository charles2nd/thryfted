// App Configuration
export const APP_CONFIG = {
  name: 'Thryfted',
  version: '1.0.0',
  supportEmail: 'support@thryfted.com',
  websiteUrl: 'https://thryfted.com',
  termsUrl: 'https://thryfted.com/terms',
  privacyUrl: 'https://thryfted.com/privacy',
} as const;

// API Configuration
export const API_CONFIG = {
  baseUrl: process.env.API_BASE_URL || 'http://localhost:3000/api',
  version: 'v1',
  timeout: 10000,
  retries: 3,
} as const;

// Business Rules
export const BUSINESS_RULES = {
  // Fee Structure (matching Vinted)
  fees: {
    fixed: 0.70, // $0.70 fixed fee
    percentage: 0.05, // 5% variable fee
    sellerFee: 0, // Free for sellers
  },
  
  // Listing Limits
  listing: {
    maxPhotos: 20,
    maxDescriptionLength: 2000,
    maxTitleLength: 100,
    minPrice: 0.99,
    maxPrice: 10000,
  },
  
  // Messaging
  messaging: {
    maxMessageLength: 1000,
    maxAttachmentSize: 10 * 1024 * 1024, // 10MB
    allowedAttachmentTypes: ['image/jpeg', 'image/png', 'image/webp'],
  },
  
  // Offers
  offers: {
    minOfferPercentage: 0.4, // 40% of listing price
    offerExpiryHours: 48,
  },
  
  // Shipping
  shipping: {
    maxWeight: 30, // kg
    maxDimensions: {
      length: 120, // cm
      width: 60,
      height: 60,
    },
    inspectionPeriodDays: 2,
  },
} as const;

// UI Constants
export const UI_CONSTANTS = {
  pagination: {
    defaultLimit: 20,
    maxLimit: 100,
  },
  
  search: {
    debounceMs: 300,
    minQueryLength: 2,
    maxSuggestions: 5,
  },
  
  image: {
    maxUploadSize: 5 * 1024 * 1024, // 5MB
    allowedFormats: ['jpeg', 'jpg', 'png', 'webp'],
    thumbnailSize: { width: 300, height: 300 },
    listingSize: { width: 800, height: 800 },
  },
} as const;

// Category Mappings
export const CATEGORIES = {
  women: {
    id: 'women',
    name: 'Women',
    subcategories: [
      'clothing',
      'shoes',
      'bags',
      'accessories',
      'jewelry',
      'beauty',
      'activewear'
    ],
  },
  men: {
    id: 'men',
    name: 'Men',
    subcategories: [
      'clothing',
      'shoes',
      'bags',
      'accessories',
      'watches',
      'grooming',
      'activewear'
    ],
  },
  kids: {
    id: 'kids',
    name: 'Kids',
    subcategories: [
      'boys_clothing',
      'girls_clothing',
      'shoes',
      'toys',
      'accessories',
      'baby_items'
    ],
  },
  home: {
    id: 'home',
    name: 'Home & Living',
    subcategories: [
      'furniture',
      'decor',
      'kitchen',
      'bedding',
      'lighting',
      'storage'
    ],
  },
  electronics: {
    id: 'electronics',
    name: 'Electronics',
    subcategories: [
      'phones',
      'laptops',
      'tablets',
      'gaming',
      'audio',
      'accessories'
    ],
  },
  pets: {
    id: 'pets',
    name: 'Pets',
    subcategories: [
      'dog_supplies',
      'cat_supplies',
      'toys',
      'accessories',
      'food',
      'health'
    ],
  },
  entertainment: {
    id: 'entertainment',
    name: 'Entertainment',
    subcategories: [
      'books',
      'movies',
      'music',
      'games',
      'collectibles',
      'sports'
    ],
  },
} as const;

// Size Charts
export const SIZE_CHARTS = {
  women: {
    tops: ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'],
    bottoms: ['24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '36', '38'],
    dresses: ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL'],
    shoes: ['5', '5.5', '6', '6.5', '7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11'],
    international: {
      tops: {
        US: ['XXS', 'XS', 'S', 'M', 'L', 'XL', 'XXL'],
        EU: ['32', '34', '36', '38', '40', '42', '44'],
        UK: ['4', '6', '8', '10', '12', '14', '16'],
      },
    },
  },
  men: {
    tops: ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'],
    bottoms: ['28', '29', '30', '31', '32', '33', '34', '35', '36', '38', '40', '42'],
    shoes: ['7', '7.5', '8', '8.5', '9', '9.5', '10', '10.5', '11', '11.5', '12', '13'],
  },
  kids: {
    clothing: {
      baby: ['Newborn', '0-3M', '3-6M', '6-9M', '9-12M', '12-18M', '18-24M'],
      toddler: ['2T', '3T', '4T'],
      kids: ['4', '5', '6', '6X', '7', '8', '10', '12', '14', '16'],
    },
    shoes: {
      baby: ['1', '2', '3', '4'],
      toddler: ['5', '6', '7', '8', '9', '10'],
      kids: ['11', '12', '13', '1', '2', '3', '4', '5', '6'],
    },
  },
} as const;

// Currency Configuration
export const CURRENCIES = {
  USD: {
    code: 'USD',
    symbol: '$',
    name: 'US Dollar',
    decimals: 2,
  },
  EUR: {
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    decimals: 2,
  },
  GBP: {
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    decimals: 2,
  },
  CAD: {
    code: 'CAD',
    symbol: 'C$',
    name: 'Canadian Dollar',
    decimals: 2,
  },
} as const;

// Error Codes
export const ERROR_CODES = {
  // Authentication
  AUTH_REQUIRED: 'AUTH_REQUIRED',
  INVALID_CREDENTIALS: 'INVALID_CREDENTIALS',
  TOKEN_EXPIRED: 'TOKEN_EXPIRED',
  ACCOUNT_DISABLED: 'ACCOUNT_DISABLED',
  EMAIL_NOT_VERIFIED: 'EMAIL_NOT_VERIFIED',
  
  // Validation
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  MISSING_REQUIRED_FIELD: 'MISSING_REQUIRED_FIELD',
  INVALID_FORMAT: 'INVALID_FORMAT',
  VALUE_TOO_LONG: 'VALUE_TOO_LONG',
  VALUE_TOO_SHORT: 'VALUE_TOO_SHORT',
  
  // Business Logic
  LISTING_NOT_FOUND: 'LISTING_NOT_FOUND',
  LISTING_NOT_AVAILABLE: 'LISTING_NOT_AVAILABLE',
  INSUFFICIENT_FUNDS: 'INSUFFICIENT_FUNDS',
  PAYMENT_FAILED: 'PAYMENT_FAILED',
  OFFER_EXPIRED: 'OFFER_EXPIRED',
  ORDER_ALREADY_SHIPPED: 'ORDER_ALREADY_SHIPPED',
  
  // System
  INTERNAL_ERROR: 'INTERNAL_ERROR',
  SERVICE_UNAVAILABLE: 'SERVICE_UNAVAILABLE',
  RATE_LIMIT_EXCEEDED: 'RATE_LIMIT_EXCEEDED',
  FILE_UPLOAD_FAILED: 'FILE_UPLOAD_FAILED',
  
  // External Services
  STRIPE_ERROR: 'STRIPE_ERROR',
  EMAIL_SEND_FAILED: 'EMAIL_SEND_FAILED',
  SMS_SEND_FAILED: 'SMS_SEND_FAILED',
  SHIPPING_LABEL_FAILED: 'SHIPPING_LABEL_FAILED',
} as const;

// Status Codes
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  NO_CONTENT: 204,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  METHOD_NOT_ALLOWED: 405,
  CONFLICT: 409,
  UNPROCESSABLE_ENTITY: 422,
  RATE_LIMITED: 429,
  INTERNAL_SERVER_ERROR: 500,
  SERVICE_UNAVAILABLE: 503,
} as const;

// Regular Expressions
export const REGEX_PATTERNS = {
  email: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  phone: /^\+?[1-9]\d{1,14}$/,
  postalCode: {
    US: /^\d{5}(-\d{4})?$/,
    CA: /^[A-Z]\d[A-Z]\s?\d[A-Z]\d$/,
    UK: /^[A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2}$/,
  },
  password: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$/,
  username: /^[a-zA-Z0-9_]{3,20}$/,
  slug: /^[a-z0-9]+(?:-[a-z0-9]+)*$/,
} as const;

// Feature Flags
export const FEATURE_FLAGS = {
  VISUAL_SEARCH: false,
  AI_CATEGORIZATION: false,
  SOCIAL_FEATURES: false,
  CRYPTOCURRENCY_PAYMENTS: false,
  ITEM_AUTHENTICATION: false,
  AR_TRY_ON: false,
  LIVE_CHAT_SUPPORT: true,
  PUSH_NOTIFICATIONS: true,
  EMAIL_NOTIFICATIONS: true,
  BULK_LISTING: false,
  ADVANCED_ANALYTICS: false,
} as const;