import * as React from 'react';

import { StyleSheet, View, Button } from 'react-native';
import { start, stop } from 'react-native-esp-smartconfig';

export default function App() {
  const [sending, setSending] = React.useState(false);

  const handleClick = () => {
    setSending(true);
    start({
      bssid: '00:13:49:12:45:01',
      ssid: 'Alauddin',
      password: 'Password',
    })
      .then((result) => {
        console.log('response from smartConfig', result);
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
      {sending ? (
        <Button title="Cancel" onPress={handleCancel} />
      ) : (
        <Button title="Start" onPress={handleClick} />
      )}
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
