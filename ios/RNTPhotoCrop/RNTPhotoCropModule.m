
#import "RNTPhotoCropModule.h"
#import "RNTPhotoCrop-Swift.h"

@interface RNTPhotoCropModule()<PhotoCropDelegate>

@end

@implementation RNTPhotoCropModule

+ (void)setImageLoader:(void (^)(NSString *, void (^ _Null_unspecified)(UIImage *)))value {
    PhotoCropViewController.loadImage = value;
}

- (void)photoCropDidCancel:(PhotoCropViewController *)photoCrop {
    [photoCrop dismissViewControllerAnimated:true completion:nil];
    self.reject(@"-1", @"cancel", nil);
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
    
    controller.delegate = self;
    controller.configuration = configuration;

    [controller showWithUrl:[RCTConvert NSString:options[@"url"]]];
    
}

RCT_EXPORT_METHOD(compress:(NSDictionary*)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    NSString *path = [RCTConvert NSString:options[@"path"]];
    int size = [RCTConvert int:options[@"size"]];
    int width = [RCTConvert int:options[@"width"]];
    int height = [RCTConvert int:options[@"height"]];
    int maxSize = [RCTConvert int:options[@"maxSize"]];
    int maxWidth = [RCTConvert int:options[@"maxWidth"]];
    int maxHeight = [RCTConvert int:options[@"maxHeight"]];
    float quality = [RCTConvert float:options[@"quality"]];
    
    CropFile *source = [[CropFile alloc] initWithPath:path size:size width:width height:height];

    Compressor *compressor = [[Compressor alloc] initWithMaxWidth:maxWidth maxHeight:maxHeight maxSize:maxSize quality:quality];
    CropFile *result = [compressor compressWithSource:source];
    
    resolve(@{
              @"path": result.path,
              @"size": @(result.size),
              @"width": @(result.width),
              @"height": @(result.height)
             });
    
}

@end
