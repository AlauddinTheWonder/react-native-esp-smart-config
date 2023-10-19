# react-native-esp-smartconfig

ESP-TOUCH protocol to seamlessly configure Wi-Fi devices connecting to a router.

## Installation

```sh
npm install react-native-esp-smartconfig
```

## Congiguration

### Android

- Add following permissions into `android/src/main/AndroidManifest.xml`

```
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
```

## Usage

```javascript
import espSmartconfig from 'react-native-esp-smartconfig';

espSmartconfig
  .start({
    bssid: 'wifi-network-bssid',
    ssid: 'wifi-network-ssid',
    password: 'wifi-password',
  })
  .then(function (results) {
    // Array of devices, successfully handshaked by smartconfig
    console.log(results);
    /*[
    {
      'bssid': 'device-bssid', // device bssid
      'ipv4': '192.168.1.11'   // device local ip address
    }
  ]*/
  })
  .catch(function (error) {});

// to cancel on-going smartconfig process
espSmartconfig.stop();
```

## TODO

- [x] Android support
- [ ] iOS support
- [ ] Method to provide connected wifi's ssid and bssid

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Created by Alauddin Ansari (alauddinx27@gmail.com)
