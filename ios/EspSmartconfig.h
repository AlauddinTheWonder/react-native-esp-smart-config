
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNEspSmartconfigSpec.h"

@interface EspSmartconfig : NSObject <NativeEspSmartconfigSpec>
#else
#import <React/RCTBridgeModule.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>

#import "esptouch/ESPTouchDelegate.h"
#import "esptouch/ESPTouchResult.h"
#import "esptouch/ESPTouchTask.h"

// EspTouchDelegateImpl interface start
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
// EspTouchDelegateImpl interface end

@interface EspSmartconfig : NSObject <RCTBridgeModule>

// to cancel ESPTouchTask when
@property (atomic, strong) ESPTouchTask *_esptouchTask;

@property (nonatomic, strong) EspTouchDelegateImpl *_esptouchDelegate;

// without the condition, if the user tap confirm/cancel quickly enough,
// the bug will arise. the reason is follows:
// 0. task is starting created, but not finished
// 1. the task is cancel for the task hasn't been created, it do nothing
// 2. task is created
// 3. Oops, the task should be cancelled, but it is running
@property (nonatomic, strong) NSCondition *_condition;

#endif

@end
