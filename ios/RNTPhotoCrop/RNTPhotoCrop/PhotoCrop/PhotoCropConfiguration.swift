
import UIKit

@objc public class PhotoCropConfiguration: NSObject {
    
    @objc public var backgroundColor = UIColor.black
    
    @objc public var finderBorderWidth: CGFloat = 1
    @objc public var finderBorderColor = UIColor.white
    
    @objc public var finderCornerLineWidth: CGFloat = 3
    @objc public var finderCornerLineSize: CGFloat = 22
    @objc public var finderCornerLineColor = UIColor.white
    
    @objc public var finderCornerButtonSize: CGFloat = 60
    
    @objc public var finderMinWidth: CGFloat = 60
    @objc public var finderMinHeight: CGFloat = 60
    
    @objc public var finderMaxWidth: CGFloat = 0
    @objc public var finderMaxHeight: CGFloat = 0
    
    @objc public var gridLineColor = UIColor.white
    @objc public var gridLineWidth = 1 / UIScreen.main.scale
    
    @objc public var overlayBlurAlpha: CGFloat = 1
    @objc public var overlayAlphaNormal: CGFloat = 1
    @objc public var overlayAlphaInteractive: CGFloat = 0.2
    
    // 裁剪宽度
    @objc public var cropWidth: CGFloat = 0
    
    // 裁剪高度
    @objc public var cropHeight: CGFloat = 0
    
    // 裁剪后图片的最大尺寸
    @objc public var maxSize = 200 * 1024
    
    // 裁剪后图片如果大于 maxSize，压缩图片的质量
    @objc public var quality: CGFloat = 0.5

    public override init() {
        
    }
    
}
