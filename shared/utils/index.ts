import { BUSINESS_RULES, REGEX_PATTERNS } from '../constants';
import type { SearchFilters, User, Listing } from '../types';

// Validation Utilities
export const validation = {
  email: (email: string): boolean => REGEX_PATTERNS.email.test(email),
  
  phone: (phone: string): boolean => REGEX_PATTERNS.phone.test(phone),
  
  password: (password: string): boolean => REGEX_PATTERNS.password.test(password),
  
  username: (username: string): boolean => REGEX_PATTERNS.username.test(username),
  
  postalCode: (code: string, country: 'US' | 'CA' | 'UK'): boolean => {
    const pattern = REGEX_PATTERNS.postalCode[country];
    return pattern ? pattern.test(code) : true;
  },
  
  price: (price: number): boolean => {
    return price >= BUSINESS_RULES.listing.minPrice && price <= BUSINESS_RULES.listing.maxPrice;
  },
  
  listingTitle: (title: string): boolean => {
    return title.length > 0 && title.length <= BUSINESS_RULES.listing.maxTitleLength;
  },
  
  listingDescription: (description: string): boolean => {
    return description.length <= BUSINESS_RULES.listing.maxDescriptionLength;
  },
};

// Fee Calculation Utilities
export const fees = {
  calculateBuyerFees: (itemPrice: number) => {
    const fixedFee = BUSINESS_RULES.fees.fixed;
    const percentageFee = itemPrice * BUSINESS_RULES.fees.percentage;
    const totalFees = fixedFee + percentageFee;
    
    return {
      itemPrice,
      fixedFee,
      percentageFee,
      totalFees,
      totalPayable: itemPrice + totalFees,
    };
  },
  
  calculateSellerEarnings: (itemPrice: number, shippingCost: number = 0) => {
    // Sellers get 100% of item price, buyer pays all fees
    return {
      itemPrice,
      shippingReimbursement: shippingCost,
      totalEarnings: itemPrice + shippingCost,
      fees: 0, // No fees for sellers
    };
  },
};

// String Utilities
export const strings = {
  truncate: (str: string, length: number, suffix: string = '...'): string => {
    if (str.length <= length) return str;
    return str.substring(0, length - suffix.length) + suffix;
  },
  
  capitalize: (str: string): string => {
    return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
  },
  
  kebabCase: (str: string): string => {
    return str
      .replace(/([a-z])([A-Z])/g, '$1-$2')
      .replace(/[\s_]+/g, '-')
      .toLowerCase();
  },
  
  camelCase: (str: string): string => {
    return str.replace(/[-_](.)/g, (_, char) => char.toUpperCase());
  },
  
  generateSlug: (str: string): string => {
    return str
      .toLowerCase()
      .replace(/[^\w\s-]/g, '')
      .replace(/[\s_-]+/g, '-')
      .replace(/^-+|-+$/g, '');
  },
  
  formatCurrency: (amount: number, currency: string = 'USD'): string => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency,
      minimumFractionDigits: 2,
    }).format(amount);
  },
};

// Date Utilities
export const dates = {
  formatRelative: (date: string | Date): string => {
    const now = new Date();
    const target = new Date(date);
    const diffMs = now.getTime() - target.getTime();
    const diffSec = Math.floor(diffMs / 1000);
    const diffMin = Math.floor(diffSec / 60);
    const diffHour = Math.floor(diffMin / 60);
    const diffDay = Math.floor(diffHour / 24);
    
    if (diffSec < 60) return 'just now';
    if (diffMin < 60) return `${diffMin}m ago`;
    if (diffHour < 24) return `${diffHour}h ago`;
    if (diffDay < 7) return `${diffDay}d ago`;
    
    return target.toLocaleDateString();
  },
  
  addDays: (date: Date, days: number): Date => {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  },
  
  isWithinDays: (date: string | Date, days: number): boolean => {
    const now = new Date();
    const target = new Date(date);
    const diffMs = now.getTime() - target.getTime();
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
    
    return diffDays <= days;
  },
  
  formatISO: (date: Date = new Date()): string => {
    return date.toISOString();
  },
};

// Array Utilities
export const arrays = {
  unique: <T>(arr: T[]): T[] => [...new Set(arr)],
  
  groupBy: <T, K extends keyof T>(arr: T[], key: K): Record<string, T[]> => {
    return arr.reduce((groups, item) => {
      const group = String(item[key]);
      groups[group] = groups[group] || [];
      groups[group].push(item);
      return groups;
    }, {} as Record<string, T[]>);
  },
  
  sortBy: <T>(arr: T[], key: keyof T, order: 'asc' | 'desc' = 'asc'): T[] => {
    return [...arr].sort((a, b) => {
      const aVal = a[key];
      const bVal = b[key];
      
      if (aVal < bVal) return order === 'asc' ? -1 : 1;
      if (aVal > bVal) return order === 'asc' ? 1 : -1;
      return 0;
    });
  },
  
  chunk: <T>(arr: T[], size: number): T[][] => {
    const chunks: T[][] = [];
    for (let i = 0; i < arr.length; i += size) {
      chunks.push(arr.slice(i, i + size));
    }
    return chunks;
  },
};

// Search Utilities
export const search = {
  buildSearchQuery: (filters: SearchFilters): string => {
    const parts: string[] = [];
    
    if (filters.query) {
      parts.push(filters.query);
    }
    
    if (filters.category) {
      parts.push(`category:${filters.category}`);
    }
    
    if (filters.brand?.length) {
      parts.push(`brand:(${filters.brand.join(' OR ')})`);
    }
    
    if (filters.condition?.length) {
      parts.push(`condition:(${filters.condition.join(' OR ')})`);
    }
    
    if (filters.priceMin !== undefined || filters.priceMax !== undefined) {
      const min = filters.priceMin ?? 0;
      const max = filters.priceMax ?? '*';
      parts.push(`price:[${min} TO ${max}]`);
    }
    
    return parts.join(' AND ');
  },
  
  highlightSearchTerm: (text: string, term: string): string => {
    if (!term) return text;
    
    const regex = new RegExp(`(${term})`, 'gi');
    return text.replace(regex, '<mark>$1</mark>');
  },
};

// User Utilities
export const users = {
  getDisplayName: (user: User): string => {
    if (user.firstName && user.lastName) {
      return `${user.firstName} ${user.lastName}`;
    }
    if (user.firstName) {
      return user.firstName;
    }
    if (user.username) {
      return user.username;
    }
    return user.email.split('@')[0];
  },
  
  getTrustLevel: (user: User): 'low' | 'medium' | 'high' => {
    if (user.trustScore >= 4.5) return 'high';
    if (user.trustScore >= 3.5) return 'medium';
    return 'low';
  },
  
  isVerified: (user: User): boolean => {
    return user.isEmailVerified && user.isPhoneVerified;
  },
};

// Listing Utilities
export const listings = {
  isAvailable: (listing: Listing): boolean => {
    return listing.isActive && !listing.isSold && !listing.isReserved;
  },
  
  getConditionLabel: (condition: string): string => {
    const labels: Record<string, string> = {
      new_with_tags: 'New with tags',
      new_without_tags: 'New without tags',
      very_good: 'Very good',
      good: 'Good',
      satisfactory: 'Satisfactory',
    };
    
    return labels[condition] || condition;
  },
  
  calculateSavings: (currentPrice: number, originalPrice?: number): number | null => {
    if (!originalPrice || originalPrice <= currentPrice) return null;
    
    return Math.round(((originalPrice - currentPrice) / originalPrice) * 100);
  },
  
  getMainPhoto: (listing: Listing): string | undefined => {
    const sortedPhotos = [...listing.photos].sort((a, b) => a.order - b.order);
    return sortedPhotos[0]?.url;
  },
};

// File Utilities
export const files = {
  formatFileSize: (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  },
  
  getFileExtension: (filename: string): string => {
    return filename.slice(((filename.lastIndexOf('.') - 1) >>> 0) + 2);
  },
  
  isImageFile: (filename: string): boolean => {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'svg'];
    const extension = files.getFileExtension(filename).toLowerCase();
    return imageExtensions.includes(extension);
  },
};

// Error Utilities
export const errors = {
  isNetworkError: (error: Error): boolean => {
    return error.message.includes('Network') || error.message.includes('fetch');
  },
  
  getErrorMessage: (error: unknown): string => {
    if (error instanceof Error) {
      return error.message;
    }
    
    if (typeof error === 'string') {
      return error;
    }
    
    if (error && typeof error === 'object' && 'message' in error) {
      return String(error.message);
    }
    
    return 'An unknown error occurred';
  },
};

// Debounce Utility
export const debounce = <T extends (...args: any[]) => any>(
  func: T,
  wait: number
): ((...args: Parameters<T>) => void) => {
  let timeout: NodeJS.Timeout | null = null;
  
  return (...args: Parameters<T>) => {
    if (timeout) {
      clearTimeout(timeout);
    }
    
    timeout = setTimeout(() => func(...args), wait);
  };
};

// Throttle Utility
export const throttle = <T extends (...args: any[]) => any>(
  func: T,
  limit: number
): ((...args: Parameters<T>) => void) => {
  let inThrottle = false;
  
  return (...args: Parameters<T>) => {
    if (!inThrottle) {
      func(...args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }
  };
};

// Local Storage Utilities (for web)
export const storage = {
  set: (key: string, value: any): void => {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error('Failed to save to localStorage:', error);
    }
  },
  
  get: <T = any>(key: string): T | null => {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : null;
    } catch (error) {
      console.error('Failed to read from localStorage:', error);
      return null;
    }
  },
  
  remove: (key: string): void => {
    try {
      localStorage.removeItem(key);
    } catch (error) {
      console.error('Failed to remove from localStorage:', error);
    }
  },
  
  clear: (): void => {
    try {
      localStorage.clear();
    } catch (error) {
      console.error('Failed to clear localStorage:', error);
    }
  },
};

// Default export with all utilities
export default {
  validation,
  fees,
  strings,
  dates,
  arrays,
  search,
  users,
  listings,
  files,
  errors,
  debounce,
  throttle,
  storage,
};