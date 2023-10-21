package com.alan.espsmartconfig;

import android.annotation.SuppressLint;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.AsyncTask;
import android.util.Log;

import androidx.annotation.NonNull;

import com.espressif.iot.esptouch.EsptouchTask;
import com.espressif.iot.esptouch.IEsptouchResult;
import com.espressif.iot.esptouch.IEsptouchTask;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;

import java.util.List;
import java.util.Objects;

@ReactModule(name = EspSmartconfigModule.NAME)
public class EspSmartconfigModule extends ReactContextBaseJavaModule {
  public static final String NAME = "EspSmartconfig";
  private IEsptouchTask esptouchTask;

  public EspSmartconfigModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  @NonNull
  public String getName() {
    return NAME;
  }

  @ReactMethod
  public void stop() {
    if (esptouchTask != null) {
      Log.d(NAME, "Cancel task");
      esptouchTask.interrupt();
    }
  }

  @ReactMethod
  public void getWifiInfo(final Promise promise) {
    Context context = Objects.requireNonNull(getCurrentActivity()).getApplicationContext();

    ConnectivityManager connectivityManager = (ConnectivityManager) context.getSystemService(Context.CONNECTIVITY_SERVICE);
    NetworkInfo networkInfo = connectivityManager.getActiveNetworkInfo();

    if (networkInfo == null) {
      promise.reject("NETWORK_NOT_AVAILABLE");
      return;
    }

    boolean isWifi = networkInfo.getType() == ConnectivityManager.TYPE_WIFI;

    WifiManager wifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
    WifiInfo info = wifiManager.getConnectionInfo();

    if (info == null) {
      promise.reject("WIFI_NOT_AVAILABLE");
      return;
    }

    int ipAddress = info.getIpAddress();

    @SuppressLint("DefaultLocale") String ip = String.format(
      "%d.%d.%d.%d",
      (ipAddress & 0xFF),
      (ipAddress >> 8 & 0xFF),
      (ipAddress >> 16 & 0xFF),
      (ipAddress >> 24 & 0xFF)
    );

    WritableMap map = Arguments.createMap();
    map.putString("bssid", info.getBSSID());
    map.putString("ssid", info.getSSID().replaceAll("\"", ""));
    map.putString("type", networkInfo.getTypeName());
    map.putInt("frequency", info.getFrequency());
    map.putString("ipv4", ip);
    map.putBoolean("isConnected", networkInfo.isConnected());
    map.putBoolean("isWifi", isWifi);

    promise.resolve(map);
  }

  @ReactMethod
  public void start(final ReadableMap options, final Promise promise) {
    String ssid = options.getString("ssid");
    String bssid = options.getString("bssid");
    String pass = options.getString("password");
    String resultCount = "1";

    Log.d(NAME, "ssid: " + ssid + ", bssid: " + bssid + ", pass: " + pass);

    // stop before starting new task
    stop();

    new EsptouchAsyncTask(new TaskListener() {
      @Override
      public void onFinished(List<IEsptouchResult> result) {
        WritableArray ret = Arguments.createArray();

        boolean resolved = false;

        for (IEsptouchResult resultInList : result) {
          if (!resultInList.isCancelled() &&resultInList.getBssid() != null) {
            WritableMap map = Arguments.createMap();
            map.putString("bssid", resultInList.getBssid());
            map.putString("ipv4", resultInList.getInetAddress().getHostAddress());
            ret.pushMap(map);
            resolved = true;

            if (!resultInList.isSuc())
              break;
          }
        }

        if (resolved) {
          Log.d(NAME, "Successfully run smartConfig");
          promise.resolve(ret);
        } else {
          Log.d(NAME, "Error while running smartConfig");
          promise.reject("new IllegalViewOperationException()");
        }
      }
    }).execute(ssid, bssid, pass, resultCount);
  }

  public interface TaskListener {
    public void onFinished(List<IEsptouchResult> result);
  }

  private class EsptouchAsyncTask extends AsyncTask<String, Void, List<IEsptouchResult>> {
    private final TaskListener taskListener;

    public EsptouchAsyncTask(TaskListener listener) {
      this.taskListener = listener;
    }

    private final Object mLock = new Object();

    @Override
    protected void onPreExecute() {
      Log.d(NAME, "Begin task");
    }
    @Override
    protected List<IEsptouchResult> doInBackground(String... params) {
      Log.d(NAME, "Doing task");

      int taskResultCount = -1;

      synchronized (mLock) {
        String apSsid = params[0];
        String apBssid =  params[1];
        String apPassword = params[2];
        String taskResultCountStr = params[3];

        taskResultCount = Integer.parseInt(taskResultCountStr);

        esptouchTask = new EsptouchTask(apSsid, apBssid, apPassword, getCurrentActivity());
      }
      return esptouchTask.executeForResults(taskResultCount);
    }

    @Override
    protected void onPostExecute(List<IEsptouchResult> result) {

      IEsptouchResult firstResult = result.get(0);
      if (!firstResult.isCancelled()) {
        if(this.taskListener != null) {
          this.taskListener.onFinished(result);
        }
      }
    }
  }
}
