import UIKit
import UI
import CoreFoundationLib

final class BannerPressFXView: UIView {
    
    var action: (() -> Void)?
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = 16
        
        return stack
    }()
    
    private let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        return image
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.numberOfLines = 1
        
        return label
    }()
    
    private lazy var pressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = pressFXColor
        
        return view
    }()
    
    var pressFXColor: UIColor = .prominentGray {
        didSet {
            pressView.backgroundColor = pressFXColor
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        label.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: UIFont.santanderTextRegular(size: 18), textAlignment: .left))
        pressView.isHidden = true
        pressView.embedInto(container: self, insets: UIEdgeInsets(top: 2, left: 16, bottom: -2, right: -16))
        addSubview(containerStackView)
        containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 32).isActive = true
        containerStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 2).isActive = true
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(label)
        imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.1).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0).isActive = true
        self.setAccessibilityIdentifiers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pressView.isHidden = false
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pressView.isHidden = true
        action?()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pressView.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pressView.layer.cornerRadius = 4
    }
    
    func setTitle(_ title: LocalizedStylableText) {
        label.set(localizedStylableText: title)
    }
    
    func setIcon(_ iconKey: String?, withColor color: UIColor = .botonRedLight) {
        guard let iconKey = iconKey else {
            return
        }
        imageView.image = Assets.image(named: iconKey)?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = color
    }
    
    func setAccessibilityIdentifiers() {
        self.imageView.isAccessibilityElement = true
        self.imageView.accessibilityIdentifier = AccessibilitySideMenu.icnHelpUsSideBar
        self.label.accessibilityIdentifier = AccessibilitySideMenu.helpUsImproveLabel
    }
}
