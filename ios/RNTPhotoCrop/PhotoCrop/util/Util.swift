
import UIKit

class Util {
    
    static let shared = Util()
    
    private var index = 0
    
    private init() {
        
    }
    
    func getFilePath(dirname: String, extname: String) -> String {
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dirname) {
            try? fileManager.createDirectory(atPath: dirname, withIntermediateDirectories: true, attributes: nil)
        }
        
        let format = DateFormatter()
        format.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        
        // 怕相同时间执行了多次
        index += 1
        
        let filename = "\(format.string(from: Date()))_\(index)\(extname)"
        
        if dirname.hasSuffix("/") {
            return dirname + filename
        }
        
        return "\(dirname)/\(filename)"
        
    }
    
    // https://stackoverflow.com/questions/36645060/rotate-uiimage-in-swift
    func rotateImage(image: UIImage, degrees: CGFloat) -> UIImage {
        
        let size = image.size
        let angle = degrees * CGFloat.pi / 180
        
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.transform = CGAffineTransform(rotationAngle: angle)
        let newSize: CGSize = view.frame.size
        
        UIGraphicsBeginImageContext(newSize)
        
        guard let bitmap = UIGraphicsGetCurrentContext() else {
            return image
        }
        
        // 中心旋转
        bitmap.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        bitmap.rotate(by: angle)
        bitmap.scaleBy(x: 1.0, y: -1.0)
        
        bitmap.draw(
            image.cgImage!,
            in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height)
        )
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
    func createNewImage(image: UIImage, size: CGSize, scale: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let result = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        
        return result
        
    }
    
    func createNewFile(image: UIImage, quality: CGFloat) -> CropFile? {
        
        if let data = image.jpegData(compressionQuality: quality) as NSData? {
            let path = Util.shared.getFilePath(dirname: NSTemporaryDirectory(), extname: ".jpg")
            if data.write(toFile: path, atomically: true) {
                return CropFile(path: path, size: data.length, width: image.size.width * image.scale, height: image.size.height * image.scale)
            }
        }
        
        return nil
        
    }
    
}
