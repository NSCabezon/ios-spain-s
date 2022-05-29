import Foundation
import CoreFoundationLib
import UI
import OpenCombine

public protocol GlobalSecurityViewDelegate: AnyObject {
    func didSelectCallNow(_ phoneNumber: String)
    func didSelectStoleCall(_ phoneNumber: String)
    func didSelectSecureDevice()
    func didSelectConfigureAlerts()
    func didSelectPermission()
    func didSelectOnlineProtection()
    func didSelectSafeBox()
    func didSelectTravel()
    func showToast()
}

public protocol GlobalSecurityViewDataComponentsProtocol: AnyObject {
    var isProtectionViewEnabled: Bool? { get }
    var fraudViewModel: PhoneViewModel? { get }
    var cardBlockViewModel: [PhoneViewModel]? { get }
    var isThirdPartyPermissionsHidden: Bool? { get }
    var isPasswordViewEnabled: Bool? { get }
    var isTripModeEnabled: Bool? { get }
    var isOtpPushEnabled: Bool? { get }
    var alertSecurityViewModel: SecurityViewModel? { get }
    var lastLogonViewModel: LastLogonViewModel? { get }
}

public protocol GlobalSecurityViewComponentsProtocol: AnyObject {
    var dataComponents: GlobalSecurityViewDataComponentsProtocol? { get set }
    var delegate: GlobalSecurityViewDelegate? { get set }
    func setProtectionView() -> UIView?
    func setReportFraudView(_ key: LocalizedStylableText?, viewStyle: FlipViewStyle) -> UIView
    func setStolenView(_ key: LocalizedStylableText?, viewStyle: FlipViewStyle) -> UIView
    func setupPermissionsView() -> UIView
    func setPasswordView() -> UIView
    func setTravelView() -> UIView
    func setSecureDevice() -> UIView
    func setAlertView() -> UIView
    func setSmallAlertView(action: @escaping (() -> Void)) -> UIView
    func setLastLogonView() -> UIView?
    func setLargeSecureDevice() -> UIView
}

public final class GlobalSecurityViewComponents: GlobalSecurityViewFactory {
    public weak var dataComponents: GlobalSecurityViewDataComponentsProtocol?
    public weak var delegate: GlobalSecurityViewDelegate?
    private var fraudView: ReportFraudView?
    private var callNowView: CallNowView?
    private var stoleViewContainer: UIView = UIView()
    private let dependencies: DependenciesResolver?
    private var subscriptions: Set<AnyCancellable> = []
    private var isEnabledSantanderKey = false
    
    public init() {
        self.dependencies = nil
    }
    
    public init(dependencies: DependenciesResolver?) {
        self.dependencies = dependencies
        self.bindSantanderKey()
    }
    
    public func setProtectionView() -> UIView? {
        guard self.dataComponents?.isProtectionViewEnabled ?? false else { return nil }
        let viewModel = SecurityViewModel(
            title: "security_button_onlineProtection",
            subtitle: "security_text_exclusivePlan",
            icon: "icnLion")
        let view = self.makeProtectionView(viewModel, idContainer: AccessibilitySecurityAreaButtons.onlineProtectionContainer, idButton: AccessibilitySecurityAreaButtons.onlineProtectionButton)
        view.action = self.delegate?.didSelectOnlineProtection
        return view
    }
    
    public func setReportFraudView(_ key: LocalizedStylableText?, viewStyle: FlipViewStyle) -> UIView {
        let view = UIView()
        view.accessibilityIdentifier = AccessibilitySecurityAreaButtons.fraudViewContainer
        view.backgroundColor = .clear
        self.fraudView = self.makeReportFraudView(idContainer: AccessibilitySecurityAreaButtons.fraudFrontContainer, idButton: AccessibilitySecurityAreaButtons.fraudFrontButton)
        self.fraudView?.action = self.didSelectReportFraudView
        view.addSubview(fraudView ?? UIView())
        self.fraudView?.fullFit()
        var viewModel = self.dataComponents?.fraudViewModel ?? PhoneViewModel(phone: "")
        if viewStyle == .hideNumberLabel {
            viewModel = PhoneViewModel(phone: viewModel.phone, title: key, viewStyle: viewStyle)
        }
        self.callNowView = self.makeCallNowView(viewModel, viewStyle: viewStyle)
        view.addSubview(self.callNowView ?? UIView())
        self.callNowView?.fullFit()
        self.callNowView?.isHidden = true
        self.callNowView?.delegate = self
        self.callNowView?.accessibilityIdentifier = AccessibilitySecurityAreaButtons.fraudBackButton
        return view
    }
    
    public func setStolenView(_ key: LocalizedStylableText?, viewStyle: FlipViewStyle) -> UIView {
        guard let cardBlokViewModel = self.dataComponents?.cardBlockViewModel else { return UIView() }
        self.stoleViewContainer.backgroundColor = .clear
        let stoleView = makeStoleView(idContainer: AccessibilitySecurityAreaButtons.stolenCardFrontContainer, idButton: AccessibilitySecurityAreaButtons.stolenCardFrontButton)
        stoleView.action = self.didSelectStoleView
        self.stoleViewContainer.addSubview(stoleView)
        self.stoleViewContainer.accessibilityIdentifier = AccessibilitySecurityAreaButtons.stolenCardContainer
        stoleView.fullFit()
        if cardBlokViewModel.count > 1 {
            self.addMultipleStolenCallView()
        } else {
            self.addSingleStolenCallView(key, viewStyle: viewStyle)
        }
        return self.stoleViewContainer
    }
    
    public func setupPermissionsView() -> UIView {
        let view = self.makePermissionsView(idContainer: AccessibilitySecurityAreaButtons.permissionsContainer, idButton: AccessibilitySecurityAreaButtons.permissionsButton)
        view.action = self.didSelectPermissionsView
        view.alpha = (self.dataComponents?.isThirdPartyPermissionsHidden ?? false) ? 0.5 : 1.0
        return view
    }
    
    public func setPasswordView() -> UIView {
        let viewModel = SecurityViewModel(
            title: "security_button_safe",
            subtitle: "security_text_exclusivePlan",
            icon: "icnSafe"
        )
        let view = self.makeProtectionView(viewModel, idContainer: AccessibilitySecurityAreaButtons.passwordContainer, idButton: AccessibilitySecurityAreaButtons.passwordButton)
        view.action = self.delegate?.didSelectSafeBox
        view.isHidden = !(self.dataComponents?.isPasswordViewEnabled ?? false)
        return view
    }
    
    public func setTravelView() -> UIView {
        let view = self.makeTravelView(idContainer: AccessibilitySecurityAreaButtons.travelContainer, idButton: AccessibilitySecurityAreaButtons.travelButton)
        view.action = self.didSelectTravelView
        view.isHidden = !(self.dataComponents?.isTripModeEnabled ?? false)
        return view
    }
    
    public func setSecureDevice() -> UIView {
        if let view = dependencies?.resolve(forOptionalType: SKSecurityPersonalAreaModifierProtocol.self)?.getCustomSecurityDeviceView(),
           isEnabledSantanderKey {
            return view
        } else {
            let viewModel = SecurityViewModel(
                title: "security_button_secureDevice",
                subtitle: "security_text_secureDevice",
                icon: "icnPhoneSecure"
            )
            let view = self.makeSecureDeviceView(viewModel, idContainer: AccessibilitySecurityAreaButtons.secureDeviceContainer, idButton: AccessibilitySecurityAreaButtons.secureDeviceButton)
            let otpEnabled = self.dataComponents?.isOtpPushEnabled ?? false
            view.alpha = !otpEnabled ? 0.5 : 1.0
            view.isUserInteractionEnabled = otpEnabled
            view.action = self.didSelectSecureDevice
            return view
        }
    }
    
    public func setAlertView() -> UIView {
        let viewModel: SecurityViewModel
        let existOffer: Bool
        if let offerViewModel = self.dataComponents?.alertSecurityViewModel {
            viewModel = offerViewModel
            existOffer = true
        } else {
            viewModel = SecurityViewModel(
                title: "security_button_notification",
                subtitle: "security_text_superInformed",
                icon: "icnRing"
            )
            existOffer = false
        }
        let view = self.makeBottomSquareView(viewModel, idContainer: AccessibilitySecurityAreaButtons.alertContainer, idButton: AccessibilitySecurityAreaButtons.alertButton)
        view.alpha = !existOffer ? 0.5 : 1.0
        view.isUserInteractionEnabled = existOffer
        view.action = self.didTapBottomSquareView
        return view
    }
    
    public func setSmallAlertView(action: @escaping () -> Void) -> UIView {
        let viewModel = SecurityViewModel(
            title: "security_button_notification",
            subtitle: "security_text_superInformed",
            icon: "icnRing"
        )
        let view = self.makeSmallBottomSquareView(viewModel, idContainer: AccessibilitySecurityAreaButtons.alertContainer, idButton: AccessibilitySecurityAreaButtons.alertButton)
        view.action = action
        return view
    }
    
    public func setLargeSecureDevice() -> UIView {
        let viewModel = SecurityViewModel(
            title: "security_button_secureDevice",
            subtitle: "security_text_secureDevice",
            icon: "icnPhoneSecure"
        )
        let view = self.makeLargeSecureDeviceView(viewModel, idContainer: AccessibilitySecurityAreaButtons.secureDeviceContainer, idButton: AccessibilitySecurityAreaButtons.secureDeviceButton)
        view.action = self.showToast
        return view
    }
    
    public func setLastLogonView() -> UIView? {
        guard let viewModel = self.dataComponents?.lastLogonViewModel else { return nil }
        let view = self.makeLastLogonView(viewModel)
        return view
    }
}

private extension GlobalSecurityViewComponents {
    func didSelectStoleView() {
        guard self.stoleViewContainer.subviews.count > 1 else { return }
        let hideView = stoleViewContainer.subviews[0]
        let showView = stoleViewContainer.subviews[1]
        UIView.flipView(viewToShow: showView,
                        viewToHide: hideView,
                        flipBackIn: 2.2)
    }
    
    func addSingleStolenCallView(_ title: LocalizedStylableText?, viewStyle: FlipViewStyle) {
        var stoleSingleCallView = SinglePhoneView()
        var cardBlockViewModel = self.dataComponents?.cardBlockViewModel?.first ?? PhoneViewModel(phone: "")
        if viewStyle == .hideNumberLabel {
            cardBlockViewModel = PhoneViewModel(phone: cardBlockViewModel.phone, title: title, viewStyle: viewStyle)
        }
        stoleSingleCallView = self.makeSinglePhoneView(cardBlockViewModel,
                                                       idContainer: AccessibilitySecurityAreaButtons.stolenCardSinglePhoneBackContainer,
                                                       idButton: AccessibilitySecurityAreaButtons.stolenCardSinglePhoneBackButton,
                                                       viewStyle: viewStyle)
        self.stoleViewContainer.addSubview(stoleSingleCallView)
        stoleSingleCallView.delegate = self
        stoleSingleCallView.fullFit()
        stoleSingleCallView.isHidden = true
    }
    
    func addMultipleStolenCallView() {
        guard let viewModel = self.dataComponents?.cardBlockViewModel else { return }
        if viewModel.count == 2 {
            let viewModels = (viewModel[0],
                              viewModel[1])
            let doblePhoneCallView = self.makeDoublePhoneView(viewModels, container: AccessibilitySecurityAreaButtons.stolenCardDoublePhoneBackContainer, topButton: AccessibilitySecurityAreaButtons.stolenCardDoubleFirstPhoneBackButton, bottomButton: AccessibilitySecurityAreaButtons.stolenCardDoubleSecondPhoneBackButton)
            self.stoleViewContainer.addSubview(doblePhoneCallView)
            doblePhoneCallView.fullFit()
            doblePhoneCallView.delegate = self
            doblePhoneCallView.isHidden = true
            doblePhoneCallView.setAccessibilityIdentifiers(
                container: AccessibilitySecurityAreaButtons.stolenCardDoublePhoneBackContainer,
                topButton: AccessibilitySecurityAreaButtons.stolenCardDoubleFirstPhoneBackButton,
                bottomButton: AccessibilitySecurityAreaButtons.stolenCardDoubleSecondPhoneBackButton)
        }
    }
    
    func didSelectReportFraudView() {
        guard let fraudView = self.fraudView, let callNowView = self.callNowView else { return }
        UIView.flipView(viewToShow: callNowView,
                        viewToHide: fraudView,
                        flipBackIn: 2.2)
    }
    
    func didSelectTravelView() {
        self.delegate?.didSelectTravel()
    }
    
    func didSelectSecureDevice() {
        self.delegate?.didSelectSecureDevice()
    }
    
    func didSelectPermissionsView() {
        self.delegate?.didSelectPermission()
    }
    
    func didTapBottomSquareView() {
        self.delegate?.didSelectConfigureAlerts()
    }
    
    func didCallCommonFunction(_ phoneNumber: String) {
        self.delegate?.didSelectStoleCall(phoneNumber)
    }
    
    func showToast() {
        self.delegate?.showToast()
    }
}

extension GlobalSecurityViewComponents: GlobalSecurityViewComponentsProtocol { }

extension GlobalSecurityViewComponents: CallNowViewDelegate {
    public func didSelectCall(_ phoneNumber: String) {
        self.delegate?.didSelectCallNow(phoneNumber)
    }
}

extension GlobalSecurityViewComponents: SinglePhoneViewDelegate, DoublePhoneViewDelegate {
    public func didSelectDobleCall(_ phoneNumber: String) {
        didCallCommonFunction(phoneNumber)
    }
    
    public func didSelectSinglePhoneView(_ phoneNumber: String) {
        didCallCommonFunction(phoneNumber)
    }
}

private extension GlobalSecurityViewComponents {
    func bindSantanderKey() {
        dependencies?.resolve(forOptionalType: SKSecurityPersonalAreaModifierProtocol.self)?.isEnabledSantanderKey { result in
            self.isEnabledSantanderKey = result
        }
    }
}
