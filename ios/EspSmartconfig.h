
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNEspSmartconfigSpec.h"

@interface EspSmartconfig : NSObject <NativeEspSmartconfigSpec>
#else
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>

//#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreLocation/CoreLocation.h>

#import "esptouch/ESPTouchDelegate.h"
#import "esptouch/ESPTouchResult.h"
#import "esptouch/ESPTouchTask.h"

// EspTouch Delegate interface start
@interface EspTouchDelegateImpl : NSObject<ESPTouchDelegate>

@end

@implementation EspTouchDelegateImpl

-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    NSLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self showAlertWithResult:result];
    });
}

@end
// EspTouch Delegate interface end

// LocationManager deligate start
@interface LocationManagerDelegateImpl : NSObject<CLLocationManagerDelegate>

@end

@implementation LocationManagerDelegateImpl

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"RNWIFI:statechaged %d", status);
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"RNWIFI:authorizationStatus" object:nil userInfo:nil];
}

@end
// LocationManager deligate end

@interface EspSmartconfig : NSObject <RCTBridgeModule>

@property (atomic, strong) ESPTouchTask *_esptouchTask;
@property (nonatomic, strong) EspTouchDelegateImpl *_esptouchDelegate;
@property (nonatomic, strong) NSCondition *_condition;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (nonatomic, strong) LocationManagerDelegateImpl *_locationManagerDelegate;

#endif

@end
