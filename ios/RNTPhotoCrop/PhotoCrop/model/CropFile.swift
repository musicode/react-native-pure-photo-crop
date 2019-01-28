
import UIKit

@objc public class CropFile: NSObject {
    
    @objc public let path: String
    @objc public let size: Int
    @objc public let width: CGFloat
    @objc public let height: CGFloat
    
    @objc public init(path: String, size: Int, width: CGFloat, height: CGFloat) {
        self.path = path
        self.size = size
        self.width = width
        self.height = height
    }
    
}
