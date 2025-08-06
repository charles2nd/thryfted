import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {useSelector} from 'react-redux';

import {selectIsAuthenticated, selectIsFirstLaunch} from '@store/slices/authSlice';
import {selectIsOnboardingComplete} from '@store/slices/appSlice';
import OnboardingNavigator from './OnboardingNavigator';
import AuthNavigator from './AuthNavigator';
import MainNavigator from './MainNavigator';
import LoadingScreen from '@components/common/LoadingScreen';

const Navigation: React.FC = () => {
  const isAuthenticated = useSelector(selectIsAuthenticated);
  const isFirstLaunch = useSelector(selectIsFirstLaunch);
  const isOnboardingComplete = useSelector(selectIsOnboardingComplete);

  // Show onboarding on first launch
  if (isFirstLaunch && !isOnboardingComplete) {
    return (
      <NavigationContainer>
        <OnboardingNavigator />
      </NavigationContainer>
    );
  }

  // Show auth flow if not authenticated
  if (!isAuthenticated) {
    return (
      <NavigationContainer>
        <AuthNavigator />
      </NavigationContainer>
    );
  }

  // Show main app if authenticated
  return (
    <NavigationContainer>
      <MainNavigator />
    </NavigationContainer>
  );
};

export default Navigation;