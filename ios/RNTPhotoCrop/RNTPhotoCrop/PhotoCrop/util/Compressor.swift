
import UIKit

@objc public class Compressor: NSObject {
    
    private var maxWidth: CGFloat = 3000
    
    private var maxHeight: CGFloat = 3000
    
    // 最大 200KB
    private var maxSize: Int = 200 * 1024
    
    private var quality: CGFloat = 0.5
    
    @objc public init(maxWidth: CGFloat, maxHeight: CGFloat, maxSize: Int, quality: CGFloat) {
        
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
        self.maxSize = maxSize
        self.quality = quality
        
    }
    
    @objc public init(maxSize: Int, quality: CGFloat) {
        
        self.maxSize = maxSize
        self.quality = quality
        
    }
    
    // 尽可能的缩小文件大小
    @objc public func compress(source: CropFile) -> CropFile {
        
        if source.size < maxSize {
            return source
        }
        
        var width = source.width
        var height = source.height

        let ratio = height > 0 ? width / height : 1
        
        if width > maxWidth && height > maxHeight {
            // 看短边
            if width / maxWidth > height / maxHeight {
                height = maxHeight
                width = height * ratio
            }
            else {
                width = maxWidth
                height = width / ratio
            }
        }
        else if width > maxWidth && height <= maxHeight {
            width = maxWidth
            height = width / ratio
        }
        else if width <= maxWidth && height > maxHeight {
            height = maxHeight
            width = height * ratio
        }

        return compress(source: source, width: width, height: height)

    }
    
    // 指定输出尺寸
    @objc public func compress(source: CropFile, width: CGFloat, height: CGFloat) -> CropFile {
        
        guard source.width != width || source.height != height || source.size > maxSize else {
            return source
        }
        
        guard var image = UIImage(contentsOfFile: source.path) else {
            return source
        }
        
        image = Util.shared.createNewImage(image: image, size: CGSize(width: width, height: height), scale: 1)
        
        var result = Util.shared.createNewFile(image: image, quality: 1)
        if let file = result, file.size > maxSize {
            result = Util.shared.createNewFile(image: image, quality: quality)
        }
        
        return result ?? source
        
    }
    
}
