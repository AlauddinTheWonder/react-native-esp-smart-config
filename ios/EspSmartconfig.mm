#import "EspSmartconfig.h"

@implementation EspSmartconfig
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(stop) {
    [self cancel];
}

RCT_EXPORT_METHOD(start:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    resolve(@"Hello from EspSmartconfig iOS");
}


- (void) cancel
{
    RCTLogInfo(@"Cancel last task before begin new task");
}



@end
