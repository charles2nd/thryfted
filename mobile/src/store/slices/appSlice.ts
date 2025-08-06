import {createSlice, PayloadAction} from '@reduxjs/toolkit';

interface AppState {
  isLoading: boolean;
  isOnboardingComplete: boolean;
  theme: 'light' | 'dark' | 'auto';
  language: string;
  currency: string;
  location: {
    country: string;
    city: string;
    latitude?: number;
    longitude?: number;
  } | null;
  notificationPermission: boolean;
  cameraPermission: boolean;
  locationPermission: boolean;
  networkStatus: 'online' | 'offline' | 'unknown';
  appVersion: string;
  buildNumber: string;
}

const initialState: AppState = {
  isLoading: false,
  isOnboardingComplete: false,
  theme: 'auto',
  language: 'en',
  currency: 'USD',
  location: null,
  notificationPermission: false,
  cameraPermission: false,
  locationPermission: false,
  networkStatus: 'unknown',
  appVersion: '1.0.0',
  buildNumber: '1',
};

const appSlice = createSlice({
  name: 'app',
  initialState,
  reducers: {
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setOnboardingComplete: (state, action: PayloadAction<boolean>) => {
      state.isOnboardingComplete = action.payload;
    },
    setTheme: (state, action: PayloadAction<'light' | 'dark' | 'auto'>) => {
      state.theme = action.payload;
    },
    setLanguage: (state, action: PayloadAction<string>) => {
      state.language = action.payload;
    },
    setCurrency: (state, action: PayloadAction<string>) => {
      state.currency = action.payload;
    },
    setLocation: (
      state,
      action: PayloadAction<{
        country: string;
        city: string;
        latitude?: number;
        longitude?: number;
      } | null>
    ) => {
      state.location = action.payload;
    },
    setNotificationPermission: (state, action: PayloadAction<boolean>) => {
      state.notificationPermission = action.payload;
    },
    setCameraPermission: (state, action: PayloadAction<boolean>) => {
      state.cameraPermission = action.payload;
    },
    setLocationPermission: (state, action: PayloadAction<boolean>) => {
      state.locationPermission = action.payload;
    },
    setNetworkStatus: (state, action: PayloadAction<'online' | 'offline' | 'unknown'>) => {
      state.networkStatus = action.payload;
    },
    setAppVersion: (state, action: PayloadAction<{version: string; buildNumber: string}>) => {
      state.appVersion = action.payload.version;
      state.buildNumber = action.payload.buildNumber;
    },
  },
});

export const {
  setLoading,
  setOnboardingComplete,
  setTheme,
  setLanguage,
  setCurrency,
  setLocation,
  setNotificationPermission,
  setCameraPermission,
  setLocationPermission,
  setNetworkStatus,
  setAppVersion,
} = appSlice.actions;

export default appSlice.reducer;

// Selectors
export const selectApp = (state: {app: AppState}) => state.app;
export const selectIsLoading = (state: {app: AppState}) => state.app.isLoading;
export const selectIsOnboardingComplete = (state: {app: AppState}) => state.app.isOnboardingComplete;
export const selectTheme = (state: {app: AppState}) => state.app.theme;
export const selectLanguage = (state: {app: AppState}) => state.app.language;
export const selectCurrency = (state: {app: AppState}) => state.app.currency;
export const selectLocation = (state: {app: AppState}) => state.app.location;
export const selectNotificationPermission = (state: {app: AppState}) => state.app.notificationPermission;
export const selectCameraPermission = (state: {app: AppState}) => state.app.cameraPermission;
export const selectLocationPermission = (state: {app: AppState}) => state.app.locationPermission;
export const selectNetworkStatus = (state: {app: AppState}) => state.app.networkStatus;
export const selectAppVersion = (state: {app: AppState}) => state.app.appVersion;
export const selectBuildNumber = (state: {app: AppState}) => state.app.buildNumber;