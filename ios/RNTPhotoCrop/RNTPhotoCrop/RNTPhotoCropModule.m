
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
                   @"size": [NSNumber numberWithInteger:cropFile.size],
                   @"width": [NSNumber numberWithInteger:cropFile.width],
                   @"height": [NSNumber numberWithInteger:cropFile.height]
                   });
}

RCT_EXPORT_MODULE(RNTPhotoCrop);

RCT_EXPORT_METHOD(open:(NSString *)url
                  width:(int)width
                  height:(int)height
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    self.resolve = resolve;
    self.reject = reject;
    
    PhotoCropViewController *controller = [PhotoCropViewController new];
    
    PhotoCropConfiguration *configuration = [PhotoCropConfiguration new];
    configuration.cropWidth = width;
    configuration.cropHeight = height;
    
    controller.delegate = self;
    controller.configuration = configuration;

    [controller showWithUrl:url];
    
}

RCT_EXPORT_METHOD(compress:(NSString *)path
                  size:(int)size
                  width:(int)width
                  height:(int)height
                  maxSize:(int)maxSize
                  maxWidth:(int)maxWidth
                  maxHeight:(int)maxHeight
                  quality:(float)quality
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
    
    CropFile *source = [[CropFile alloc] initWithPath:path size:size width:width height:height];

    Compressor *compressor = [[Compressor alloc] initWithMaxWidth:maxWidth maxHeight:maxHeight maxSize:maxSize quality:quality];
    CropFile *result = [compressor compressWithSource:source];
    
    resolve(@{
              @"path": result.path,
              @"size": [NSNumber numberWithInteger:result.size],
              @"width": [NSNumber numberWithInteger:result.width],
              @"height": [NSNumber numberWithInteger:result.height]
             });
    
}

@end
