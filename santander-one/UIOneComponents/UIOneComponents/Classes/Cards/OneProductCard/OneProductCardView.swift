//
//  OneProductCardView.swift
//  UIOneComponents
//
//  Created by Jose Javier Montes Romero on 9/3/22.
//

import UI
import UIKit
import CoreFoundationLib
import OpenCombine
import CoreDomain

public protocol OneProductCardViewRepresentable {
    var title: String { get }
    var subTitle: String? { get }
    var defatultImageName: String? { get }
    var urlImage: String? { get }
    var logoSize: OneProductCardLogoHeight? { get }
    var moreActionsImageName: String? { get }
    var mainAmount: OneProductCardAmountRepresentable? { get }
    var extraAmounts: [OneProductCardAmountRepresentable]? { get }
    var infoExtra: LocalizedStylableText? { get }
    var firstNotification: OneNotificationRepresentable? { get }
    var secondNotification: OneNotificationRepresentable? { get }
    var thirdNotification: OneNotificationRepresentable? { get }
    var toggleNotification: OneNotificationRepresentable? { get }
    var cardStatus: OneProductCardStatus { get set }
    var borderStyle: OneProductCardBorderStyle { get }
    var mainBackgroundColor: UIColor { get }
    var secundaryBackgroundColor: UIColor? { get }
    var notificationTitleAccessibilityLabel: String? { get }
}

public protocol OneProductCardAmountRepresentable {
    var title: String { get }
    var amount: AmountRepresentable { get }
}

extension OneProductCardAmountRepresentable {
    
    var formattedAmount: NSAttributedString? {
        let primaryFont = UIFont.typography(fontName: .oneH300Regular)
        let decimalFont = UIFont.typography(fontName: .oneB400Regular)
        let decorator = AmountRepresentableDecorator(amount, font: primaryFont, decimalFont: decimalFont)
        return decorator.formattedCurrencyWithoutMillion
    }
}

public enum OneProductCardBorderStyle {
    case shadow
    case line
    case none
}

public enum OneProductCardStatus {
    case normal
    case selected
}

public enum OneProductCardLogoHeight: CGFloat {
    case small = 24
    case big = 35
}

public enum OneProductCardNotificationOption: String {
    case first
    case second
    case third
}

public enum OneProductCardState: State {
    case didTappedNotificationLink(orderNotification: OneProductCardNotificationOption)
    case didTappedNotificationIcnHelp(orderNotification: OneProductCardNotificationOption)
    case didChangeToggle(Bool)
    case didTappedMoreActionButton
}

final public class OneProductCardView: XibView {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var mainStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var logoImage: UIImageView!
    @IBOutlet private weak var logoHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var moreActionsButton: UIButton!
    @IBOutlet private weak var mainBalanceTitleLabel: UILabel!
    @IBOutlet private weak var mainBalanceAmountLabel: UILabel!
    @IBOutlet private weak var mainBalanceStackView: UIStackView!
    @IBOutlet private weak var infoAmountStackView: UIStackView!
    @IBOutlet private weak var infoExtraLabel: UILabel!
    @IBOutlet private weak var infoNotificationsStackView: UIStackView!
    @IBOutlet private weak var infoExtraStackView: UIStackView!
    @IBOutlet private weak var checkView: UIImageView!
    private var representable: OneProductCardViewRepresentable?
    private var subscriptions = Set<AnyCancellable>()
    private var subject = PassthroughSubject<OneProductCardState, Never>()
    public lazy var publisher: AnyPublisher<OneProductCardState, Never> = {
        return subject.eraseToAnyPublisher()
    }()
    private lazy var notificationToggleView = {
        OneNotificationsView()
    }()
    private var firstNotificationView: OneNotificationsView?
    private var secondNotificationView: OneNotificationsView?
    private var thirdNotificationView: OneNotificationsView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func setupProductCard(_ representable: OneProductCardViewRepresentable) {
        self.representable = representable
        self.configureView()
        self.setCardStatus(representable.cardStatus)
        self.configureTopView()
        self.configureAmountsView()
        self.configureInfoExtraLabel()
        self.configureNotificationsView()
        self.configureToggleNotificationView()
    }
    
    public func setStatus(_ status: OneProductCardStatus) {
        self.configureView()
        self.setCardStatus(status)
    }
    
    public func setToggleView(_ isOn: Bool, isEnabeld: Bool = true) {
        notificationToggleView.setToggleViewStatus(isOn: isOn, isEnabled: isEnabeld)
    }
    
    @IBAction private func moreActionButtonDidTapped(_ sender: Any) {
        self.subject.send(.didTappedMoreActionButton)
    }
    
    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
}

private extension OneProductCardView {
    
    func setupView() {
        configureLabels()
        self.checkView.image = Assets.image(named: "icnCheckOvalGreen")
        self.setAccessibilityIdentifiers()
        self.setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func configureView() {
        guard let model = representable else { return }
        self.containerView.setOneCornerRadius(type: .oneShRadius4)
        switch model.borderStyle {
        case .shadow:
            self.containerView.setOneShadows(type: .oneShadowLarge)
        case .line:
            self.containerView.drawBorder(cornerRadius: 4, color: .oneMediumSkyGray, width: 1.0)
        case .none:
            break
        }
    }
    
    func setCardStatus(_ status: OneProductCardStatus) {
        guard let model = representable else { return }
        switch status {
        case .normal:
            self.containerView.backgroundColor = model.mainBackgroundColor
            self.checkView.isHidden = true
        case .selected:
            self.containerView.backgroundColor = .turquoise.withAlphaComponent(0.07)
            self.checkView.isHidden = false
            self.clearContainerViewStyle()
        }
    }
    
    func configureViewWithToggleStatus(_ isOn: Bool) {
        guard let model = representable else { return }
        self.containerView.backgroundColor = isOn ? model.mainBackgroundColor : model.secundaryBackgroundColor
    }
    
    func clearContainerViewStyle() {
        self.containerView.layer.borderWidth = 0.0
        self.containerView.layer.shadowOpacity = 0.0
    }
    
    func configureLabels() {
        self.titleLabel.font = .typography(fontName: .oneH100Bold)
        self.titleLabel.textColor = .oneLisboaGray
        self.subtitleLabel.font = .typography(fontName: .oneB300Regular)
        self.subtitleLabel.textColor = .oneLisboaGray
        self.mainBalanceTitleLabel.font = .typography(fontName: .oneB300Regular)
        self.mainBalanceTitleLabel.textColor = .oneBrownishGray
        self.mainBalanceAmountLabel.font = .typography(fontName: .oneH300Regular)
        self.mainBalanceAmountLabel.textColor = .oneLisboaGray
        self.infoExtraLabel.font = .typography(fontName: .oneB300Regular)
        self.infoExtraLabel.textColor = .oneLisboaGray
    }
    
    func configureTopView() {
        guard let model = representable else { return }
        self.titleLabel.text = model.title
        if let subtitle = model.subTitle {
            self.subtitleLabel.text = subtitle
            self.subtitleLabel.isHidden = false
        }
        configureLogo()
        configureMoreActionButton()
    }
    
    func configureLogo() {
        guard let model = representable else { return }
        if let sizeImage = model.logoSize {
            self.logoHeightConstraint.constant = sizeImage.rawValue
        }
        if let defaultImageName = model.defatultImageName,
            let defaultImage = Assets.image(named: defaultImageName) {
            self.logoImage.image = defaultImage
            checkImageSize()
            self.logoImage.isHidden = false
        }
        if let urlImage = model.urlImage {
            self.logoImage.loadImage(urlString: urlImage,
                                     placeholder: Assets.image(named: model.defatultImageName ?? ""),
                                     completion: {
                self.checkImageSize()
            })
            self.logoImage.isHidden = false
        }
    }
    
    func checkImageSize() {
        if !self.logoImage.isRightAspectRatio() {
            guard let image = self.logoImage.image else { return }
            let ratio = image.size.width / image.size.height
            self.updateImageAspecRatio(ratio)
        }
    }
    
    func updateImageAspecRatio(_ ratio: CGFloat) {
        removeWidthContraint()
        self.logoImage.widthAnchor.constraint(equalTo: self.logoImage.heightAnchor, multiplier: ratio).isActive = true
    }
    
    private func removeWidthContraint() {
        self.logoImage.constraints.filter { $0.firstAnchor == self.logoImage.widthAnchor }.forEach { $0.isActive = false }
    }
    
    func configureMoreActionButton() {
        guard let imageName = representable?.moreActionsImageName, let image = Assets.image(named: imageName) else {
            self.moreActionsButton.isHidden = true
            return
        }
        self.moreActionsButton.setImage(image, for: .normal)
        self.moreActionsButton.isHidden = false
    }
    
    func configureAmountsView() {
        guard let model = representable, let mainAmount = model.mainAmount else {
            self.mainStackView.spacing = 12
            return
        }
        self.mainBalanceTitleLabel.text = mainAmount.title
        self.mainBalanceAmountLabel.attributedText = mainAmount.formattedAmount
        self.infoAmountStackView.isHidden = false
        self.infoExtraStackView.isHidden = false
        guard let amounts = model.extraAmounts else { return }
        amounts.enumerated().forEach { index, amountModel in
            let amountView = OneProductCardAmountView()
            amountView.setupProductCard(amountModel)
            amountView.setAccessibilitySuffix("\(index)")
            self.infoAmountStackView.addArrangedSubview(amountView)
        }
    }
    
    func configureInfoExtraLabel() {
        guard let infoExtraString = representable?.infoExtra else { return }
        self.infoExtraLabel.configureText(withLocalizedString: infoExtraString)
        self.infoExtraLabel.isHidden = false
        self.infoExtraStackView.isHidden = false
    }
    
    func configureNotificationsView() {
        guard let model = representable else { return }
        if let firstNotificationModel = model.firstNotification {
            self.addNotificationViewWithModel(firstNotificationModel, notificationOption: .first)
        }
        if let secondNotificationModel = model.secondNotification {
            self.addNotificationViewWithModel(secondNotificationModel, notificationOption: .second)
        }
        if let thirdNotificationModel = model.thirdNotification {
            self.addNotificationViewWithModel(thirdNotificationModel, notificationOption: .third)
        }
    }
    
    func addNotificationViewWithModel(_ model: OneNotificationRepresentable, notificationOption: OneProductCardNotificationOption) {
        let notificationView = OneNotificationsView()
        notificationView.setNotificationView(with: model)
        notificationView.setAccessibilitySuffix(notificationOption.rawValue)
        switch notificationOption {
        case .first:
            firstNotificationView = notificationView
            self.bindFirstNotification(notificationView)
        case .second:
            secondNotificationView = notificationView
            self.bindSecondNotification(notificationView)
        case .third:
            thirdNotificationView = notificationView
            self.bindThirdNotification(notificationView)
        }
        self.infoNotificationsStackView.addArrangedSubview(notificationView)
        self.infoExtraStackView.isHidden = false
    }
    
    func configureToggleNotificationView() {
        guard let toggeNotificationModel = representable?.toggleNotification else { return }
        notificationToggleView.setNotificationView(with: toggeNotificationModel)
        notificationToggleView.setAccessibilitySuffix("toggle")
        if case .textAndToggle(_, let toggleValue, let toggleIsEnabled) = toggeNotificationModel.type {
            self.configureViewWithToggleStatus(toggleValue && toggleIsEnabled)
        }
        self.bindNotificationToggle(notificationToggleView)
        self.infoExtraStackView.addArrangedSubview(notificationToggleView)
        self.infoExtraStackView.isHidden = false
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.containerView.accessibilityIdentifier = AccessibilityOneComponents.oneProductCardView + (suffix ?? "")
        self.titleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneProductCardTitleLabel + (suffix ?? "")
        self.subtitleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneProductCardSubtitleLabel + (suffix ?? "")
        self.logoImage.accessibilityIdentifier = AccessibilityOneComponents.oneProductCardLogoImage + (suffix ?? "")
        self.moreActionsButton.accessibilityIdentifier = AccessibilityOneComponents.oneProductCardMoreAction + (suffix ?? "")
        self.mainBalanceTitleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneProductCardMainBalanceTitleLabel + (suffix ?? "")
        self.mainBalanceAmountLabel.accessibilityIdentifier = AccessibilityOneComponents.oneProductCardMainBalanceAmountLabel + (suffix ?? "")
        self.infoExtraLabel.accessibilityIdentifier = AccessibilityOneComponents.oneProductCardExtraInfoLabel + (suffix ?? "")
        self.checkView.accessibilityIdentifier = AccessibilityOneComponents.oneProductCardCheckIcon + (suffix ?? "")
        if let firstNotificationView = firstNotificationView {
            firstNotificationView.setAccessibilitySuffix("\(OneProductCardNotificationOption.first.rawValue)_\(suffix ?? "")")
        }
        if let secondNotificationView = secondNotificationView {
            secondNotificationView.setAccessibilitySuffix("\(OneProductCardNotificationOption.second.rawValue)_\(suffix ?? "")")
        }
        if let thirdNotificationView = thirdNotificationView {
            thirdNotificationView.setAccessibilitySuffix("\(OneProductCardNotificationOption.third.rawValue)_\(suffix ?? "")")
        }
        notificationToggleView.setAccessibilitySuffix("toggle\(suffix ?? "")")
    }

    func setAccessibilityInfo() {
        self.titleLabel.isAccessibilityElement = false
        self.contentView.isAccessibilityElement = true
        self.contentView.accessibilityLabel = self.titleLabel.text ?? ""
        self.subtitleLabel.accessibilityLabel = (subtitleLabel.text?.replace("|", "") ?? "")
        self.moreActionsButton.accessibilityLabel = localized("voiceover_bankOptions")
        self.mainBalanceStackView.accessibilityElements = [self.mainBalanceTitleLabel, self.mainBalanceAmountLabel].compactMap {$0}
        guard let titleAccessibilityLabel = self.representable?.notificationTitleAccessibilityLabel else { return }
        self.infoExtraLabel.accessibilityLabel = titleAccessibilityLabel
    }
}

//MARK: Binding compoments
private extension OneProductCardView {
    func bindNotificationToggle(_ notificationToggleView: OneNotificationsView) {
        notificationToggleView
            .publisher
            .case(OneNotificationState.didChangeToggle)
            .sink { [unowned self] isOn in
                self.configureViewWithToggleStatus(isOn)
                self.subject.send(.didChangeToggle(isOn))
            }.store(in: &subscriptions)
    }
    
    func bindFirstNotification(_ notificationView: OneNotificationsView) {
        notificationView
            .publisher
            .case(OneNotificationState.didTappedLink)
            .sink { [unowned self] _ in
                self.subject.send(.didTappedNotificationLink(orderNotification: .first))
            }.store(in: &subscriptions)
        
        notificationView
            .publisher
            .case(OneNotificationState.didTappedIcnHelp)
            .sink { [unowned self] _ in
                self.subject.send(.didTappedNotificationIcnHelp(orderNotification: .first))
            }.store(in: &subscriptions)
    }
    
    func bindSecondNotification(_ notificationView: OneNotificationsView) {
        notificationView
            .publisher
            .case(OneNotificationState.didTappedLink)
            .sink { [unowned self] _ in
                self.subject.send(.didTappedNotificationLink(orderNotification: .second))
            }.store(in: &subscriptions)
        
        notificationView
            .publisher
            .case(OneNotificationState.didTappedIcnHelp)
            .sink { [unowned self] _ in
                self.subject.send(.didTappedNotificationIcnHelp(orderNotification: .second))
            }.store(in: &subscriptions)
    }
    
    func bindThirdNotification(_ notificationView: OneNotificationsView) {
        notificationView
            .publisher
            .case(OneNotificationState.didTappedLink)
            .sink { [unowned self] _ in
                self.subject.send(.didTappedNotificationLink(orderNotification: .third))
            }.store(in: &subscriptions)
        
        notificationView
            .publisher
            .case(OneNotificationState.didTappedIcnHelp)
            .sink { [unowned self] _ in
                self.subject.send(.didTappedNotificationIcnHelp(orderNotification: .third))
            }.store(in: &subscriptions)
    }
}

extension OneProductCardView: AccessibilityCapable {}
