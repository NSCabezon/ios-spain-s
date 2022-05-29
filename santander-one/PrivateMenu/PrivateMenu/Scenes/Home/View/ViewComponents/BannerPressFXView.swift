import UIKit
import UI
import CoreFoundationLib
import CoreDomain

final class BannerPressFXView: UIView {
    private enum Constants {
        static let stackSpacing: CGFloat = 15
        static let labelNumberOfLines: Int = 1
        static let pressViewInsets = UIEdgeInsets(top: 2, left: 16, bottom: -2, right: -16)
        static let containerLeftConstraint: CGFloat = 32
        static let containerTopConstraing: CGFloat = 2
        static let imageSize: CGFloat = 26
        static let pressViewCornerRadius: CGFloat = 4
        static let labelFontSize: CGFloat = 18
        static let labelLineHeightMultiple: CGFloat = 1
    }

    var action: (() -> Void)?
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = Constants.stackSpacing
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
        label.numberOfLines = Constants.labelNumberOfLines
        label.textColor = .lisboaGray
        return label
    }()
    
    private lazy var pressView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = pressFXColor
        
        return view
    }()
    
    var pressFXColor: UIColor = .prominentSanGray {
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
        pressView.isHidden = true
        pressView.embedInto(container: self, insets: Constants.pressViewInsets)
        addSubview(containerStackView)
        containerStackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        containerStackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        containerStackView.leftAnchor.constraint(equalTo: leftAnchor,
                                                 constant: Constants.containerLeftConstraint).isActive = true
        containerStackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor,
                                                constant: Constants.containerTopConstraing).isActive = true
        containerStackView.addArrangedSubview(imageView)
        containerStackView.addArrangedSubview(label)
        imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize).isActive = true
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
        pressView.layer.cornerRadius = Constants.pressViewCornerRadius
    }
    
    func setTitleWithKey(_ titleKey: String) {
        let font = UIFont.santander(family: .text, type: .regular, size: Constants.labelFontSize)
        let configuration = LocalizedStylableTextConfiguration(font: font,
                                                               alignment: .left,
                                                               lineHeightMultiple: Constants.labelLineHeightMultiple,
                                                               lineBreakMode: .byWordWrapping)
        label.configureText(withKey: titleKey, andConfiguration: configuration)
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
