import React, {useEffect} from 'react';
import {StatusBar, LogBox} from 'react-native';
import {GestureHandlerRootView} from 'react-native-gesture-handler';
import {SafeAreaProvider} from 'react-native-safe-area-context';
import {Provider} from 'react-redux';
import {PersistGate} from 'redux-persist/integration/react';
import Toast from 'react-native-toast-message';

import {store, persistor} from '@store';
import Navigation from '@navigation';
import LoadingScreen from '@components/common/LoadingScreen';
import {initializeApp} from '@services/app';
import {toastConfig} from '@config/toast';

// Ignore specific warnings in development
if (__DEV__) {
  LogBox.ignoreLogs([
    'Remote debugger',
    'Sending...',
    'Non-serializable values were found in the navigation state',
  ]);
}

const App: React.FC = () => {
  useEffect(() => {
    // Initialize app services
    initializeApp();
  }, []);

  return (
    <GestureHandlerRootView style={{flex: 1}}>
      <SafeAreaProvider>
        <Provider store={store}>
          <PersistGate loading={<LoadingScreen />} persistor={persistor}>
            <StatusBar
              barStyle="dark-content"
              backgroundColor="transparent"
              translucent
            />
            <Navigation />
            <Toast config={toastConfig} />
          </PersistGate>
        </Provider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
};

export default App;