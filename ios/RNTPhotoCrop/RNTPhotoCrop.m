
#import "RNTPhotoCrop.h"
#import <React/RCTConvert.h>
#import "react_native_pure_photo_crop-Swift.h"

@interface RNTPhotoCrop()<PhotoCropDelegate>

@end

@implementation RNTPhotoCrop

+ (void)init:(void (^)(NSString *, void (^ _Null_unspecified)(UIImage *)))value {
    PhotoCropViewController.loadImage = value;
}

- (void)photoCropDidCancel:(PhotoCropViewController *)photoCrop {
    [photoCrop dismissViewControllerAnimated:true completion:nil];
    self.reject(@"-1", @"cancel", nil);
}

- (void)photoCropDidExit:(PhotoCropViewController *)photoCrop {
    self.reject(@"-1", @"exit", nil);
}

- (void)photoCropDidSubmit:(PhotoCropViewController *)photoCrop cropFile:(CropFile *)cropFile {
    [photoCrop dismissViewControllerAnimated:true completion:nil];
    self.resolve(@{
                   @"path": cropFile.path,
                   @"size": @(cropFile.size),
                   @"width": @(cropFile.width),
                   @"height": @(cropFile.height)
                   });
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(RNTPhotoCrop);

RCT_EXPORT_METHOD(open:(NSDictionary*)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {

    self.resolve = resolve;
    self.reject = reject;

    PhotoCropViewController *controller = [PhotoCropViewController new];

    PhotoCropConfiguration *configuration = [PhotoCropConfiguration new];
    configuration.cropWidth = [RCTConvert int:options[@"width"]];
    configuration.cropHeight = [RCTConvert int:options[@"height"]];

    NSString *guideLabelTitle = [RCTConvert NSString:options[@"guideLabelTitle"]];
    if (guideLabelTitle != nil) {
        configuration.guideLabelTitle = guideLabelTitle;
    }
    NSString *cancelButtonTitle = [RCTConvert NSString:options[@"cancelButtonTitle"]];
    if (cancelButtonTitle != nil) {
        configuration.cancelButtonTitle = cancelButtonTitle;
    }
    NSString *resetButtonTitle = [RCTConvert NSString:options[@"resetButtonTitle"]];
    if (resetButtonTitle != nil) {
        configuration.resetButtonTitle = resetButtonTitle;
    }
    NSString *submitButtonTitle = [RCTConvert NSString:options[@"submitButtonTitle"]];
    if (submitButtonTitle != nil) {
        configuration.submitButtonTitle = submitButtonTitle;
    }

    controller.delegate = self;
    controller.configuration = configuration;

    [controller showWithUrl:[RCTConvert NSString:options[@"url"]]];

}

@end
