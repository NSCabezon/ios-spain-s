import UIKit
import CoreFoundationLib
import OpenCombine
import CoreDomain
import UI

protocol PrivateMenuOption {
    var title: LocalizedStylableText { get }
    var iconKey: String? { get }
    var imageURL: String? { get set }
    var action: () -> Void { get }
    var didUpdateImageURL: ((String) -> Void)? { get set }
}

class MenuOptionData: PrivateMenuOption, AccessibilityProtocol {
    var title: LocalizedStylableText
    var iconKey: String?
    var imageURL: String? {
        didSet {
            if let imageURL = imageURL {
                didUpdateImageURL?(imageURL)
            }
        }
    }
    var action: () -> Void
    var didUpdateImageURL: ((String) -> Void)?
    var accessibilityIdentifier: String?
    
    init(title: LocalizedStylableText, iconKey: String?, imageURL: String? = nil, accessibilityIdentifier: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.iconKey = iconKey
        self.imageURL = imageURL
        self.action = action
        self.accessibilityIdentifier = accessibilityIdentifier
    }
}

class PrivateUserHeader: UIView {
    private enum Constants {
        static let initialPercentage = 0.0
        static let exitOptionWidth: CGFloat = 56.0
        static let exitOptionHeight: CGFloat = 75.0
        static let closeButtonSize: CGFloat = 24
        static let separatorHeight: CGFloat = 1.0
        static let containerBottomAnchor: CGFloat = 4.0
        static let containerRightAnchor: CGFloat = 15.0
        static let closeIcn: String = "icnCloseMenu"
    }
    
    let isDigitalProfileEnabledSubject = PassthroughSubject<Bool, Never>()
    let digitalProfilePercentageSubject = PassthroughSubject<Double, Never>()
    let nameOrAliasSubject = PassthroughSubject<NameRepresentable, Never>()
    let avatarImageSubject = PassthroughSubject<Data, Never>()
    private var anySubscriptions = Set<AnyCancellable>()
    private lazy var avatarView: UserAvatarView = {
        let view = UserAvatarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = AccessibilitySideMenu.btnPhoto
        return view
    }()
    private let exitOption = PrivateMenuHeaderOption(
        titleKey: "menu_link_exit",
        imageName: "icnExit",
        accessibilityIdentifier: AccessibilitySideMenu.btnExit
    )
    
    let tapPersonalAreaSubject = PassthroughSubject<Void, Never>()
    let tapCloseMenuButtonSubject = PassthroughSubject<Void, Never>()
    let tapLogOutSubject = PassthroughSubject<PrivateMenuHeaderOption, Never>()
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = .zero
        return stack
    }()
    
    private let exitStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = .zero
        stack.setContentHuggingPriority(.required, for: .horizontal)
        return stack
    }()
    
    private lazy var leftView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()
    
    private lazy var userInfoView: MiddleOptionsView = {
        let view = MiddleOptionsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var exitOptionView: HeaderFXView = {
        let view = HeaderFXView()
        view.optionSubject.send(exitOption)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isAccessibilityElement = true
        view.accessibilityIdentifier = exitOption.accessibilityIdentifier
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Assets.image(named: Constants.closeIcn), for: .normal)
        button.addTarget(self,
                         action: #selector(handleTapClose),
                         for: .touchUpInside)
        button.accessibilityIdentifier = AccessibilitySideMenu.closeBtn
        return button
    }()
    
    private var hasTopNotch: Bool {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
    
    private lazy var leftViewTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self.leftView,
                                         action: #selector(handleTapPersonalArea(_:)))
        return tap
    }()
    
    private lazy var userInfoViewTapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self.userInfoView,
                                         action: #selector(handleTapPersonalArea(_:)))
        return tap
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
        addSubview(containerStackView)
        addSubview(separatorView)
        separatorView.backgroundColor = .mediumSky
        containerStackView.addArrangedSubview(leftView)
        containerStackView.addArrangedSubview(userInfoView)
        exitStackView.addArrangedSubview(closeButton)
        exitStackView.addArrangedSubview(exitOptionView)
        containerStackView.addArrangedSubview(exitStackView)
        setupConstraints()
        bindAndSubscribeViews()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            exitOptionView.widthAnchor.constraint(equalToConstant: Constants.exitOptionWidth),
            exitOptionView.heightAnchor.constraint(equalToConstant: Constants.exitOptionHeight),
            exitStackView.widthAnchor.constraint(equalToConstant: Constants.exitOptionWidth),
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            separatorView.heightAnchor.constraint(equalToConstant: Constants.separatorHeight),
            separatorView.leftAnchor.constraint(equalTo: leftAnchor),
            separatorView.rightAnchor.constraint(equalTo: rightAnchor),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerStackView.bottomAnchor.constraint(
                equalTo: separatorView.topAnchor,
                constant: -Constants.containerBottomAnchor),
            containerStackView.leftAnchor.constraint(equalTo: leftAnchor),
            containerStackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -Constants.containerRightAnchor),
        ])
        if #available(iOS 11.0, *) {
            containerStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            containerStackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        }
    }
    
    func setLeftView() {
        for view in leftView.subviews {
            view.removeFromSuperview()
        }
        self.avatarView.embedInto(container: leftView)
    }
    
    func hideDigitalProfileView(isHidden: Bool) {
        userInfoView.hideDigitalProfile(isHidden: isHidden)
    }
}

private extension PrivateUserHeader {
    @objc func handleTapPersonalArea(_ sender: UITapGestureRecognizer) {
        tapPersonalAreaSubject.send()
    }
    
    @objc func handleTapClose() {
        tapCloseMenuButtonSubject.send()
    }
}

private extension PrivateUserHeader {
    func bindAndSubscribeViews() {
        bindDigitalProfilePercentage()
        bindNameOrAlias()
        bindAvatarImage()
        subscribeToAvatarView()
        subscribeToUserInfoView()
        subscribeToExitOptionView()
    }
    
    func bindDigitalProfilePercentage() {
        isDigitalProfileEnabledSubject
            .sink { [unowned self] isEnabled in
                userInfoView.isDigitalProfileEnabledSubject.send(isEnabled)
            }.store(in: &anySubscriptions)
        
        digitalProfilePercentageSubject
            .sink { [unowned self] percentage in
                userInfoView.percentageSubject.send(percentage)
            }.store(in: &anySubscriptions)
    }
    
    func bindNameOrAlias() {
        nameOrAliasSubject
            .sink { [unowned self] name in
                userInfoView.nameSubject.send(name)
                avatarView.nameSubject.send(name)
            }.store(in: &anySubscriptions)
    }
    
    func bindAvatarImage() {
        avatarImageSubject
            .receive(on: Schedulers.main)
            .sink { [unowned self] image in
                avatarView.avatarImageSubject.send(image)
            }.store(in: &anySubscriptions)
    }
    
    func subscribeToAvatarView() {
        avatarView.tapSubject
            .sink { [unowned self] _ in
                self.tapPersonalAreaSubject.send()
            }
            .store(in: &anySubscriptions)
    }
    
    func subscribeToUserInfoView() {
        userInfoView.tapSubject
            .sink { [unowned self] _ in
                self.tapPersonalAreaSubject.send()
            }
            .store(in: &anySubscriptions)
    }
    func subscribeToExitOptionView() {
        exitOptionView.optionSubject
            .sink { [unowned self] option in
                self.tapLogOutSubject.send(option)
            }
            .store(in: &anySubscriptions)
    }
}
