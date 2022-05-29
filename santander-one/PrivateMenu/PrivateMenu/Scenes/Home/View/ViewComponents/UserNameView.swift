import UIKit
import UI
import CoreFoundationLib
import OpenCombine
import CoreDomain

class UserNameView: ResponsiveView {
    private var anySubscriptions = Set<AnyCancellable>()
    let subject = PassthroughSubject<NameRepresentable, Never>()
    
    private lazy var containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        stack.spacing = 0
        
        return stack
    }()
    
    private lazy var subtitleStackView: UIStackView = {
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
        let titleFont = UIFont(name: "SantanderHeadline-Regular", size: 19)
        let subtitleFont = UIFont(name: "SantanderText-Light", size: 15)
        titleLabel.font = titleFont
        titleLabel.textColor = .lisboaGray
        titleLabel.textAlignment = .left
        subtitleLabel.font = subtitleFont
        subtitleLabel.textColor = .lisboaGray
        subtitleLabel.textAlignment = .left
        containerStackView.embedInto(container: self)
        containerStackView.addArrangedSubview(titleLabel)
        containerStackView.addArrangedSubview(subtitleStackView)
        subtitleStackView.addArrangedSubview(icon)
        subtitleStackView.addArrangedSubview(subtitleLabel)
        self.setAccessibilityIdentifiers()
        bind()
    }
    
    func setIconImageKey(_ key: String) {
        icon.image = Assets.image(named: key)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title.capitalized
    }
    
    func setSubTitle(_ subtitle: LocalizedStylableText?) {
        subtitleLabel.configureText(withLocalizedString: subtitle ?? .empty)
    }
    
    func setSubtitleWithKey(_ subtitleKey: String) {
        subtitleLabel.configureText(withKey: subtitleKey)
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilitySideMenu.usernameTitleLabel
        self.subtitleLabel.accessibilityIdentifier = AccessibilitySideMenu.usernameSubtitleLabel
    }
    
    func bind() {
        subject
            .sink { [unowned self] name in
                setTitle(name.availableName ?? "")
            }.store(in: &anySubscriptions)
    }
}
