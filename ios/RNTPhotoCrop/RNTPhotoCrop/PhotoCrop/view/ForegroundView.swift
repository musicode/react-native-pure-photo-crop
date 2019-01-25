
import UIKit

// 没法在 Overlay 上实现打孔 + 动画
// 因此只好新建一个 View，用 clipsToBounds + imageView 的位移来实现
// 这个 view 需要跟 UIScrollView 紧密绑定，当 UIScrollView 滑动时，也要移动 imageView
// 从而实现视觉上的合二为一
class ForegroundView: UIView {
    
    var photoView: PhotoView!
    
    override var frame: CGRect {
        didSet {
            guard photoView != nil else {
                return
            }
            updateImageOrigin()
        }
    }
    
    lazy var imageView: UIImageView = {
    
        let view = UIImageView()
        addSubview(view)
        
        clipsToBounds = true
        
        return view
        
    }()
    
    var relativeX: CGFloat = 0
    var relativeY: CGFloat = 0
    
    var relativeWidth: CGFloat = 0
    var relativeHeight: CGFloat = 0
    
    // 记录图片的当前位置
    func save() {
        
        let imageFrame = imageView.frame
        
        relativeX = imageFrame.origin.x / imageFrame.width
        relativeY = imageFrame.origin.y / imageFrame.height
        
        relativeWidth = frame.width / imageFrame.width
        relativeHeight = frame.height / imageFrame.height
        
    }
    
    // 当 UIScrollView 发生改变后，再把记录的相对位置还原回去
    func restore() {
        
        var imageFrame = imageView.frame
        let x = relativeX * imageFrame.width
        let y = relativeY * imageFrame.height
        
        imageFrame.origin = CGPoint(x: x, y: y)
        
        let offsetX = x + frame.origin.x
        let offsetY = y + frame.origin.y
        
        photoView.imageOrigin = CGPoint(x: offsetX, y: offsetY)
        
    }

    func updateImageOrigin() {

        let imageOrigin = photoView.imageOrigin

        imageView.frame.origin = CGPoint(
            x: imageOrigin.x - frame.origin.x,
            y: imageOrigin.y - frame.origin.y
        )
        
    }
    
    func updateImageSize() {
        
        imageView.frame.size = photoView.imageSize

    }
    
    // 无视各种交互
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
}
