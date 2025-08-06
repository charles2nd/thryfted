import {createSlice, createAsyncThunk, PayloadAction} from '@reduxjs/toolkit';
import {AuthTokens, User, LoginRequest, RegisterRequest} from '@shared/types';
import * as AuthService from '@services/auth';
import * as KeychainService from '@services/keychain';

interface AuthState {
  user: User | null;
  tokens: AuthTokens | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  isFirstLaunch: boolean;
  biometricEnabled: boolean;
}

const initialState: AuthState = {
  user: null,
  tokens: null,
  isAuthenticated: false,
  isLoading: false,
  error: null,
  isFirstLaunch: true,
  biometricEnabled: false,
};

// Async thunks
export const loginWithEmail = createAsyncThunk(
  'auth/loginWithEmail',
  async (credentials: LoginRequest, {rejectWithValue}) => {
    try {
      const response = await AuthService.loginWithEmail(credentials);
      
      // Store tokens securely
      if (response.tokens) {
        await KeychainService.setTokens(response.tokens);
      }
      
      return response;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Login failed');
    }
  }
);

export const registerWithEmail = createAsyncThunk(
  'auth/registerWithEmail',
  async (userData: RegisterRequest, {rejectWithValue}) => {
    try {
      const response = await AuthService.registerWithEmail(userData);
      
      // Store tokens securely
      if (response.tokens) {
        await KeychainService.setTokens(response.tokens);
      }
      
      return response;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Registration failed');
    }
  }
);

export const loginWithSocialProvider = createAsyncThunk(
  'auth/loginWithSocialProvider',
  async (provider: 'google' | 'facebook' | 'apple', {rejectWithValue}) => {
    try {
      const response = await AuthService.loginWithSocialProvider(provider);
      
      // Store tokens securely
      if (response.tokens) {
        await KeychainService.setTokens(response.tokens);
      }
      
      return response;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Social login failed');
    }
  }
);

export const refreshTokens = createAsyncThunk(
  'auth/refreshTokens',
  async (_, {getState, rejectWithValue}) => {
    try {
      const {auth} = getState() as {auth: AuthState};
      
      if (!auth.tokens?.refreshToken) {
        throw new Error('No refresh token available');
      }
      
      const response = await AuthService.refreshTokens(auth.tokens.refreshToken);
      
      // Update stored tokens
      await KeychainService.setTokens(response.tokens);
      
      return response;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Token refresh failed');
    }
  }
);

export const logout = createAsyncThunk(
  'auth/logout',
  async (_, {getState, rejectWithValue}) => {
    try {
      const {auth} = getState() as {auth: AuthState};
      
      // Call logout API if tokens exist
      if (auth.tokens?.accessToken) {
        await AuthService.logout(auth.tokens.accessToken);
      }
      
      // Clear stored tokens
      await KeychainService.clearTokens();
      
      return null;
    } catch (error: any) {
      // Even if logout API fails, clear local data
      await KeychainService.clearTokens();
      return null;
    }
  }
);

export const checkAuthState = createAsyncThunk(
  'auth/checkAuthState',
  async (_, {rejectWithValue}) => {
    try {
      // Check for stored tokens
      const tokens = await KeychainService.getTokens();
      
      if (!tokens) {
        return {user: null, tokens: null};
      }
      
      // Validate tokens and get user data
      const response = await AuthService.validateTokens(tokens);
      
      return response;
    } catch (error: any) {
      // Clear invalid tokens
      await KeychainService.clearTokens();
      return rejectWithValue(error.message || 'Auth check failed');
    }
  }
);

export const requestPasswordReset = createAsyncThunk(
  'auth/requestPasswordReset',
  async (email: string, {rejectWithValue}) => {
    try {
      await AuthService.requestPasswordReset(email);
      return null;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Password reset request failed');
    }
  }
);

export const verifyEmail = createAsyncThunk(
  'auth/verifyEmail',
  async (token: string, {rejectWithValue}) => {
    try {
      const response = await AuthService.verifyEmail(token);
      return response.user;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Email verification failed');
    }
  }
);

export const enableBiometric = createAsyncThunk(
  'auth/enableBiometric',
  async (_, {getState, rejectWithValue}) => {
    try {
      const {auth} = getState() as {auth: AuthState};
      
      if (!auth.tokens) {
        throw new Error('No authentication tokens available');
      }
      
      // Store tokens for biometric access
      await KeychainService.setBiometricTokens(auth.tokens);
      
      return true;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Failed to enable biometric authentication');
    }
  }
);

export const loginWithBiometric = createAsyncThunk(
  'auth/loginWithBiometric',
  async (_, {rejectWithValue}) => {
    try {
      const tokens = await KeychainService.getBiometricTokens();
      
      if (!tokens) {
        throw new Error('No biometric tokens available');
      }
      
      // Validate tokens and get user data
      const response = await AuthService.validateTokens(tokens);
      
      return response;
    } catch (error: any) {
      return rejectWithValue(error.message || 'Biometric login failed');
    }
  }
);

// Auth slice
const authSlice = createSlice({
  name: 'auth',
  initialState,
  reducers: {
    clearError: (state) => {
      state.error = null;
    },
    updateUser: (state, action: PayloadAction<Partial<User>>) => {
      if (state.user) {
        state.user = {...state.user, ...action.payload};
      }
    },
    setFirstLaunch: (state, action: PayloadAction<boolean>) => {
      state.isFirstLaunch = action.payload;
    },
    setBiometricEnabled: (state, action: PayloadAction<boolean>) => {
      state.biometricEnabled = action.payload;
    },
  },
  extraReducers: (builder) => {
    // Login with email
    builder
      .addCase(loginWithEmail.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(loginWithEmail.fulfilled, (state, action) => {
        state.isLoading = false;
        state.isAuthenticated = true;
        state.user = action.payload.user;
        state.tokens = action.payload.tokens;
        state.error = null;
      })
      .addCase(loginWithEmail.rejected, (state, action) => {
        state.isLoading = false;
        state.isAuthenticated = false;
        state.user = null;
        state.tokens = null;
        state.error = action.payload as string;
      });
    
    // Register with email
    builder
      .addCase(registerWithEmail.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(registerWithEmail.fulfilled, (state, action) => {
        state.isLoading = false;
        state.isAuthenticated = true;
        state.user = action.payload.user;
        state.tokens = action.payload.tokens;
        state.error = null;
      })
      .addCase(registerWithEmail.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });
    
    // Social login
    builder
      .addCase(loginWithSocialProvider.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(loginWithSocialProvider.fulfilled, (state, action) => {
        state.isLoading = false;
        state.isAuthenticated = true;
        state.user = action.payload.user;
        state.tokens = action.payload.tokens;
        state.error = null;
      })
      .addCase(loginWithSocialProvider.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });
    
    // Refresh tokens
    builder
      .addCase(refreshTokens.fulfilled, (state, action) => {
        state.tokens = action.payload.tokens;
        state.user = action.payload.user;
      })
      .addCase(refreshTokens.rejected, (state) => {
        state.isAuthenticated = false;
        state.user = null;
        state.tokens = null;
      });
    
    // Logout
    builder
      .addCase(logout.fulfilled, (state) => {
        state.isAuthenticated = false;
        state.user = null;
        state.tokens = null;
        state.error = null;
        state.biometricEnabled = false;
      });
    
    // Check auth state
    builder
      .addCase(checkAuthState.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(checkAuthState.fulfilled, (state, action) => {
        state.isLoading = false;
        if (action.payload.user && action.payload.tokens) {
          state.isAuthenticated = true;
          state.user = action.payload.user;
          state.tokens = action.payload.tokens;
        }
      })
      .addCase(checkAuthState.rejected, (state) => {
        state.isLoading = false;
        state.isAuthenticated = false;
        state.user = null;
        state.tokens = null;
      });
    
    // Password reset
    builder
      .addCase(requestPasswordReset.pending, (state) => {
        state.isLoading = true;
        state.error = null;
      })
      .addCase(requestPasswordReset.fulfilled, (state) => {
        state.isLoading = false;
      })
      .addCase(requestPasswordReset.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      });
    
    // Email verification
    builder
      .addCase(verifyEmail.fulfilled, (state, action) => {
        if (state.user) {
          state.user = action.payload;
        }
      });
    
    // Biometric authentication
    builder
      .addCase(enableBiometric.fulfilled, (state) => {
        state.biometricEnabled = true;
      })
      .addCase(loginWithBiometric.fulfilled, (state, action) => {
        state.isAuthenticated = true;
        state.user = action.payload.user;
        state.tokens = action.payload.tokens;
        state.error = null;
      })
      .addCase(loginWithBiometric.rejected, (state, action) => {
        state.error = action.payload as string;
      });
  },
});

export const {clearError, updateUser, setFirstLaunch, setBiometricEnabled} = authSlice.actions;
export default authSlice.reducer;

// Selectors
export const selectAuth = (state: {auth: AuthState}) => state.auth;
export const selectUser = (state: {auth: AuthState}) => state.auth.user;
export const selectIsAuthenticated = (state: {auth: AuthState}) => state.auth.isAuthenticated;
export const selectAuthLoading = (state: {auth: AuthState}) => state.auth.isLoading;
export const selectAuthError = (state: {auth: AuthState}) => state.auth.error;
export const selectIsFirstLaunch = (state: {auth: AuthState}) => state.auth.isFirstLaunch;
export const selectBiometricEnabled = (state: {auth: AuthState}) => state.auth.biometricEnabled;