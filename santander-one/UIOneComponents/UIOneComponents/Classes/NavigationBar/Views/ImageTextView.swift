import CoreFoundationLib
import UIKit
import UI

struct ImageTextViewModel {
    let style: OneNavigationBarStyle
    let imageKey: String
    let titleKey: String
    let accesibilityLabelKey: String
    let action: () -> Void
}

final class ImageTextView: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .typography(fontName: .oneB100Regular)
        label.textColor = .oneLisboaGray
        label.textAlignment = .center
        self.addSubview(label)
        return label
    }()
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.widthAnchor.constraint(equalToConstant: 24).isActive = true
        image.heightAnchor.constraint(equalToConstant: 24).isActive = true
        image.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(image)
        return image
    }()
    
    private var action: (() -> Void)?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.alpha = 0.5
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.4) {
            self.alpha = 1.0
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.4) {
            self.alpha = 1.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    init(_ info: ImageTextViewModel) {
        super.init(frame: .zero)
        self.commonInit()
        self.set(info: info)
        self.setAccessibilityIdentifiers(info)
        self.setAccessibilityInfo(info)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }
}

private extension ImageTextView {
    @objc func performAction() {
        self.action?()
    }
    
    func commonInit() {
        self.imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        self.imageView.bottomAnchor.constraint(equalTo: self.label.topAnchor).isActive = true
        self.label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: -12).isActive = true
        self.label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 12).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.performAction)))
        self.clipsToBounds = false
    }
    
    func set(info: ImageTextViewModel) {
        self.imageView.image = Assets.image(named: info.imageKey)?.withRenderingMode(.alwaysTemplate)
        self.label.configureText(withKey: info.titleKey)
        self.label.textColor = info.style.buttonTextColor
        self.imageView.tintColor = info.style.buttonImageTintColor
        self.action = info.action
        self.accessibilityLabel = localized(info.titleKey)
        self.accessibilityTraits = .button
    }
    
    func setAccessibilityIdentifiers(_ viewModel: ImageTextViewModel) {
        self.accessibilityIdentifier = viewModel.imageKey
        self.label.accessibilityIdentifier = "\(viewModel.imageKey)_label"
    }
    
    func setAccessibilityInfo(_ viewModel: ImageTextViewModel) {
        self.accessibilityLabel = localized(viewModel.accesibilityLabelKey)
        self.accessibilityTraits = .button
        self.label.isAccessibilityElement = false
        self.isAccessibilityElement = true
    }
}
