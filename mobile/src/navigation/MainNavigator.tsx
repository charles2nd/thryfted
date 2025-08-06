import React from 'react';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {createStackNavigator} from '@react-navigation/stack';
import {View, StyleSheet} from 'react-native';
import Icon from 'react-native-vector-icons/Feather';
import {useSafeAreaInsets} from 'react-native-safe-area-context';

// Import screens (placeholder components for now)
import HomeScreen from '@screens/home/HomeScreen';
import SearchScreen from '@screens/search/SearchScreen';
import SellScreen from '@screens/listing/SellScreen';
import MessagesScreen from '@screens/messaging/MessagesScreen';
import ProfileScreen from '@screens/profile/ProfileScreen';

// Stack navigators for each tab
const HomeStack = createStackNavigator();
const SearchStack = createStackNavigator();
const SellStack = createStackNavigator();
const MessagesStack = createStackNavigator();
const ProfileStack = createStackNavigator();

// Individual stack components
const HomeStackScreen = () => (
  <HomeStack.Navigator screenOptions={{headerShown: false}}>
    <HomeStack.Screen name="HomeMain" component={HomeScreen} />
  </HomeStack.Navigator>
);

const SearchStackScreen = () => (
  <SearchStack.Navigator screenOptions={{headerShown: false}}>
    <SearchStack.Screen name="SearchMain" component={SearchScreen} />
  </SearchStack.Navigator>
);

const SellStackScreen = () => (
  <SellStack.Navigator screenOptions={{headerShown: false}}>
    <SellStack.Screen name="SellMain" component={SellScreen} />
  </SellStack.Navigator>
);

const MessagesStackScreen = () => (
  <MessagesStack.Navigator screenOptions={{headerShown: false}}>
    <MessagesStack.Screen name="MessagesMain" component={MessagesScreen} />
  </MessagesStack.Navigator>
);

const ProfileStackScreen = () => (
  <ProfileStack.Navigator screenOptions={{headerShown: false}}>
    <ProfileStack.Screen name="ProfileMain" component={ProfileScreen} />
  </ProfileStack.Navigator>
);

// Bottom Tab Navigator
const Tab = createBottomTabNavigator();

const MainNavigator: React.FC = () => {
  const insets = useSafeAreaInsets();

  return (
    <Tab.Navigator
      screenOptions={({route}) => ({
        headerShown: false,
        tabBarIcon: ({focused, color, size}) => {
          let iconName: string;

          switch (route.name) {
            case 'Home':
              iconName = 'home';
              break;
            case 'Search':
              iconName = 'search';
              break;
            case 'Sell':
              iconName = 'plus-circle';
              break;
            case 'Messages':
              iconName = 'message-circle';
              break;
            case 'Profile':
              iconName = 'user';
              break;
            default:
              iconName = 'circle';
          }

          return (
            <View style={[styles.tabIcon, focused && styles.tabIconFocused]}>
              <Icon 
                name={iconName} 
                size={size} 
                color={focused ? '#000000' : '#8E8E93'} 
              />
            </View>
          );
        },
        tabBarActiveTintColor: '#000000',
        tabBarInactiveTintColor: '#8E8E93',
        tabBarStyle: [
          styles.tabBar,
          {
            paddingBottom: insets.bottom > 0 ? insets.bottom : 10,
            height: 60 + (insets.bottom > 0 ? insets.bottom : 10),
          },
        ],
        tabBarLabelStyle: styles.tabLabel,
        tabBarShowLabel: true,
      })}
    >
      <Tab.Screen
        name="Home"
        component={HomeStackScreen}
        options={{
          title: 'Home',
          tabBarTestID: 'HomeTab',
        }}
      />
      <Tab.Screen
        name="Search"
        component={SearchStackScreen}
        options={{
          title: 'Search',
          tabBarTestID: 'SearchTab',
        }}
      />
      <Tab.Screen
        name="Sell"
        component={SellStackScreen}
        options={{
          title: 'Sell',
          tabBarTestID: 'SellTab',
        }}
      />
      <Tab.Screen
        name="Messages"
        component={MessagesStackScreen}
        options={{
          title: 'Messages',
          tabBarTestID: 'MessagesTab',
        }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileStackScreen}
        options={{
          title: 'You',
          tabBarTestID: 'ProfileTab',
        }}
      />
    </Tab.Navigator>
  );
};

const styles = StyleSheet.create({
  tabBar: {
    backgroundColor: '#FFFFFF',
    borderTopWidth: 1,
    borderTopColor: '#E1E1E1',
    elevation: 8,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: -2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3,
  },
  tabIcon: {
    alignItems: 'center',
    justifyContent: 'center',
    width: 28,
    height: 28,
  },
  tabIconFocused: {
    transform: [{scale: 1.1}],
  },
  tabLabel: {
    fontSize: 10,
    fontWeight: '500',
    marginTop: 2,
  },
});

export default MainNavigator;