import {configureStore, combineReducers} from '@reduxjs/toolkit';
import {
  persistStore,
  persistReducer,
  FLUSH,
  REHYDRATE,
  PAUSE,
  PERSIST,
  PURGE,
  REGISTER,
} from 'redux-persist';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Slice imports
import authSlice from './slices/authSlice';
import userSlice from './slices/userSlice';
import listingSlice from './slices/listingSlice';
import searchSlice from './slices/searchSlice';
import messagingSlice from './slices/messagingSlice';
import cartSlice from './slices/cartSlice';
import notificationSlice from './slices/notificationSlice';
import appSlice from './slices/appSlice';

// Root reducer
const rootReducer = combineReducers({
  auth: authSlice,
  user: userSlice,
  listing: listingSlice,
  search: searchSlice,
  messaging: messagingSlice,
  cart: cartSlice,
  notification: notificationSlice,
  app: appSlice,
});

// Persist configuration
const persistConfig = {
  key: 'root',
  version: 1,
  storage: AsyncStorage,
  whitelist: [
    'auth', // Persist authentication state
    'user', // Persist user preferences
    'cart', // Persist cart items
    'app', // Persist app settings
  ],
  blacklist: [
    'listing', // Don't persist listing data (fetch fresh)
    'search', // Don't persist search results
    'messaging', // Don't persist messages (fetch fresh)
    'notification', // Don't persist notifications
  ],
};

const persistedReducer = persistReducer(persistConfig, rootReducer);

// Store configuration
export const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        ignoredActions: [FLUSH, REHYDRATE, PAUSE, PERSIST, PURGE, REGISTER],
        // Ignore these field paths in all actions
        ignoredActionsPaths: ['meta.arg', 'payload.timestamp'],
        // Ignore these paths in the state
        ignoredPaths: ['items.dates'],
      },
      immutableCheck: {
        // Ignore these paths in the state for immutability checks
        ignoredPaths: ['auth.tokens', 'user.preferences'],
      },
    }),
  devTools: __DEV__,
});

export const persistor = persistStore(store);

// TypeScript types
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;

// Export individual slice actions for easier imports
export * from './slices/authSlice';
export * from './slices/userSlice';
export * from './slices/listingSlice';
export * from './slices/searchSlice';
export * from './slices/messagingSlice';
export * from './slices/cartSlice';
export * from './slices/notificationSlice';
export * from './slices/appSlice';