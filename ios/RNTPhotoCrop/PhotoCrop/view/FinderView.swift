
import UIKit

class FinderView: UIView {
    
    var configuration: PhotoCropConfiguration!
    
    var onCropAreaChange: (() -> Void)!
    var onCropAreaResize: (() -> Void)!
    
    var onInteractionStart: (() -> Void)!
    var onInteractionEnd: (() -> Void)!
    
    override var frame: CGRect {
        didSet {
            size = frame.size
        }
    }
    
    var cropArea = CropArea.zero {
        didSet {
            update()
            onCropAreaChange()
        }
    }
    
    var normalizedCropArea = CropArea.zero
    
    var cropRatio: CGFloat = 1

    var minWidth: CGFloat = 0
    var minHeight: CGFloat = 0
    
    private lazy var topBorder: UIView = {
        return createBorder()
    }()
    
    private lazy var rightBorder: UIView = {
        return createBorder()
    }()
    
    private lazy var bottomBorder: UIView = {
        return createBorder()
    }()
    
    private lazy var leftBorder: UIView = {
        return createBorder()
    }()
    
    private lazy var topLeftButton: UIView = {
        return createButton()
    }()
    
    private lazy var topRightButton: UIView = {
        return createButton()
    }()
    
    private lazy var bottomLeftButton: UIView = {
        return createButton()
    }()
    
    private lazy var bottomRightButton: UIView = {
        return createButton()
    }()

    private lazy var topLeftHorizontalLine: UIView = {
        return createHorizontalCornerLine()
    }()
    
    private lazy var topLeftVerticalLine: UIView = {
        return createVerticalCornerLine()
    }()
    
    private lazy var topRightHorizontalLine: UIView = {
        return createHorizontalCornerLine()
    }()
    
    private lazy var topRightVerticalLine: UIView = {
        return createVerticalCornerLine()
    }()
    
    private lazy var bottomLeftHorizontalLine: UIView = {
        return createHorizontalCornerLine()
    }()
    
    private lazy var bottomLeftVerticalLine: UIView = {
        return createVerticalCornerLine()
    }()
    
    private lazy var bottomRightHorizontalLine: UIView = {
        return createHorizontalCornerLine()
    }()
    
    private lazy var bottomRightVerticalLine: UIView = {
        return createVerticalCornerLine()
    }()
    
    private var resizeCropAreaTimer: Timer?
    
    private var interactionTimer: Timer?
    
    private var isInteractive = false {
        didSet {
            guard isInteractive != oldValue, !isHidden else {
                return
            }
            if isInteractive {
                onInteractionStart()
            }
            else {
                onInteractionEnd()
            }
        }
    }
    
    private var size = CGSize.zero {
        didSet {
            
            guard size.width != oldValue.width || size.height != oldValue.height else {
                return
            }
            
            var cropWidth = size.width - configuration.finderCornerButtonSize - 2 * configuration.finderCornerLineWidth
            var cropHeight = cropWidth / cropRatio
            
            if cropHeight > size.height {
                cropHeight = size.height - configuration.finderCornerButtonSize - 2 * configuration.finderCornerLineWidth
                cropWidth = cropHeight * cropRatio
            }
            
            if configuration.finderMaxWidth > 0 && cropWidth > configuration.finderMaxWidth {
                cropWidth = configuration.finderMaxWidth
                cropHeight = cropWidth / cropRatio
            }
            if configuration.finderMaxHeight > 0 && cropHeight > configuration.finderMaxHeight {
                cropHeight = configuration.finderMaxHeight
                cropWidth = cropHeight * cropRatio
            }
            
            let vertical = (size.height - cropHeight) / 2
            let horizontal = (size.width - cropWidth) / 2
            
            normalizedCropArea = CropArea(top: vertical, left: horizontal, bottom: vertical, right: horizontal)

            // 重新计算裁剪区域
            if oldValue.width > 0 && oldValue.height > 0 {
                resizeCropArea()
            }
            else {
                update()
            }
            
        }
    }
    
    @objc private func resize(gestureRecognizer: UIPanGestureRecognizer) {
        
        guard let button = gestureRecognizer.view as? UIButton else {
            return
        }

        let state = gestureRecognizer.state
        guard (state == .began && resizeCropAreaTimer == nil) || state == .changed else {
            return
        }
        
        let viewWidth = size.width
        let viewHeight = size.height
        
        // 位移量
        let offsetX = gestureRecognizer.translation(in: self).x
        
        // 裁剪区域
        var left = cropArea.left
        var top = cropArea.top
        
        var right = viewWidth - cropArea.right
        var bottom = viewHeight - cropArea.bottom
        
        let maxLeft = normalizedCropArea.left
        let maxRight = viewWidth - normalizedCropArea.right
        
        switch button {
        case topLeftButton:
            left = min(right - minWidth, max(maxLeft, left + offsetX))
            top = bottom - (right - left) / cropRatio
            break
        case topRightButton:
            right = min(maxRight, max(left + minWidth, right + offsetX))
            top = bottom - (right - left) / cropRatio
            break
        case bottomRightButton:
            right = min(maxRight, max(left + minWidth, right + offsetX))
            bottom = top + (right - left) / cropRatio
            break
        default:
            left = min(right - minWidth, max(maxLeft, left + offsetX))
            bottom = top + (right - left) / cropRatio
            break
        }
        
        cropArea = CropArea(top: top, left: left, bottom: viewHeight - bottom, right: viewWidth - right)
        
        addResizeCropAreaTimer()
        addInteractionTimer()
        
        gestureRecognizer.setTranslation(.zero, in: self)
        
    }
    
    @objc private func resizeCropArea() {
        removeResizeCropAreaTimer()
        if !isHidden {
            onCropAreaResize()
        }
    }
    
    @objc func stopInteraction() {
        removeInteractionTimer()
        isInteractive = false
    }
    
    private func addResizeCropAreaTimer() {
        removeResizeCropAreaTimer()
        resizeCropAreaTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(resizeCropArea), userInfo: nil, repeats: false)
    }
    
    private func removeResizeCropAreaTimer() {
        resizeCropAreaTimer?.invalidate()
        resizeCropAreaTimer = nil
    }
    
    func addInteractionTimer() {
        removeInteractionTimer()
        interactionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(stopInteraction), userInfo: nil, repeats: false)
        isInteractive = true
    }
    
    private func removeInteractionTimer() {
        interactionTimer?.invalidate()
        interactionTimer = nil
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }
        if topLeftButton === view
            || topRightButton === view
            || bottomLeftButton === view
            || bottomRightButton === view
        {
            return view
        }
        return nil
    }
    
}

extension FinderView {

    private func createLine(color: UIColor) -> UIView {
        let line = UIView()
        line.backgroundColor = color
        addSubview(line)
        return line
    }
    
    private func createBorder() -> UIView {
        let line = createLine(color: configuration.finderBorderColor)
        line.layer.shadowColor = UIColor.black.cgColor
        line.layer.shadowOpacity = 0.3
        line.layer.shadowOffset = CGSize(width: 0, height: 0)
        line.layer.shadowRadius = 3
        return line
    }
    
    private func createHorizontalCornerLine() -> UIView {
        let line = createLine(color: configuration.finderCornerLineColor)
        line.frame = CGRect(x: 0, y: 0, width: configuration.finderCornerLineSize, height: configuration.finderCornerLineWidth)
        return line
    }
    
    private func createVerticalCornerLine() -> UIView {
        let line = createLine(color: configuration.finderCornerLineColor)
        line.frame = CGRect(x: 0, y: 0, width: configuration.finderCornerLineWidth, height: configuration.finderCornerLineSize)
        return line
    }
    
    private func createButton() -> UIButton {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: configuration.finderCornerButtonSize, height: configuration.finderCornerButtonSize)
        button.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(resize)))
        addSubview(button)
        return button
    }
    
    private func update() {
        
        let left = cropArea.left
        let top = cropArea.top
        let right = size.width - cropArea.right
        let bottom = size.height - cropArea.bottom
        
        let halfButtonSize = configuration.finderCornerButtonSize / 2
        let finderBorderWidth = configuration.finderBorderWidth
        let finderCornerLineWidth = configuration.finderCornerLineWidth
        let finderCornerLineSize = configuration.finderCornerLineSize
        
        topBorder.frame = CGRect(x: left, y: top - finderBorderWidth, width: right - left, height: finderBorderWidth)
        rightBorder.frame = CGRect(x: right, y: top, width: finderBorderWidth, height: bottom - top)
        bottomBorder.frame = CGRect(x: left, y: bottom, width: right - left, height: finderBorderWidth)
        leftBorder.frame = CGRect(x: left - finderBorderWidth, y: top, width: finderBorderWidth, height: bottom - top)

        topLeftHorizontalLine.frame.origin = CGPoint(x: left - finderCornerLineWidth, y: top - finderCornerLineWidth)
        topLeftVerticalLine.frame.origin = CGPoint(x: left - finderCornerLineWidth, y: top - finderCornerLineWidth)
        topLeftButton.frame.origin = CGPoint(x: left - finderCornerLineWidth - halfButtonSize, y: top - finderCornerLineWidth - halfButtonSize)

        topRightHorizontalLine.frame.origin = CGPoint(x: right + finderCornerLineWidth - finderCornerLineSize, y: top - finderCornerLineWidth)
        topRightVerticalLine.frame.origin = CGPoint(x: right, y: top - finderCornerLineWidth)
        topRightButton.frame.origin = CGPoint(x: right + finderCornerLineWidth - halfButtonSize, y: top - finderCornerLineWidth - halfButtonSize)

        bottomRightHorizontalLine.frame.origin = CGPoint(x: right + finderCornerLineWidth - finderCornerLineSize, y: bottom)
        bottomRightVerticalLine.frame.origin = CGPoint(x: right, y: bottom + finderCornerLineWidth - finderCornerLineSize)
        bottomRightButton.frame.origin = CGPoint(x: right + finderCornerLineWidth - halfButtonSize, y: bottom + finderCornerLineWidth - halfButtonSize)

        bottomLeftHorizontalLine.frame.origin = CGPoint(x: left - finderCornerLineWidth, y: bottom)
        bottomLeftVerticalLine.frame.origin = CGPoint(x: left - finderCornerLineWidth, y: bottom + finderCornerLineWidth - finderCornerLineSize)
        bottomLeftButton.frame.origin = CGPoint(x: left - finderCornerLineWidth - halfButtonSize, y: bottom + finderCornerLineWidth - halfButtonSize)
        
    }
    
}

