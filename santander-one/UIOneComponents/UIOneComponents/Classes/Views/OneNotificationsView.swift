//
//  OneNotificationsView.swift
//  UIOneComponents
//
//  Created by Jose Javier Montes Romero on 4/3/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine

public enum OneNotificationType {
    case textOnly(stringKey: String)
    case stylableTextOnly(withLocalizedString: LocalizedStylableText)
    case textAndLink(stringKey: String, linkKey: String, linkIsEnabled: Bool)
    case stylableTextAndLink(withLocalizedString: LocalizedStylableText, linkKey: String, linkIsEnabled: Bool)
    case textAndHelp(stringKey: String)
    case stylableTextAndHelp(withLocalizedString: LocalizedStylableText)
    case textHelpAndLink(stringKey: String, linkKey: String, linkIsEnabled: Bool)
    case stylableTextHelpAndLink(withLocalizedString: LocalizedStylableText, linkKey: String, linkIsEnabled: Bool)
    case textAndToggle(stringKey: String, toggleValue: Bool, toggleIsEnabled: Bool)
    case stylableTextAndToggle(withLocalizedString: LocalizedStylableText, toggleValue: Bool, toggleIsEnabled: Bool)
}

public protocol OneNotificationRepresentable {
    var type: OneNotificationType { get }
    var defaultColor: UIColor { get }
    var inactiveColor: UIColor? { get }
}

public enum OneNotificationState: State {
    case didTappedLink
    case didTappedIcnHelp
    case didChangeToggle(Bool)
}

private extension OneNotificationsView {}

final public class OneNotificationsView: XibView {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var icnButton: UIButton!
    @IBOutlet private weak var linkButton: UIButton!
    @IBOutlet private weak var linkLabel: UILabel!
    @IBOutlet private weak var toggleView: OneToggleView!
    @IBOutlet private weak var textToHelpConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textToLinkConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textToToggleConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textToSuperViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var helpToSuperViewConstraint: NSLayoutConstraint!
    @IBOutlet private weak var helpToLinkConstraint: NSLayoutConstraint!
    private var subscriptions = Set<AnyCancellable>()
    private var subject = PassthroughSubject<OneNotificationState, Never>()
    public lazy var publisher: AnyPublisher<OneNotificationState, Never> = {
        return subject.eraseToAnyPublisher()
    }()
    private var model: OneNotificationRepresentable?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        bind()
    }
    
    public func setNotificationView(with notificationModel: OneNotificationRepresentable) {
        self.model = notificationModel
        self.setupContainer(with: notificationModel.defaultColor)
        switch notificationModel.type {
        case .textOnly(let stringKey):
            self.configureTextOnlyWith(stringKey)
        case .stylableTextOnly(let localizedString):
            self.configureTextOnlyWith(localizedString: localizedString)
        case .textAndLink(let stringKey, let linkKey, let linkIsEnabled):
            self.configureText(stringKey, andLink: linkKey, linkIsEnabled: linkIsEnabled)
        case .stylableTextAndLink(let localizedString, let linkKey, let linkIsEnabled):
            self.configureText(localizedString: localizedString, andLink: linkKey, linkIsEnabled: linkIsEnabled)
        case .textAndHelp(let stringKey):
            self.configureTextAndHelp(stringKey: stringKey)
        case .stylableTextAndHelp(let localizedString):
            self.configureTextAndHelp(localizedString: localizedString)
        case .textHelpAndLink(let stringKey, let linkKey, let linkIsEnabled):
            self.configureTextHelpAndLink(stringKey: stringKey, andLink: linkKey, linkIsEnabled: linkIsEnabled)
        case .stylableTextHelpAndLink(let localizedString, let linkKey, let linkIsEnabled):
            self.configureTextHelpAndLink(localizedString: localizedString, andLink: linkKey, linkIsEnabled: linkIsEnabled)
        case .textAndToggle(let stringKey, let toggleValue, let toggleIsEnabled):
            self.configureTextAndToggle(stringKey: stringKey, toggleValue: toggleValue, toggleIsEnabled: toggleIsEnabled)
            self.bindToggleView()
        case .stylableTextAndToggle(let localizedString, let toggleValue, let toggleIsEnabled):
            self.configureTextAndToggle(localizedString: localizedString, toggleValue: toggleValue, toggleIsEnabled: toggleIsEnabled)
            self.bindToggleView()
        }
    }
    
    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
    
    @IBAction private func didTappedIcnHelpButton(_ sender: Any) {
        self.subject.send(.didTappedIcnHelp)
    }
    
    @IBAction private func didTappedLinkButton(_ sender: Any) {
        self.subject.send(.didTappedLink)
    }
    
    public func setLinkIsEnabled(_ isEnabled: Bool) {
        self.configureLink(isEnable: isEnabled)
    }
    
    public func setToggleViewStatus(isOn: Bool, isEnabled: Bool) {
        guard let type = self.model?.type else { return }
        switch type {
        case .textAndToggle(let stringKey, _, _):
            self.configureTextAndToggle(stringKey: stringKey, toggleValue: isOn, toggleIsEnabled: isEnabled)
        case .stylableTextAndToggle(let stylableText, _, _):
            self.configureTextAndToggle(localizedString: stylableText, toggleValue: isOn, toggleIsEnabled: isEnabled)
        default:
            return
        }
    }
}

private extension OneNotificationsView {
    func bind() {}
    
    func setupView() {
        self.titleLabel.font = .typography(fontName: .oneB300Regular)
        self.titleLabel.textColor = .oneLisboaGray
        self.icnButton.setImage(Assets.image(named: "oneIcnHelp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        self.linkLabel.font = .typography(fontName: .oneB300Bold)
        self.linkLabel.textColor = .oneDarkTurquoise
        self.toggleView.oneSize = .small
        self.containerView.setOneCornerRadius(type: .oneShRadius4)
        self.setAccessibilityIdentifiers()
        self.setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func setupContainer(with backgroundColor: UIColor) {
        self.containerView.backgroundColor = backgroundColor
    }
    
    func configureTextOnlyWith(_ stringKey: String) {
        self.icnButton.isHidden = true
        self.linkButton.isHidden = true
        self.linkLabel.isHidden = true
        self.toggleView.isHidden = true
        self.textToHelpConstraint.isActive = false
        self.textToSuperViewConstraint.isActive = true
        self.titleLabel.configureText(withKey: stringKey)
        self.layoutIfNeeded()
    }
    
    func configureTextOnlyWith(localizedString: LocalizedStylableText) {
        self.icnButton.isHidden = true
        self.linkButton.isHidden = true
        self.linkLabel.isHidden = true
        self.toggleView.isHidden = true
        self.textToHelpConstraint.isActive = false
        self.textToSuperViewConstraint.isActive = true
        self.titleLabel.configureText(withLocalizedString: localizedString)
        self.layoutIfNeeded()
    }
    
    func configureText(_ stringKey: String, andLink linkKey: String, linkIsEnabled: Bool) {
        self.icnButton.isHidden = true
        self.toggleView.isHidden = true
        self.textToHelpConstraint.isActive = false
        self.textToLinkConstraint.isActive = true
        self.titleLabel.configureText(withKey: stringKey)
        self.linkLabel.text = localized(linkKey)
        self.configureLink(isEnable: linkIsEnabled)
        self.layoutIfNeeded()
    }
    
    func configureText(localizedString: LocalizedStylableText, andLink linkKey: String, linkIsEnabled: Bool) {
        self.icnButton.isHidden = true
        self.toggleView.isHidden = true
        self.textToHelpConstraint.isActive = false
        self.textToLinkConstraint.isActive = true
        self.titleLabel.configureText(withLocalizedString: localizedString)
        self.linkLabel.text = localized(linkKey)
        self.configureLink(isEnable: linkIsEnabled)
        self.layoutIfNeeded()
    }
    
    func configureTextAndHelp(stringKey: String) {
        self.linkButton.isHidden = true
        self.linkLabel.isHidden = true
        self.toggleView.isHidden = true
        self.helpToLinkConstraint.isActive = false
        self.helpToSuperViewConstraint.isActive = true
        self.titleLabel.configureText(withKey: stringKey)
        self.layoutSubviews()
    }
    
    func configureTextAndHelp(localizedString: LocalizedStylableText) {
        self.linkButton.isHidden = true
        self.linkLabel.isHidden = true
        self.toggleView.isHidden = true
        self.helpToLinkConstraint.isActive = false
        self.helpToSuperViewConstraint.isActive = true
        self.titleLabel.configureText(withLocalizedString: localizedString)
        self.layoutSubviews()
    }
    
    func configureTextHelpAndLink(stringKey: String, andLink linkKey: String, linkIsEnabled: Bool) {
        self.toggleView.isHidden = true
        self.titleLabel.configureText(withKey: stringKey)
        self.linkLabel.text = localized(linkKey)
        self.configureLink(isEnable: linkIsEnabled)
    }
    
    func configureTextHelpAndLink(localizedString: LocalizedStylableText, andLink linkKey: String, linkIsEnabled: Bool) {
        self.toggleView.isHidden = true
        self.titleLabel.configureText(withLocalizedString: localizedString)
        self.linkLabel.text = localized(linkKey)
        self.configureLink(isEnable: linkIsEnabled)
    }
    
    func configureTextAndToggle(stringKey: String, toggleValue: Bool, toggleIsEnabled: Bool) {
        self.icnButton.isHidden = true
        self.linkButton.isHidden = true
        self.linkLabel.isHidden = true
        self.textToHelpConstraint.isActive = false
        self.textToToggleConstraint.isActive = true
        self.titleLabel.configureText(withKey: stringKey)
        self.toggleView.isOn = toggleValue
        self.toggleView.isEnabled = toggleIsEnabled
        configureBackgroudByToggle(toggleValue: toggleValue, toggleIsEnabled: toggleIsEnabled)
        self.layoutIfNeeded()
    }
    
    func configureTextAndToggle(localizedString: LocalizedStylableText, toggleValue: Bool, toggleIsEnabled: Bool) {
        self.icnButton.isHidden = true
        self.linkButton.isHidden = true
        self.linkLabel.isHidden = true
        self.textToHelpConstraint.isActive = false
        self.textToToggleConstraint.isActive = true
        self.titleLabel.configureText(withLocalizedString: localizedString)
        self.toggleView.isOn = toggleValue
        self.toggleView.isEnabled = toggleIsEnabled
        configureBackgroudByToggle(toggleValue: toggleValue, toggleIsEnabled: toggleIsEnabled)
        self.layoutIfNeeded()
    }
    
    func configureBackgroudByToggle(toggleValue: Bool, toggleIsEnabled: Bool) {
        guard let defaultColor = self.model?.defaultColor, let inactiveColor = self.model?.inactiveColor else { return }
        if toggleValue && toggleIsEnabled {
            self.setupContainer(with: defaultColor)
        } else {
            self.setupContainer(with: inactiveColor)
        }
    }
    
    func bindToggleView() {
        self.toggleView
            .publisher
            .sink { [unowned self] isOn in
                configureBackgroudByToggle(toggleValue: isOn, toggleIsEnabled: self.toggleView.isEnabled)
                self.subject.send(.didChangeToggle(isOn))
            }.store(in: &subscriptions)
    }
    
    func configureLink(isEnable: Bool) {
        self.linkLabel.textColor = isEnable ? .oneDarkTurquoise : .oneBrownGray
        self.linkButton.isEnabled = isEnable
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.containerView?.accessibilityIdentifier = AccessibilityOneComponents.oneNotificationView + (suffix ?? "")
        self.titleLabel?.accessibilityIdentifier = AccessibilityOneComponents.oneNotificationLabel + (suffix ?? "")
        self.icnButton?.accessibilityIdentifier = AccessibilityOneComponents.oneNotificationHelpIcn + (suffix ?? "")
        self.linkLabel?.accessibilityIdentifier = AccessibilityOneComponents.oneNotificationLink + (suffix ?? "")
        self.toggleView?.setAccessibilitySuffix(suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.linkButton.accessibilityLabel = (self.linkLabel.text ?? "")
        self.linkLabel.isAccessibilityElement = false
    }
}

extension OneNotificationsView: AccessibilityCapable {}
