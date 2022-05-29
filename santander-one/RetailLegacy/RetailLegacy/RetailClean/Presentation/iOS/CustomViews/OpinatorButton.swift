import UIKit
import UI
import CoreFoundationLib

@IBDesignable
class OpinatorButton: UIButton {
    var onTouchAction: ((_ sender: OpinatorButton) -> Void)?
    
    var opinatorButtonTitle: LocalizedStylableText? {
        didSet {
            if let title = opinatorButtonTitle {
                set(localizedStylableText: title, state: .normal)
                accessibilityIdentifier = "opinatorBtnLabelTitle"
            } else {
                setTitle(nil, for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        build()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        build()
    }
    
    private func build() {
        addTarget(self, action: #selector(didTouch(sender:)), for: .touchUpInside)
    }
    
    func update(imageName: String, title: LocalizedStylableText) {
        set(localizedStylableText: title, state: .normal)
        setImage(Assets.image(named: imageName), for: .normal)
        setNeedsDisplay()
        DispatchQueue.main.async {
            self.placeTitleAndImage()
        }
    }
    
    func setup(buttonStylist: ButtonStylist) {
        setImage(Assets.image(named: "icnLikeRetail"), for: .normal)
        tintColor = .sanRed
        (self as UIButton).applyStyle(buttonStylist)
        drawRoundedAndShadowed()
        setNeedsDisplay()
        DispatchQueue.main.async {
            self.placeTitleAndImage()
        }
        isExclusiveTouch = true
    }
    
    func setAccessibilityIdentifiers(titleIdentifier: String? = nil, imageIdentifier: String? = nil) {
        imageView?.isAccessibilityElement = true
        self.setAccessibility { self.imageView?.isAccessibilityElement = false }
        imageView?.accessibilityIdentifier = imageIdentifier
        titleLabel?.accessibilityIdentifier = titleIdentifier
    }
        
    @objc
    internal func didTouch(sender: OpinatorButton) {
        onTouchAction?(self)
    }
    
    func placeTitleAndImage() {
        guard let image = imageView, let title = titleLabel else {
            return
        }
        let contentOrigin = min(title.frame.origin.x, image.frame.origin.x)
        let contentEnd = max(title.frame.maxX, image.frame.maxX)
        let content = contentEnd - contentOrigin
        let outerSpace = bounds.width - content
        imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: outerSpace - image.frame.width)
        titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: image.frame.width)
    }
}

extension OpinatorButton: AccessibilityCapable { }
