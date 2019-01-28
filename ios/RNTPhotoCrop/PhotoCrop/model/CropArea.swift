
import UIKit

class CropArea {
    
    static let zero = CropArea(top: 0, left: 0, bottom: 0, right: 0)
    
    let top: CGFloat
    let left: CGFloat
    let bottom: CGFloat
    let right: CGFloat
    
    init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
    
    func toRect(width: CGFloat, height: CGFloat) -> CGRect {
        return CGRect(x: left, y: top, width: width - left - right, height: height - top - bottom)
    }
    
    func toEdgeInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
}
