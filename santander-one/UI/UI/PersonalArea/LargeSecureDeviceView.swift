import Foundation
import CoreFoundationLib

public final class LargeSecureDeviceView: UIView {
    private lazy var iconImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        return view
    }()
    private lazy var buttonBottom: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addTarget(self, action: #selector(self.didTapOnButton), for: .touchUpInside)
        self.addSubview(view)
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        self.addSubview(view)
        return view
    }()
    private lazy var subtitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        self.addSubview(view)
        return view
    }()
    public var action: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public func setViewModel(_ viewModel: SecurityViewModel) {
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(family: .text, type: .light, size: 20.0)
        self.titleLabel.configureText(withKey: viewModel.title, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        self.subtitleLabel.textColor = .mediumSanGray
        self.subtitleLabel.font = .santander(family: .text, type: .regular, size: 14.0)
        self.subtitleLabel.configureText(withKey: viewModel.subtitle, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.75))
        self.iconImage.image = Assets.image(named: viewModel.icon)
    }
    
    public func setAccessibilityIdentifiers(container: String? = nil, button: String? = nil) {
        self.accessibilityIdentifier = container
        self.buttonBottom.accessibilityIdentifier = button
    }
}

private extension LargeSecureDeviceView {
    @objc func didTapOnButton() {
        self.action?()
    }
    
    func setupView() {
        self.backgroundColor = .white
        self.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
        self.iconImage.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        self.iconImage.widthAnchor.constraint(equalToConstant: 48.0).isActive = true
        self.iconImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 17.0).isActive = true
        self.iconImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0).isActive = true
        self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImage.trailingAnchor, constant: 16.0).isActive = true
        self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.0).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16.0).isActive = true
        self.subtitleLabel.leadingAnchor.constraint(equalTo: self.iconImage.trailingAnchor, constant: 16.0).isActive = true
        self.subtitleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20.0).isActive = true
        self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 2.0).isActive = true
        self.buttonBottom.fullFit()
    }
}
