#import "EspSmartconfig.h"

@implementation EspSmartconfig
RCT_EXPORT_MODULE()

- (instancetype)init
{
    if (self = [super init]) {
        self._esptouchDelegate = [[EspTouchDelegateImpl alloc]init];
        
        if (@available(iOS 13, *)) {
            self._locationManagerDelegate = [[LocationManagerDelegateImpl alloc]init];
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self._locationManagerDelegate;
        }
    }
    return self;
}


RCT_EXPORT_METHOD(stop) {
    [self cancel];
}

RCT_EXPORT_METHOD(start:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *apSsid = [options valueForKey:@"ssid"];
    NSString *apBssid = [options valueForKey:@"bssid"];
    NSString *apPwd = [options valueForKey:@"password"];
    int taskCount = 1;
    BOOL broadcast = YES;
    
    dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSLog(@"ESPViewController do the execute work...");
        
        NSArray *esptouchResultArray = [self executeForResultsWithSsid:apSsid bssid:apBssid password:apPwd taskCount:taskCount broadcast:broadcast];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            BOOL resolved = false;
            NSMutableArray *ret = [[NSMutableArray alloc]init];
            
            for (int i = 0; i < [esptouchResultArray count]; ++i)
            {
                ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                
                if (![resultInArray isCancelled] && [resultInArray bssid] != nil) {
                    
                    unsigned char *ipBytes = (unsigned char *)[[resultInArray ipAddrData] bytes];
                    
                    NSString *ipv4String = [NSString stringWithFormat:@"%d.%d.%d.%d", ipBytes[0], ipBytes[1], ipBytes [2], ipBytes [3]];
                    
                    NSDictionary *respData = @{@"bssid": [resultInArray bssid], @"ipv4": ipv4String};
                    
                    [ret addObject: respData];
                    resolved = true;
                    if (![resultInArray isSuc])
                        break;
                }
            }
            if(resolved)
                resolve(ret);
            else
                reject(RCTErrorUnspecified, nil, RCTErrorWithMessage(@"Timoutout or not Found"));
            
        });
    });
}

RCT_EXPORT_METHOD(getWifiInfo:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    BOOL hasLocationPermission = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
                                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways;

    if (@available(iOS 13, *) && hasLocationPermission == NO) {
        [self.locationManager requestWhenInUseAuthorization];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"RNWIFI:authorizationStatus" object:nil queue:nil usingBlock:^(NSNotification *note)
        {
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
                [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways){
                resolve([self getWifiInfo]);
                return;
            } else{
                reject(RCTErrorUnspecified, nil, RCTErrorWithMessage(@"Permission not granted"));
                return;
            }
        }];
    } else {
        resolve([self getWifiInfo]);
    }
}


#pragma mark - the example of how to get wifi information

- (NSDictionary *) getWifiInfo
{
    __block NSString *ssid = @"";
    __block NSString *bssid = @"";

    if (@available(iOS 14.0, *)) {
//        [NEHotspotNetwork fetchCurrentWithCompletionHandler:^(NEHotspotNetwork * _Nullable currentNetwork) {
//            ssid = [currentNetwork SSID];
//            bssid = [currentNetwork BSSID];
//        }];
        
        // dummy response until "NetworkExtension not found for arm64" fixed
        bssid = @"INCOMPATIBLE";
    } else {
        NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
        for (NSString *ifnam in ifs) {
            NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
            if (info) {
                ssid = [info valueForKey:@"SSID"];
                bssid = [info valueForKey:@"BSSID"];
            }
        }
    }
    return @{@"bssid": bssid, @"ssid": ssid, @"ipv4": @"", @"isConnected": @true, @"isWifi": @true, @"frequency": @"null", @"type": @""};
}


#pragma mark - the example of how to cancel the executing task

- (void) cancel
{
    [self._condition lock];
    if (self._esptouchTask != nil)
    {
        [self._esptouchTask interrupt];
    }
    [self._condition unlock];
}


#pragma mark - the example of how to use executeForResults
- (NSArray *) executeForResultsWithSsid:(NSString *)apSsid bssid:(NSString *)apBssid password:(NSString *)apPwd taskCount:(int)taskCount broadcast:(BOOL)broadcast
{
    [self cancel];
    [self._condition lock];
    
    RCTLogInfo(@"ssid %@ bssid %@ pass %@", apSsid, apBssid, apPwd);

    self._esptouchTask = [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd];
    // set delegate
    [self._esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    [self._esptouchTask setPackageBroadcast:broadcast];
    [self._condition unlock];
//    ESPTouchResult *ESPTR = self._esptouchTask.executeForResult;
    NSArray * esptouchResults = [self._esptouchTask executeForResults:taskCount];
    NSLog(@"ESPViewController executeForResult() result is: %@",esptouchResults);
    return esptouchResults;
}


@end
