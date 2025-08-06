// User Management Types
export interface User {
  id: string;
  email: string;
  username?: string;
  firstName?: string;
  lastName?: string;
  profilePicture?: string;
  bio?: string;
  isVerified: boolean;
  isEmailVerified: boolean;
  isPhoneVerified: boolean;
  phoneNumber?: string;
  dateOfBirth?: string;
  location?: Address;
  preferences: UserPreferences;
  createdAt: string;
  updatedAt: string;
  lastActiveAt: string;
  trustScore: number;
  totalSales: number;
  totalPurchases: number;
  followers: number;
  following: number;
}

export interface UserPreferences {
  language: string;
  currency: string;
  notifications: NotificationSettings;
  privacy: PrivacySettings;
  sizes: SizePreferences;
  brands: string[];
  categories: string[];
}

export interface NotificationSettings {
  pushNotifications: boolean;
  emailNotifications: boolean;
  smsNotifications: boolean;
  marketingEmails: boolean;
  newMessages: boolean;
  offers: boolean;
  priceDrops: boolean;
  newFollowers: boolean;
}

export interface PrivacySettings {
  showLastSeen: boolean;
  showLocation: boolean;
  allowDirectMessages: boolean;
  showFollowers: boolean;
  showFollowing: boolean;
}

export interface SizePreferences {
  clothing?: ClothingSize;
  shoes?: ShoeSize;
}

export interface Address {
  id?: string;
  street: string;
  city: string;
  state: string;
  postalCode: string;
  country: string;
  isDefault?: boolean;
}

// Product/Listing Types
export interface Listing {
  id: string;
  sellerId: string;
  seller: User;
  title: string;
  description: string;
  category: Category;
  subcategory?: string;
  brand?: string;
  condition: ItemCondition;
  price: number;
  originalPrice?: number;
  currency: string;
  size?: string;
  color: string[];
  material?: string;
  photos: Photo[];
  tags: string[];
  dimensions?: Dimensions;
  weight?: number;
  isActive: boolean;
  isSold: boolean;
  isReserved: boolean;
  views: number;
  likes: number;
  bookmarks: number;
  createdAt: string;
  updatedAt: string;
  soldAt?: string;
  shippingOptions: ShippingOption[];
  bundleDiscount?: number;
  location: Address;
  isPromoted?: boolean;
  promotionEndsAt?: string;
}

export interface Photo {
  id: string;
  url: string;
  thumbnailUrl?: string;
  alt?: string;
  order: number;
}

export interface Dimensions {
  length: number;
  width: number;
  height: number;
  unit: 'cm' | 'in';
}

export enum ItemCondition {
  NEW_WITH_TAGS = 'new_with_tags',
  NEW_WITHOUT_TAGS = 'new_without_tags',
  VERY_GOOD = 'very_good',
  GOOD = 'good',
  SATISFACTORY = 'satisfactory',
}

export enum Category {
  WOMEN = 'women',
  MEN = 'men',
  KIDS = 'kids',
  HOME = 'home',
  ELECTRONICS = 'electronics',
  PETS = 'pets',
  ENTERTAINMENT = 'entertainment',
}

export interface ClothingSize {
  tops: string[];
  bottoms: string[];
  dresses: string[];
  shoes: string[];
}

export interface ShoeSize {
  us?: number;
  eu?: number;
  uk?: number;
}

// Transaction Types
export interface Order {
  id: string;
  buyerId: string;
  sellerId: string;
  listingId: string;
  listing: Listing;
  buyer: User;
  seller: User;
  status: OrderStatus;
  totalAmount: number;
  itemPrice: number;
  buyerProtectionFee: number;
  shippingCost: number;
  currency: string;
  shippingAddress: Address;
  billingAddress?: Address;
  paymentMethod: PaymentMethod;
  shippingMethod: ShippingMethod;
  trackingNumber?: string;
  carrierName?: string;
  estimatedDelivery?: string;
  actualDelivery?: string;
  createdAt: string;
  updatedAt: string;
  shippedAt?: string;
  deliveredAt?: string;
  disputeId?: string;
}

export enum OrderStatus {
  PENDING_PAYMENT = 'pending_payment',
  PAID = 'paid',
  SHIPPED = 'shipped',
  DELIVERED = 'delivered',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  DISPUTED = 'disputed',
  REFUNDED = 'refunded',
}

export interface PaymentMethod {
  id: string;
  type: 'card' | 'paypal' | 'apple_pay' | 'google_pay' | 'bank_transfer';
  last4?: string;
  brand?: string;
  expiryMonth?: number;
  expiryYear?: number;
  isDefault: boolean;
}

export interface ShippingMethod {
  id: string;
  name: string;
  carrier: string;
  estimatedDays: number;
  price: number;
  trackingIncluded: boolean;
  insuranceIncluded: boolean;
  signatureRequired?: boolean;
}

export interface ShippingOption {
  method: ShippingMethod;
  price: number;
  estimatedDelivery: string;
}

// Messaging Types
export interface Conversation {
  id: string;
  participants: string[];
  listingId?: string;
  listing?: Listing;
  lastMessage?: Message;
  unreadCount: number;
  createdAt: string;
  updatedAt: string;
}

export interface Message {
  id: string;
  conversationId: string;
  senderId: string;
  sender: User;
  content: string;
  type: MessageType;
  attachments?: MessageAttachment[];
  offer?: Offer;
  isRead: boolean;
  createdAt: string;
  updatedAt?: string;
}

export enum MessageType {
  TEXT = 'text',
  IMAGE = 'image',
  OFFER = 'offer',
  SYSTEM = 'system',
}

export interface MessageAttachment {
  id: string;
  type: 'image' | 'document';
  url: string;
  thumbnailUrl?: string;
  filename: string;
  size: number;
}

export interface Offer {
  id: string;
  listingId: string;
  buyerId: string;
  sellerId: string;
  amount: number;
  currency: string;
  status: OfferStatus;
  message?: string;
  expiresAt: string;
  createdAt: string;
  updatedAt?: string;
  acceptedAt?: string;
  rejectedAt?: string;
}

export enum OfferStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  REJECTED = 'rejected',
  EXPIRED = 'expired',
  CANCELLED = 'cancelled',
}

// Search & Filter Types
export interface SearchFilters {
  query?: string;
  category?: Category;
  subcategory?: string;
  brand?: string[];
  condition?: ItemCondition[];
  size?: string[];
  color?: string[];
  priceMin?: number;
  priceMax?: number;
  location?: string;
  shippingFree?: boolean;
  sortBy?: SortOption;
  sortOrder?: 'asc' | 'desc';
}

export enum SortOption {
  RELEVANCE = 'relevance',
  PRICE_LOW_HIGH = 'price_asc',
  PRICE_HIGH_LOW = 'price_desc',
  NEWEST = 'newest',
  OLDEST = 'oldest',
  POPULARITY = 'popularity',
  DISTANCE = 'distance',
}

export interface SearchResult {
  listings: Listing[];
  totalCount: number;
  totalPages: number;
  currentPage: number;
  filters: SearchFilters;
  suggestions?: string[];
}

// API Response Types
export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: ApiError;
  message?: string;
  meta?: {
    page?: number;
    totalPages?: number;
    totalCount?: number;
    hasNextPage?: boolean;
    hasPrevPage?: boolean;
  };
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, any>;
}

// Authentication Types
export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  expiresAt: string;
}

export interface LoginRequest {
  email: string;
  password: string;
  rememberMe?: boolean;
}

export interface RegisterRequest {
  email: string;
  password: string;
  firstName?: string;
  lastName?: string;
  acceptTerms: boolean;
}

export interface ResetPasswordRequest {
  token: string;
  newPassword: string;
}

// Utility Types
export interface PaginationParams {
  page?: number;
  limit?: number;
  offset?: number;
}

export interface UploadResult {
  url: string;
  thumbnailUrl?: string;
  width?: number;
  height?: number;
  size: number;
  format: string;
}

// Review & Rating Types
export interface Review {
  id: string;
  orderId: string;
  reviewerId: string;
  revieweeId: string;
  reviewer: User;
  reviewee: User;
  rating: number;
  comment?: string;
  type: 'seller' | 'buyer';
  createdAt: string;
  updatedAt?: string;
}

// Notification Types
export interface Notification {
  id: string;
  userId: string;
  type: NotificationType;
  title: string;
  body: string;
  data?: Record<string, any>;
  isRead: boolean;
  createdAt: string;
  readAt?: string;
}

export enum NotificationType {
  NEW_MESSAGE = 'new_message',
  NEW_OFFER = 'new_offer',
  OFFER_ACCEPTED = 'offer_accepted',
  OFFER_REJECTED = 'offer_rejected',
  ITEM_SOLD = 'item_sold',
  ITEM_SHIPPED = 'item_shipped',
  ITEM_DELIVERED = 'item_delivered',
  PRICE_DROP = 'price_drop',
  NEW_FOLLOWER = 'new_follower',
  PAYMENT_RECEIVED = 'payment_received',
  DISPUTE_OPENED = 'dispute_opened',
  SYSTEM_ANNOUNCEMENT = 'system_announcement',
}