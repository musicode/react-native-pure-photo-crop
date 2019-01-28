
import UIKit

class GridView: UIView {
    
    var configuration: PhotoCropConfiguration!
    
    lazy var horizontalLines: [UIView] = {
        return [createLine(color: configuration.gridLineColor), createLine(color: configuration.gridLineColor)]
    }()
    
    lazy var verticalLines: [UIView] = {
        return [createLine(color: configuration.gridLineColor), createLine(color: configuration.gridLineColor)]
    }()
    
    override var frame: CGRect {
        didSet {
            guard frame.width != oldValue.width || frame.height != oldValue.height else {
                return
            }
            update()
        }
    }

    // 无视各种交互
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return nil
    }
    
}

extension GridView {
    
    private func createLine(color: UIColor) -> UIView {
        let line = UIView()
        line.backgroundColor = color
        addSubview(line)
        return line
    }
    
    private func update() {
        
        let width = bounds.width
        let height = bounds.height
        
        let lineWidth = configuration.gridLineWidth
        let rowSpacing = height / CGFloat(horizontalLines.count + 1)
        let columnSpacing = width / CGFloat(verticalLines.count + 1)
        
        for (i, line) in horizontalLines.enumerated() {
            let offset = rowSpacing * CGFloat(i + 1) + lineWidth * CGFloat(i)
            line.frame = CGRect(x: 0, y: offset, width: width, height: lineWidth)
        }
        
        for (i, line) in verticalLines.enumerated() {
            let offset = columnSpacing * CGFloat(i + 1) + lineWidth * CGFloat(i)
            line.frame = CGRect(x: offset, y: 0, width: lineWidth, height: height)
        }
        
    }
    
}
