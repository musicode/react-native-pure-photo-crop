
#import <React/RCTViewManager.h>
#import <React/RCTBridgeModule.h>

@interface RNTPhotoCropModule : NSObject <RCTBridgeModule>

+ (void)setImageLoader:(void (^ _Null_unspecified)(NSString*, void (^ _Null_unspecified)(UIImage*)))value;

@property (nonatomic, strong) RCTPromiseResolveBlock resolve;
@property (nonatomic, strong) RCTPromiseRejectBlock reject;

@end
