
import UIKit

public class PhotoCropViewController: UIViewController {
    
    @objc public static var loadImage: ((String, @escaping (UIImage?) -> Void) -> Void)!
    
    @objc public var delegate: PhotoCropDelegate!
    @objc public var configuration: PhotoCropConfiguration!

    private var photoCrop: PhotoCrop!
    
    private var separatorView: UIView!
    private var cancelButton: SimpleButton!
    private var resetButton: SimpleButton!
    private var submitButton: SimpleButton!
    private var rotateButton: SimpleButton!
    
    private var url: String!

    private var topLayoutConstraint: NSLayoutConstraint?
    private var bottomLayoutConstraint: NSLayoutConstraint!
    
    private var isSubmitClicked = false
    private var isCancelClicked = false
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc public func show(url: String) {
        
        self.url = url
        
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = .crossDissolve
        
        UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
        
    }

    public override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        if (!isSubmitClicked && !isCancelClicked) {
            delegate.photoCropDidExit(self)
        }
        
    }
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        extendedLayoutIncludesOpaqueBars = true
        automaticallyAdjustsScrollViewInsets = false

        photoCrop = PhotoCrop(configuration: configuration)
        photoCrop.translatesAutoresizingMaskIntoConstraints = false
        photoCrop.onInteractionStart = {
            self.rotateButton.isHidden = true
        }
        photoCrop.onInteractionEnd = {
            self.rotateButton.isHidden = false
        }
        view.addSubview(photoCrop)
        
        separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = configuration.separatorLineColor
        view.addSubview(separatorView)
        
        cancelButton = SimpleButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.contentEdgeInsets.left = 6
        cancelButton.contentEdgeInsets.right = 6
        cancelButton.setTitle(configuration.cancelButtonTitle, for: .normal)
        cancelButton.setTitleColor(configuration.buttonTextColor, for: .normal)
        cancelButton.titleLabel?.font = configuration.buttonTextFont
        cancelButton.onClick = {
            self.isCancelClicked = true
            self.delegate.photoCropDidCancel(self)
        }
        view.addSubview(cancelButton)
        
        resetButton = SimpleButton()
        resetButton.isHidden = true
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        resetButton.contentEdgeInsets.left = 6
        resetButton.contentEdgeInsets.right = 6
        resetButton.setTitle(configuration.resetButtonTitle, for: .normal)
        resetButton.setTitleColor(configuration.buttonTextColor, for: .normal)
        resetButton.titleLabel?.font = configuration.buttonTextFont
        resetButton.onClick = {
            self.photoCrop.reset()
        }
        view.addSubview(resetButton)
        
        submitButton = SimpleButton()
        submitButton.isHidden = true
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.contentEdgeInsets.left = 6
        submitButton.contentEdgeInsets.right = 6
        submitButton.setTitle(configuration.submitButtonTitle, for: .normal)
        submitButton.setTitleColor(configuration.buttonTextColor, for: .normal)
        submitButton.titleLabel?.font = configuration.buttonTextFont
        submitButton.onClick = {
            guard let image = self.photoCrop.crop() else {
                return
            }
            DispatchQueue.global(qos: .default).async {
                let extname = Util.shared.getImageExtname(path: self.url)
                guard let file = self.photoCrop.save(image: image, extname: extname) else {
                    return
                }
                let result = self.photoCrop.compress(source: file)
                DispatchQueue.main.async {
                    self.isSubmitClicked = true
                    self.delegate.photoCropDidSubmit(self, cropFile: result)
                }
            }
        }
        view.addSubview(submitButton)
        
        rotateButton = SimpleButton()
        rotateButton.isHidden = true
        rotateButton.translatesAutoresizingMaskIntoConstraints = false
        rotateButton.setImage(configuration.rotateButtonImage, for: .normal)
        rotateButton.onClick = {
            self.photoCrop.rotate(degrees: -90)
        }
        view.addSubview(rotateButton)
        
        bottomLayoutConstraint = NSLayoutConstraint(item: separatorView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        var layoutConstraintList: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: photoCrop, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: photoCrop, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            
            
            NSLayoutConstraint(item: separatorView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: separatorView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: separatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: configuration.separatorLineWidth),
            bottomLayoutConstraint,

            NSLayoutConstraint(item: cancelButton, attribute: .top, relatedBy: .equal, toItem: separatorView, attribute: .bottom, multiplier: 1, constant: configuration.separatorLineSpacingBottom),
            NSLayoutConstraint(item: cancelButton, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: configuration.cancelButtonMarginLeft),
            NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: configuration.buttonWidth),
            NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: configuration.buttonHeight),
            
            NSLayoutConstraint(item: resetButton, attribute: .top, relatedBy: .equal, toItem: separatorView, attribute: .bottom, multiplier: 1, constant: configuration.separatorLineSpacingBottom),
            NSLayoutConstraint(item: resetButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: resetButton, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: configuration.buttonWidth),
            NSLayoutConstraint(item: resetButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: configuration.buttonHeight),
            
            NSLayoutConstraint(item: submitButton, attribute: .top, relatedBy: .equal, toItem: separatorView, attribute: .bottom, multiplier: 1, constant: configuration.separatorLineSpacingBottom),
            NSLayoutConstraint(item: submitButton, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -configuration.submitButtonMarginRight),
            NSLayoutConstraint(item: submitButton, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: configuration.buttonWidth),
            NSLayoutConstraint(item: submitButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: configuration.buttonHeight),

            NSLayoutConstraint(item: rotateButton, attribute: .bottom, relatedBy: .equal, toItem: separatorView, attribute: .top, multiplier: 1, constant: -configuration.separatorLineSpacingTop),
            NSLayoutConstraint(item: rotateButton, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: configuration.rotateButtonMarginLeft),
            NSLayoutConstraint(item: rotateButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: configuration.buttonWidth),
            NSLayoutConstraint(item: rotateButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: configuration.buttonHeight),
        ]
        
        if (!configuration.guideLabelTitle.isEmpty) {
            let guideLabel = UILabel()
            guideLabel.text = configuration.guideLabelTitle
            guideLabel.font = configuration.guideLabelTextFont
            guideLabel.textColor = configuration.guideLabelTextColor
            
            guideLabel.sizeToFit()
            guideLabel.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(guideLabel)
            
            topLayoutConstraint = NSLayoutConstraint(item: guideLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
            
            layoutConstraintList.append(
                topLayoutConstraint!
            )
            layoutConstraintList.append(
                NSLayoutConstraint(item: guideLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            )
        }
        
        view.addConstraints(layoutConstraintList)

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
        rotateButton.isHidden = false
    }
    
    public override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            if let constraint = topLayoutConstraint {
                constraint.constant = configuration.guideLabelMarginTop + view.safeAreaInsets.top
            }
            bottomLayoutConstraint.constant = -(configuration.separatorLineMarginBottom + view.safeAreaInsets.bottom)
        }
        else {
            if let constraint = topLayoutConstraint {
                constraint.constant = configuration.guideLabelMarginTop
            }
            bottomLayoutConstraint.constant = -configuration.separatorLineMarginBottom
        }
        
        view.setNeedsLayout()
        
    }
    
}
