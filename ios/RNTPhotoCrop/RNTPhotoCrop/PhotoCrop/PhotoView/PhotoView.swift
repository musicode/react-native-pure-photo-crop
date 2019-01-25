
import UIKit

// https://www.appcoda.com/uiscrollview-introduction/

// image.size 是原始尺寸
// imageView.frame.size 是缩放后的尺寸

// 继承 UIView，而不是 UIScrollView
// 这样双击放大不会触发 layoutSubviews
public class PhotoView: UIView {
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        
        view.addObserver(self, forKeyPath: "contentSize", options: [.new, .old], context: nil)
        view.addObserver(self, forKeyPath: "contentOffset", options: [.new, .old], context: nil)
        
        addSubview(view)
        return view
    }()

    public lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.addObserver(self, forKeyPath: "image", options: [.new, .old], context: nil)
        scrollView.addSubview(view)
        return view
    }()
    
    public override var frame: CGRect {
        didSet {
            size = frame.size
        }
    }
    
    private var size = CGSize.zero {
        didSet {
            
            let oldWidth = oldValue.width
            let oldHeight = oldValue.height
            
            let newWidth = size.width
            let newHeight = size.height
            
            guard newWidth != oldWidth || newHeight != oldHeight else {
                return
            }
            scrollView.frame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
            
            reset()
            
        }
    }
    
    public var scaleType = ScaleType.fillWidth
    
    public var scale: CGFloat {
        get {
            return scrollView.zoomScale
        }
        set {
            scrollView.zoomScale = newValue
        }
    }
    
    public var minScale: CGFloat {
        get {
            return scrollView.minimumZoomScale
        }
        set {
            scrollView.minimumZoomScale = newValue
        }
    }
    
    public var maxScale: CGFloat {
        get {
            return scrollView.maximumZoomScale
        }
        set {
            scrollView.maximumZoomScale = newValue
        }
    }
    
    public var imageOrigin: CGPoint {
        get {
            let contentOffset = scrollView.contentOffset
            return CGPoint(x: -contentOffset.x, y: -contentOffset.y)
        }
        set {
            scrollView.contentOffset = CGPoint(x: -newValue.x, y: -newValue.y)
        }
    }
    
    public var imageSize: CGSize {
        get {
            return imageView.frame.size
        }
    }
    
    public var imageOriginalSize: CGSize? {
        get {
            guard let image = imageView.image else {
                return nil
            }
            return getImageSize(image: image)
        }
    }
    
    public var calculateMaxScale: ((CGFloat) -> CGFloat) = { scale in
        return 3 * scale < 1 ? 1 : (3 * scale)
    }
    public var calculateMinScale: ((CGFloat) -> CGFloat) = { scale in
        return scale
    }

    public var onReset: (() -> Void)?
    
    public var onTap: (() -> Void)?
    public var onLongPress: (() -> Void)?
    public var onScaleChange: (() -> Void)?
    public var onOriginChange: (() -> Void)?
    public var onDragStart: (() -> Void)?
    public var onDragEnd: (() -> Void)?
    
    public var contentInset: UIEdgeInsets?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public func reset(image: UIImage? = nil) {

        if let image = image {
            
            minScale = 1
            maxScale = 1
            scale = 1

            imageView.frame.size = getImageSize(image: image)
            
        }
        
        updateZoomScale()
        updateImageOrigin()
        
        onReset?()
        
    }

    private func getContentInset() -> UIEdgeInsets {
        
        guard contentInset == nil else {
            return contentInset!
        }
        
        let imageSize = imageView.frame.size
        guard imageSize.width > 0 && imageSize.height > 0 else {
            return .zero
        }
        
        let viewSize = bounds.size
        
        var insetHorizontal: CGFloat = 0
        var insetVertical: CGFloat = 0
        
        if viewSize.width > imageSize.width {
            insetHorizontal = (viewSize.width - imageSize.width) / 2
        }
        if viewSize.height > imageSize.height {
            insetVertical = (viewSize.height - imageSize.height) / 2
        }
        
        return UIEdgeInsets(top: insetVertical, left: insetHorizontal, bottom: insetVertical, right: insetHorizontal)
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        size = frame.size
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let keyPath = keyPath else {
            return
        }
        
        switch keyPath {
        case "image":
            if let image = imageView.image {
                reset(image: image)
            }
            break
            
        case "contentSize":
            onScaleChange?()
            break
            
        case "contentOffset":
            onOriginChange?()
            break
        default: ()
        }
        
        
    }

}

extension PhotoView: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView.image != nil ? imageView : nil
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        onDragStart?()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        onDragEnd?()
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateImageOrigin()
    }
    
}

extension PhotoView {
    
    private func setup() {
        
        backgroundColor = .black
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapGesture))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(onDoubleTapGesture))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
        
        // 避免 doubleTap 时触发 tap 回调
        tap.require(toFail: doubleTap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture))
        imageView.addGestureRecognizer(longPress)
        
    }
    
    private func updateZoomScale() {
        
        guard let imageSize = imageOriginalSize else {
            return
        }

        let contentInset = getContentInset()
        let viewWidth = bounds.size.width - contentInset.left - contentInset.right
        let viewHeight = bounds.size.height - contentInset.top - contentInset.bottom
        
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        
        let widthScale = viewWidth / imageWidth
        let heightScale = viewHeight / imageHeight

        let zoomScale: CGFloat
        if scaleType == .fillWidth {
            zoomScale = widthScale
        }
        else if scaleType == .fillHeight {
            zoomScale = heightScale
        }
        else if scaleType == .fill {
            zoomScale = max(widthScale, heightScale)
        }
        else {
            zoomScale = min(widthScale, heightScale)
        }

        minScale = calculateMinScale(zoomScale)
        maxScale = max(calculateMaxScale(zoomScale), minScale)
        
        scale = zoomScale
        
    }
    
    private func updateImageOrigin() {
        
        scrollView.contentInset = getContentInset()

    }
    
    private func getZoomRect(point: CGPoint, zoomScale: CGFloat) -> CGRect {
        
        // 传入的 point 是相对于图片的实际尺寸计算的

        let x = point.x
        let y = point.y
        
        // 这里的 width height 需要以当前视图为窗口进行缩放
        
        let viewSize = bounds.size
        let width = viewSize.width / zoomScale
        let height = viewSize.height / zoomScale

        return CGRect(x: x - width / 2, y: y - height / 2, width: width, height: height)
        
    }
    
    private func getImageSize(image: UIImage) -> CGSize {
        return CGSize(
            width: image.size.width * image.scale,
            height: image.size.height * image.scale
        )
    }
    
    @objc private func onTapGesture(_ gesture: UILongPressGestureRecognizer) {
        
        onTap?()
        
    }
    
    @objc private func onDoubleTapGesture(_ gesture: UITapGestureRecognizer) {
        
        // 距离谁比较远就去谁
        let zoomScale = (scale - minScale > maxScale - scale) ? minScale : maxScale
        guard zoomScale != scale else {
            return
        }
        
        let point = gesture.location(in: imageView)

        scrollView.zoom(to: getZoomRect(point: point, zoomScale: zoomScale), animated: true)
        
    }
    
    @objc private func onLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        
        guard gesture.state == .began else {
            return
        }
        
        onLongPress?()
        
    }
    
}

extension PhotoView {
    
    public enum ScaleType {
        case fit, fill, fillWidth, fillHeight
    }
    
}
