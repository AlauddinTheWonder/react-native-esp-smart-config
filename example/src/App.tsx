import * as React from 'react';
import {
  Alert,
  Button,
  PermissionsAndroid,
  Platform,
  StyleSheet,
  TextInput,
  View,
} from 'react-native';
import { start, stop } from 'react-native-esp-smartconfig';
import {
  refresh as refetchNetInfo,
  type NetInfoState,
  NetInfoStateType,
} from '@react-native-community/netinfo';

export default function App() {
  const [apSsid, setSsid] = React.useState('Alauddin');
  const [apBssid, setBssid] = React.useState('');
  const [apPass, setPass] = React.useState('');
  const [sending, setSending] = React.useState(false);

  React.useEffect(() => {
    const checkAndroidPerm = async () => {
      const already = await PermissionsAndroid.check(
        'android.permission.ACCESS_FINE_LOCATION'
      );
      if (!already) {
        const granted = await PermissionsAndroid.request(
          'android.permission.ACCESS_FINE_LOCATION'
        );
        if (granted === 'granted') {
          setTimeout(() => {
            refetchNetInfo().then(onFeedInfo);
          }, 500);
        } else {
          Alert.alert(
            'Permission denied!',
            'Location permission is needed to retrive current wifi SSID. Please grant the permission why going to Settings->App Info'
          );
        }
      }
    };

    if (Platform.OS === 'android') {
      checkAndroidPerm();
      refetchNetInfo().then(onFeedInfo);
    } else {
      setTimeout(() => {
        refetchNetInfo().then(onFeedInfo);
      }, 2000);
    }
  }, []);

  const onFeedInfo = (netState: NetInfoState) => {
    console.log('netState', netState);
    if (netState.type === NetInfoStateType.wifi && netState.isConnected) {
      const { bssid, ssid } = netState.details;
      if (ssid) {
        setSsid(ssid);
      }
      if (bssid) {
        setBssid(bssid);
      }
    }
  };

  const handleClick = () => {
    setSending(true);
    start({
      bssid: apBssid,
      ssid: apSsid,
      password: apPass,
    })
      .then((result) => {
        console.log('response from smartConfig: ', result);
      })
      .catch((error) => {
        console.log('No response from any device', error);
      })
      .finally(() => setSending(false));
  };

  const handleCancel = () => {
    stop();
    setSending(false);
  };

  return (
    <View style={styles.container}>
      <View>
        <TextInput
          value={apBssid}
          placeholder="BSSID"
          onChangeText={setBssid}
        />
        <TextInput value={apSsid} placeholder="SSID" onChangeText={setSsid} />
        <TextInput
          value={apPass}
          placeholder="Password"
          onChangeText={setPass}
        />
      </View>
      <View>
        {sending ? (
          <Button title="Cancel" onPress={handleCancel} />
        ) : (
          <Button title="Start" onPress={handleClick} />
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
