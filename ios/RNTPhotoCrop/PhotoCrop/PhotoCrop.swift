
import UIKit

public class PhotoCrop: UIView {
    
    public var image: UIImage? {
        didSet {
            if image == oldValue {
                return
            }
            photoView.imageView.image = image
            foregroundView.imageView.image = image
        }
    }
    
    public var onInteractionStart: (() -> Void)?
    public var onInteractionEnd: (() -> Void)?
    
    // 图片容器，可缩放
    private lazy var photoView: PhotoView = {
       
        let view = PhotoView()
        
        view.scaleType = .fit
        view.backgroundColor = configuration.backgroundColor
        
        view.onScaleChange = {
            if self.finderView.alpha > 0 {
                self.updateFinderMinSize()
            }
            if self.foregroundView.alpha > 0 {
                self.foregroundView.updateImageSize()
            }
        }
        view.onOriginChange = {
            if self.foregroundView.alpha > 0 {
                self.foregroundView.updateImageOrigin()
            }
        }
        view.onReset = {
            if self.foregroundView.alpha > 0 {
                self.foregroundView.updateImageSize()
                self.foregroundView.updateImageOrigin()
            }
        }
        
        foregroundView.photoView = view
        
        return view
        
    }()
    
    private lazy var overlayView: OverlayView = {
        
        let view = OverlayView()
        
        view.isHidden = true

        view.blurView.alpha = configuration.overlayBlurAlpha

        return view
        
    }()
    
    // 裁剪器
    private lazy var finderView: FinderView = {
       
        let view = FinderView()
        
        view.isHidden = true
        view.cropRatio = configuration.cropWidth / configuration.cropHeight
        view.configuration = configuration
        
        view.onCropAreaChange = {
            let rect = view.cropArea.toRect(width: self.bounds.width, height: self.bounds.height)
            self.foregroundView.frame = rect
            self.gridView.frame = rect
        }
        view.onCropAreaResize = {
            self.updateCropArea(by: self.finderView.normalizedCropArea)
        }
        view.onInteractionStart = {
            self.updateInteractionState(overlayAlpha: self.configuration.overlayAlphaInteractive, gridAlpha: 1)
            self.onInteractionStart?()
        }
        view.onInteractionEnd = {
            self.updateInteractionState(overlayAlpha: self.configuration.overlayAlphaNormal, gridAlpha: 0)
            self.onInteractionEnd?()
        }
        
        return view
    }()
    
    private lazy var foregroundView: ForegroundView = {

        let view = ForegroundView()
        
        view.isHidden = true

        return view
        
    }()
    
    private lazy var gridView: GridView = {
        
        let view = GridView()
        
        view.alpha = 0
        view.isHidden = true

        view.configuration = configuration

        return view
        
    }()
    
    private var isAnimating = false
    
    public var isCropping = false {
        didSet {
            
            guard isCropping != oldValue else {
                return
            }

            finderView.stopInteraction()
            
            if isCropping {

                overlayView.isHidden = false
                finderView.isHidden = false
                foregroundView.isHidden = false
                gridView.isHidden = false
                
                overlayView.alpha = 0
                finderView.alpha = 0

                photoView.scaleType = .fill
                
                // 初始化裁剪区域，尺寸和当前图片一样大
                // 这样就会有一个从大到小的动画
                finderView.cropArea = getCropAreaByPhotoView()
                
                // 停一下(为了触发动画)，调整成符合比例的裁剪框
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    self.startAnimation(duration: 0.5, animations: {
                        let cropArea = self.finderView.normalizedCropArea
                        self.finderView.cropArea = cropArea
                        self.photoView.contentInset = cropArea.toEdgeInsets()
                        self.photoView.reset()
                        self.overlayView.alpha = self.configuration.overlayAlphaNormal
                        self.finderView.alpha = 1
                    })
                    
                }
                
            }
            else {

                photoView.scaleType = .fit
                photoView.contentInset = nil
                
                // 从选定的裁剪区域到图片区域的动画
                startAnimation(duration: 0.5, animations: {
                    self.photoView.reset()
                    self.finderView.cropArea = self.getCropAreaByPhotoView()
                    self.overlayView.alpha = 0
                    self.finderView.alpha = 0
                }, completion: {
                    self.overlayView.isHidden = true
                    self.finderView.isHidden = true
                    self.gridView.isHidden = true
                    self.foregroundView.isHidden = true
                })
                
            }
            
        }
    }
    
    private var configuration: PhotoCropConfiguration!

    public convenience init(configuration: PhotoCropConfiguration) {
        self.init()
        self.configuration = configuration
        addSubview(photoView)
        addSubview(overlayView)
        addSubview(foregroundView)
        addSubview(finderView)
        addSubview(gridView)
    }

    public override func layoutSubviews() {
        
        super.layoutSubviews()
        
        photoView.frame = bounds
        overlayView.frame = bounds
        finderView.frame = bounds

    }

    public func rotate(degrees: CGFloat) {
        
        guard let bitmap = image else {
            return
        }
        
        image = Util.shared.rotateImage(image: bitmap, degrees: degrees)
        
    }
    
    public func reset() {
        
        startAnimation(duration: 0.5, animations: {
            self.photoView.reset()
        })
        
    }
    
    public func crop() -> UIImage? {

        guard let source = photoView.imageView.image, let sourceSize = photoView.imageOriginalSize, isCropping else {
            return nil
        }

        foregroundView.save()

        let sourceWidth = sourceSize.width
        let sourceHeight = sourceSize.height

        let x = abs(foregroundView.relativeX) * sourceWidth
        let y = abs(foregroundView.relativeY) * sourceHeight
        let width = foregroundView.relativeWidth * sourceWidth
        let height = foregroundView.relativeHeight * sourceHeight
        
        let rect = CGRect(
            x: floor(x),
            y: floor(y),
            width: round(width),
            height: round(height)
        )

        if let croped = source.cgImage?.cropping(to: rect) {
            
            // 最终输出的图片尺寸
            let size = CGSize(
                width: configuration.cropWidth,
                height: configuration.cropHeight
            )
            
            // 除了定义图片尺寸，还需指定图片的缩放值，也就是像素密度
            // 这样输出的图片质量才和裁剪时预览所见相同
            var scale = floor(width / configuration.cropWidth)
            if scale < 1 {
                scale = 1
            }

            return Util.shared.createNewImage(
                image: UIImage(cgImage: croped, scale: scale, orientation: source.imageOrientation),
                size: size,
                scale: scale
            )
            
        }
        
        return nil
        
    }
    
    // 裁剪出来的是最高清的图，这里保存的也是高清图
    public func save(image: UIImage, extname: String) -> CropFile? {
        
        return Util.shared.createNewFile(image: image, quality: 1, extname: extname)
        
    }
    
    // 如果无需高清，可压缩
    public func compress(source: CropFile) -> CropFile {
        
        return Compressor(maxSize: configuration.maxSize, quality: configuration.quality)
            .compress(source: source, width: configuration.cropWidth, height: configuration.cropHeight)
        
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        if finderView.alpha > 0 && !isAnimating {
            finderView.addInteractionTimer()
        }
        
        return super.hitTest(point, with: event)
        
    }
    
}

extension PhotoCrop {

    private func updateFinderMinSize() {

        let finderMinWidth = configuration.finderMinWidth
        let finderMinHeight = configuration.finderMinHeight
        
        // 有两个限制：
        // 1. 裁剪框不能小于 finderMinWidth/finderMinHeight
        // 2. 裁剪后的图片不能小余 cropWidth/cropHeight
        
        let normalizedRect = finderView.normalizedCropArea.toRect(width: bounds.width, height: bounds.height)
        let normalizedWidth = normalizedRect.width
        let normalizedHeight = normalizedRect.height
        
        // 这是裁剪框能缩放的最小尺寸
        let scaleFactor = photoView.maxScale / photoView.scale
        let finderWidth = max(normalizedWidth / scaleFactor, finderMinWidth)
        let finderHeight = max(normalizedHeight / scaleFactor, finderMinHeight)
        
        // 裁剪框尺寸对应的图片尺寸
        // 因为 photoView 已到达 maxScale，因此裁剪框和图片是 1:1 的关系
//        let cropWidth = configuration.cropWidth
//        let cropHeight = configuration.cropHeight
//        if (finderWidth < cropWidth) {
//            finderWidth = cropWidth / scaleFactor
//        }
//        if (finderHeight < cropHeight) {
//            finderHeight = cropHeight / scaleFactor
//        }

        finderView.minWidth = finderWidth
        finderView.minHeight = finderHeight
        
    }
    
    // CropArea 完全覆盖 PhotoView
    private func getCropAreaByPhotoView() -> CropArea {
        
        let imageOrigin = photoView.imageOrigin
        let imageSize = photoView.imageSize
        
        let left = max(imageOrigin.x, 0)
        let top = max(imageOrigin.y, 0)
        
        let right = max(photoView.frame.width - (imageOrigin.x + imageSize.width), 0)
        let bottom = max(photoView.frame.height - (imageOrigin.y + imageSize.height), 0)
        
        return CropArea(top: top, left: left, bottom: bottom, right: right)
        
    }
    
    private func updateCropArea(by cropArea: CropArea) {
        
        let width = bounds.width
        let height = bounds.height

        let oldRect = finderView.cropArea.toRect(width: width, height: height)
        let newRect = cropArea.toRect(width: width, height: height)
        
        // 谁更大就用谁作为缩放系数
        let widthScale = newRect.width / oldRect.width
        let heightScale = newRect.height / oldRect.height
        let scale = max(widthScale, heightScale)
        
        guard scale != 1 else {
            return
        }

        startAnimation(duration: 0.3, animations: {
            
            self.foregroundView.save()
            
            self.finderView.cropArea = cropArea
            self.photoView.scale *= scale
            
            self.foregroundView.restore()
            
        })
        
    }
    
    private func updateInteractionState(overlayAlpha: CGFloat, gridAlpha: CGFloat) {
        
        UIView.animate(withDuration: 0.5) {
            self.overlayView.alpha = overlayAlpha
            self.gridView.alpha = gridAlpha
        }
        
    }
    
    private func startAnimation(duration: TimeInterval, animations: @escaping () -> Void, completion: (() -> Void)? = nil) {
        
        isAnimating = true
        
        UIView.animate(withDuration: duration, animations: {
            animations()
        }, completion: { success in
            self.isAnimating = false
            completion?()
        })
        
    }
    
}

