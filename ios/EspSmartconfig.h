
#ifdef RCT_NEW_ARCH_ENABLED
#import "RNEspSmartconfigSpec.h"

@interface EspSmartconfig : NSObject <NativeEspSmartconfigSpec>
#else
#import <React/RCTBridgeModule.h>

@interface EspSmartconfig : NSObject <RCTBridgeModule>
#endif

@end
