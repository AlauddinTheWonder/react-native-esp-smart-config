#import "EspSmartconfig.h"

@implementation EspSmartconfig
RCT_EXPORT_MODULE()

- (instancetype)init
{
    if (self = [super init]) {
        self._esptouchDelegate = [[EspTouchDelegateImpl alloc]init];
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
