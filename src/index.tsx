import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-esp-smartconfig' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const EspSmartconfig = NativeModules.EspSmartconfig
  ? NativeModules.EspSmartconfig
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

interface IStartProps {
  bssid: string;
  ssid: string;
  password: string;
}

interface ISmartConfigResponse {
  bssid: string;
  ipv4: string;
}

export function start(args: IStartProps): Promise<ISmartConfigResponse[]> {
  return EspSmartconfig.start(args);
}

export function stop() {
  return EspSmartconfig.stop();
}
