import UIKit
import UI
import CoreFoundationLib

class UserNameView: ResponsiveView {
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        stack.spacing = 0
        
        return stack
    }()
    
    private let subtitleStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .center
        stack.spacing = 6
        
        return stack
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        
        return label
    }()
    
    private var icon: UIImageView = {
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.contentMode = .center
        icon.setContentHuggingPriority(.required, for: .horizontal)
        
        return icon
    }()
    
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViews()
    }
    
    private func setupViews() {
        titleLabel.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: UIFont.santanderHeadlineRegular(size: 19), textAlignment: .left))
        subtitleLabel.applyStyle(LabelStylist(textColor: .lisboaGrayNew, font: UIFont.santanderTextLight(size: 15), textAlignment: .left))
        containerStackView.embedInto(container: self)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(subtitleStackView)
        subtitleStackView.addArrangedSubview(icon)
        subtitleStackView.addArrangedSubview(subtitleLabel)
        self.setAccessibilityIdentifiers()
    }
    
    func setIconImageKey(_ key: String) {
        icon.image = Assets.image(named: key)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setSubTitle(_ subtitle: LocalizedStylableText?) {
        subtitleLabel.set(localizedStylableText: subtitle ?? .empty)
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilitySideMenu.usernameTitleLabel
        self.subtitleLabel.accessibilityIdentifier = AccessibilitySideMenu.usernameSubtitleLabel
    }
}
