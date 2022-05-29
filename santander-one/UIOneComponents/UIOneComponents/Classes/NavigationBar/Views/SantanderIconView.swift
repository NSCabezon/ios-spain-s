import CoreFoundationLib
import UIKit
import UI

struct SantanderIconViewModel {
    let style: OneNavigationBarStyle
    let logo: OneNavigationBarSantanderLogo
    let action: (() -> Void)?
}

final class SantanderIconView: UIView {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        return imageView
    }()
    
    private var action: (() -> Void)?
    
    init(model: SantanderIconViewModel) {
        super.init(frame: .zero)
        self.commonInit()
        self.set(info: model)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
}

private extension SantanderIconView {
    @objc func performAction() {
        self.action?()
    }
    
    func set(info: SantanderIconViewModel) {
        self.imageView.image = Assets.image(named: info.logo.getImageKey(style: info.style))
        self.action = info.action
    }
    
    func commonInit() {
        self.imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.performAction))
        gestureRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(gestureRecognizer)
        self.isAccessibilityElement = true
        self.imageView.isAccessibilityElement = false
        self.accessibilityTraits = .button
        self.imageView.accessibilityIdentifier = AccessibilityOneComponents.oneLogoSantander
    }
}
