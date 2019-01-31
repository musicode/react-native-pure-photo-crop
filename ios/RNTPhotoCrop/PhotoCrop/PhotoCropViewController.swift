
import UIKit

public class PhotoCropViewController: UIViewController {
    
    @objc public static var loadImage: ((String, @escaping (UIImage?) -> Void) -> Void)!
    
    @objc public var delegate: PhotoCropDelegate!
    @objc public var configuration: PhotoCropConfiguration!

    private var photoCrop: PhotoCrop!
    private var cancelButton: SimpleButton!
    private var resetButton: SimpleButton!
    private var submitButton: SimpleButton!
    
    private var url: String!

    private var bottomLayoutConstraint: NSLayoutConstraint!
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc public func show(url: String) {
        
        self.url = url
        
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = .crossDissolve
        
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
        }
        
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false
        
        photoCrop = PhotoCrop(configuration: configuration)
        
        photoCrop.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(photoCrop)
        view.backgroundColor = .black
        
        view.addConstraints([
            NSLayoutConstraint(item: photoCrop, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
        ])
        
        let buttonTextFont = UIFont.systemFont(ofSize: 15)
        let buttonTextColor = UIColor.white
        
        let buttonWidth: CGFloat = 50
        let buttonHeight: CGFloat = 50
        
        cancelButton = SimpleButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(buttonTextColor, for: .normal)
        cancelButton.titleLabel?.font = buttonTextFont
        cancelButton.onClick = {
            self.delegate.photoCropDidCancel(self)
        }

        resetButton = SimpleButton()
        resetButton.isHidden = true
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.setTitle("重置", for: .normal)
        resetButton.setTitleColor(buttonTextColor, for: .normal)
        resetButton.titleLabel?.font = buttonTextFont
        resetButton.onClick = {
            self.photoCrop.reset()
        }
        
        submitButton = SimpleButton()
        submitButton.isHidden = true
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("确定", for: .normal)
        submitButton.setTitleColor(buttonTextColor, for: .normal)
        submitButton.titleLabel?.font = buttonTextFont
        submitButton.onClick = {
            guard let image = self.photoCrop.crop() else {
                return
            }
            DispatchQueue.global(qos: .default).async {
                guard let file = self.photoCrop.save(image: image) else {
                    return
                }
                let result = self.photoCrop.compress(source: file)
                DispatchQueue.main.async {
                    self.delegate.photoCropDidSubmit(self, cropFile: result)
                }
            }
        }
        
        
        let bottomBar = UIView()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        bottomBar.addSubview(cancelButton)
        bottomBar.addSubview(resetButton)
        bottomBar.addSubview(submitButton)
        
        view.addSubview(bottomBar)
        
        bottomLayoutConstraint = NSLayoutConstraint(item: bottomBar, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([
            
            NSLayoutConstraint(item: bottomBar, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bottomBar, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            bottomLayoutConstraint,

            NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: bottomBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cancelButton, attribute: .bottom, relatedBy: .equal, toItem: bottomBar, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: cancelButton, attribute: .left, relatedBy: .equal, toItem: bottomBar, attribute: .left, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: buttonWidth),
            NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: buttonHeight),
            
            NSLayoutConstraint(item: resetButton, attribute: .centerY, relatedBy: .equal, toItem: cancelButton, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: resetButton, attribute: .centerX, relatedBy: .equal, toItem: bottomBar, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: resetButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: buttonWidth),
            NSLayoutConstraint(item: resetButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: buttonHeight),
            
            NSLayoutConstraint(item: submitButton, attribute: .centerY, relatedBy: .equal, toItem: cancelButton, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: submitButton, attribute: .right, relatedBy: .equal, toItem: bottomBar, attribute: .right, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: submitButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: buttonWidth),
            NSLayoutConstraint(item: submitButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: buttonHeight),

        ])

        PhotoCropViewController.loadImage(url) { [weak self] image in
            
            guard let _self = self, let image = image else {
                return
            }
            
            DispatchQueue.main.async {
                _self.photoCrop.image = image
                Timer.scheduledTimer(timeInterval: 0.5, target: _self, selector: #selector(_self.startCropping), userInfo: nil, repeats: false)
            }
            
        }
        
    }
    
    @objc private func startCropping() {
        photoCrop.isCropping = true
        resetButton.isHidden = false
        submitButton.isHidden = false
    }
    
    public override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            bottomLayoutConstraint.constant = -view.safeAreaInsets.bottom
            view.setNeedsLayout()
        }
        
    }
    
}
