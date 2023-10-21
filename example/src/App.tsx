import * as React from 'react';
import {
  Alert,
  Button,
  PermissionsAndroid,
  Platform,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import {
  getWifiInfo,
  start,
  stop,
  type WifiInfoState,
} from 'react-native-esp-smartconfig';
// import {
//   refresh as refetchNetInfo,
//   type NetInfoState,
//   NetInfoStateType,
// } from '@react-native-community/netinfo';

const ACCESS_FINE_LOCATION = 'android.permission.ACCESS_FINE_LOCATION';

const checkAndroidPerm = async (callback: () => void) => {
  const already = await PermissionsAndroid.check(ACCESS_FINE_LOCATION);
  if (already) {
    callback();
  } else {
    const granted = await PermissionsAndroid.request(ACCESS_FINE_LOCATION);
    if (granted === 'granted') {
      setTimeout(() => {
        callback();
      }, 500);
    } else {
      Alert.alert(
        'Permission denied!',
        'Location permission is needed to retrive current wifi SSID.\nPlease grant the permission by going to Settings->App Info and restart the application.'
      );
    }
  }
};

export default function App() {
  const [apSsid, setSsid] = React.useState('');
  const [apBssid, setBssid] = React.useState('');
  const [apPass, setPass] = React.useState('');
  const [sending, setSending] = React.useState(false);

  const [wifiState, setWifiState] = React.useState<WifiInfoState>();

  React.useEffect(() => {
    if (Platform.OS === 'android') {
      checkAndroidPerm(() => {
        getWifiInfo()
          .then(feedWifiInfo)
          .catch((error) => {
            Alert.alert('Error', error?.message);
          });
      });
    } else if (Platform.OS === 'ios') {
      // refetchNetInfo().then(feedNetInfoWifi);
      getWifiInfo()
        .then(feedWifiInfo)
        .catch((error) => {
          Alert.alert('Error', error?.message);
        });
    }
  }, []);

  const feedWifiInfo = (state: WifiInfoState) => {
    console.log('wifi info', state);
    setWifiState(state);
    if (state && state.isConnected && state.isWifi) {
      setSsid(state.ssid || '');
      setBssid(state.bssid || '');
    }
  };

  // const feedNetInfoWifi = (netState: NetInfoState) => {
  //   if (netState.type === NetInfoStateType.wifi && netState.isConnected) {
  //     const { bssid, ssid } = netState.details;
  //     if (ssid) {
  //       setSsid(ssid);
  //     }
  //     if (bssid) {
  //       setBssid(bssid);
  //     }
  //   }
  // };

  const handleStart = () => {
    setSending(true);
    start({
      bssid: apBssid,
      ssid: apSsid,
      password: apPass,
    })
      .then((result) => {
        console.log('response from smartConfig: ', result);
        if (result && result.length > 0) {
          const firstDevice = result[0];
          Alert.alert(
            'Found',
            `Handshaked with device- bssid: ${firstDevice?.bssid}, ip: ${firstDevice?.ipv4}`
          );
        }
      })
      .catch((error) => {
        console.log('No response from any device', error);
        Alert.alert('Error', 'No device responded');
      })
      .finally(() => setSending(false));
  };

  const handleCancel = () => {
    stop();
    setSending(false);
  };

  return (
    <View style={styles.container}>
      <View style={styles.form}>
        <TextInput
          style={styles.input}
          value={apBssid}
          placeholder="BSSID"
          onChangeText={setBssid}
        />
        <TextInput
          style={styles.input}
          value={apSsid}
          placeholder="SSID"
          onChangeText={setSsid}
        />
        <TextInput
          style={styles.input}
          value={apPass}
          placeholder="Password"
          onChangeText={setPass}
        />
        <View style={styles.button}>
          {sending ? (
            <Button title="Cancel" onPress={handleCancel} />
          ) : (
            <Button title="Start" onPress={handleStart} />
          )}
        </View>
        <Text>{wifiState && JSON.stringify(wifiState)}</Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#ffffff',
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    width: '100%',
  },
  form: {
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    rowGap: 16,
    width: '100%',
    paddingHorizontal: 24,
  },
  input: {
    borderWidth: 1,
    borderRadius: 4,
    borderColor: '#cccccc',
    paddingHorizontal: 16,
    width: '80%',
  },
  button: {
    width: 150,
  },
});
