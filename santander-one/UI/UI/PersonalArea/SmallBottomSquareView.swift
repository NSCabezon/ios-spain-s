import Foundation
import CoreFoundationLib

public final class SmallBottomSquareView: UIView {
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
        titleLabel.textColor = .lisboaGray
        titleLabel.font = .santander(family: .text, type: .light, size: 20.0)
        titleLabel.configureText(withKey: viewModel.title, andConfiguration: LocalizedStylableTextConfiguration(lineHeightMultiple: 0.85))
        self.iconImage.image = Assets.image(named: viewModel.icon)

        setAccessibilityIdentifiers(from: viewModel)
    }
    
    public func setAccessibilityIdentifiers(container: String? = nil, button: String? = nil) {
        self.accessibilityIdentifier = container
        self.buttonBottom.accessibilityIdentifier = button
    }
}

private extension SmallBottomSquareView {
    @objc func didTapOnButton() {
        self.action?()
    }
    
    func setupView() {
        self.backgroundColor = .white
        self.drawRoundedAndShadowedNew(radius: 4, borderColor: .mediumSkyGray, widthOffSet: 1, heightOffSet: 2)
        self.iconImage.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        self.iconImage.widthAnchor.constraint(equalToConstant: 36.0).isActive = true
        self.iconImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 15.0).isActive = true
        self.iconImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10.0).isActive = true
        self.titleLabel.leadingAnchor.constraint(equalTo: self.iconImage.trailingAnchor, constant: 4.0).isActive = true
        self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8.0).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 17.0).isActive = true
        self.buttonBottom.fullFit()
    }

    func setAccessibilityIdentifiers(from viewModel: SecurityViewModel) {
        self.titleLabel.accessibilityIdentifier = viewModel.title
        self.iconImage.accessibilityIdentifier = viewModel.icon
    }
}
