# react-native-esp-smartconfig

ESP-TOUCH protocol to seamlessly configure Wi-Fi devices connecting to a router.

## Installation

```sh
npm install react-native-esp-smartconfig
```

## Usage

```javascript
import espSmartconfig from 'react-native-esp-smartconfig';

espSmartconfig
  .start({
    ssid: 'wifi-network-ssid',
    password: 'wifi-password',
  })
  .then(function (results) {
    //Array of device success do smartconfig
    console.log(results);
    /*[
    {
      'bssid': 'device-bssi1', //device bssid
      'ipv4': '192.168.1.11' //local ip address
    }
  ]*/
  })
  .catch(function (error) {});

espSmartconfig.stop(); //interrupt task
```

## TODO

- [ ] Android support
- [ ] iOS support

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
