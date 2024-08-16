
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
    
    @objc public var gridLineColor = UIColor.white.withAlphaComponent(0.6)
    @objc public var gridLineWidth = 1 / UIScreen.main.scale
    
    @objc public var overlayBlurAlpha: CGFloat = 1
    @objc public var overlayAlphaNormal: CGFloat = 1
    @objc public var overlayAlphaInteractive: CGFloat = 0.2
    
    @objc public var guideLabelTextFont = UIFont.systemFont(ofSize: 14)
    @objc public var guideLabelTextColor = UIColor.white
    
    @objc public var guideLabelMarginTop: CGFloat = 20
    @objc public var separatorLineWidth = 1 / UIScreen.main.scale
    @objc public var separatorLineColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
    @objc public var separatorLineSpacingTop: CGFloat = 10
    @objc public var separatorLineSpacingBottom: CGFloat = 5
    @objc public var separatorLineMarginBottom: CGFloat = 60
    
    @objc public var cancelButtonMarginLeft: CGFloat = 20
    @objc public var submitButtonMarginRight: CGFloat = 20
    @objc public var rotateButtonMarginLeft: CGFloat = 20
    @objc public var rotateButtonImage = UIImage(named: "photo_crop_rotate")
    
    @objc public var guideLabelTitle = ""
    @objc public var cancelButtonTitle = "取消"
    @objc public var resetButtonTitle = "重置"
    @objc public var submitButtonTitle = "确定"
    
    @objc public var buttonTextFont = UIFont.systemFont(ofSize: 15)
    @objc public var buttonTextColor = UIColor.white
    @objc public var buttonWidth: CGFloat = 44
    @objc public var buttonHeight: CGFloat = 44
    
    
    
    
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
