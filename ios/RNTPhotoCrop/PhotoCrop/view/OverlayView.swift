
import UIKit

class OverlayView: UIView {

    override var frame: CGRect {
        didSet {
            guard frame.width != oldValue.width || frame.height != oldValue.height else {
                return
            }
            update()
        }
    }

    lazy var blurView: UIVisualEffectView = {
        
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))

        insertSubview(view, at: 0)

        return view
        
    }()
    
    // 无视各种交互
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
    private func update() {
        
        blurView.frame = bounds
        
    }

}
