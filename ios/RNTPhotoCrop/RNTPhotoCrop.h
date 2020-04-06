#import <React/RCTBridgeModule.h>

@interface RNTPhotoCrop : NSObject <RCTBridgeModule>

+ (void)init:(void (^ _Null_unspecified)(NSString*, void (^ _Null_unspecified)(UIImage*)))value;

@property (nonatomic, strong) RCTPromiseResolveBlock resolve;
@property (nonatomic, strong) RCTPromiseRejectBlock reject;

@end
