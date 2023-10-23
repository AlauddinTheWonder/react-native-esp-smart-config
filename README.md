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
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
```

### iOS

- Add following entitlements into `ios/<project-name>/<project-name>.entitlements`

```
<key>com.apple.developer.networking.wifi-info</key><true/>
<key>com.apple.developer.networking.HotspotConfiguration</key><true>
```

- Add following capabilites into `ios/<project-name>/info.plist`

```
<key>NSLocalNetworkUsageDescription</key>
<string>The application needs to access the local network, allowing UDP to send broadcasts</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This application uses location permissions to obtain currently connected Wi-Fi information. This application does not collect, store or record any location data.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This application uses location permissions to obtain currently connected Wi-Fi information. This application does not collect, store or record any location data.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This application uses location permissions to obtain currently connected Wi-Fi information. This application does not collect, store or record any location data.</string>
```

- Add adding them, run `pod install` inside `ios` directory.

## Usage

- Available methods and interfaces

```typescript
interface SmartConfigResponse {
  bssid: string;
  ipv4: string;
}

interface WifiInfoState {
  bssid: string | null;
  ssid: string | null;
  ipv4: string;
  isConnected: boolean;
  isWifi: boolean;
  frequency: number | null; // android only
  type: string; // connection type name i.e wifi/cellular/none
}

function start({
  bssid: string;
  ssid: string;
  password: string;
}): Promise<SmartConfigResponse[]>;

function stop();

function getWifiInfo(): Promise<WifiInfoState>;
```

- Javascript example

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
- [x] iOS support
- [x] getWifiInfo - android
- [ ] getWifiInfo - ios

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Created by Alauddin Ansari (alauddinx27@gmail.com)
