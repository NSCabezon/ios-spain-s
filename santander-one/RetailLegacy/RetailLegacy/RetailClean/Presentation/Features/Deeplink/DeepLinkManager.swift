import UIKit
import Transfer
import CoreFoundationLib
import Cards
import Operative
import GlobalPosition
import OneAuthorizationProcessor

enum DeepLinkLauncherAccessType {
    case publicAccess
    case privateAccess
}

/// Protocol that should implement any presenter with the responsability of handling the deeplink representation
protocol DeepLinkLauncherPresentationProtocol: AnyObject {
    /// Variable to set if a controller should show a deeplink.
    var shouldRegisterAsDeeplinkHandler: Bool { get }
    var shouldOpenDeepLinkAutomatically: Bool { get }
    var dependencies: PresentationComponent { get }
    var genericErrorHandler: GenericPresenterErrorHandler { get }
    var viewProxy: ViewControllerProxy { get }
    var sessionManager: CoreSessionManager { get }
    var launcherAccessType: DeepLinkLauncherAccessType { get }
    func showLoading(info: LoadingInfo, tag: Int)
    func hideLoading(completion: (() -> Void)?, tag: Int)
    func showError(keyTitle: String?, keyDesc: String?, phone: String?, completion: (() -> Void)?)
    func appOpenedFromDeeplink(deeplinkId: String)
}

class DeepLinkManager {
    
    // MARK: - Private attributes
    
    private var scheduledDeepLink: DeepLinkEnumerationCapable?
    private var deeplinkLauncher: DeepLinkLauncher?
    private let sessionManager: CoreSessionManager

    // MARK: - Public methods
    
    init(sessionManager: CoreSessionManager) {
        self.sessionManager = sessionManager
    }
    
    /// Use this method to register the presentation layer that handle the deeplink representation
    ///
    /// - Parameter presentationDelegate: the DeepLinkLauncherPresentationProtocol object
    func register(presentationDelegate: DeepLinkLauncherPresentationProtocol) {
        guard presentationDelegate.shouldRegisterAsDeeplinkHandler else { return }
        self.deeplinkLauncher = DeepLinkLauncher(presentationLauncher: presentationDelegate)
        if presentationDelegate.shouldOpenDeepLinkAutomatically && self.validateAccess(presentationDelegate) {
            performScheduledDeepLink()
        }
    }
    
    func getScheduledDeepLinkTracker() -> String? {
        return scheduledDeepLink?.trackerId
    }
    
    /// Use this method to unregister the presentation layer that handle the deeplink representation
    ///
    /// - Parameter presentationDelegate: the DeepLinkLauncherPresentationProtocol object
    func unregister(presentationDelegate: DeepLinkLauncherPresentationProtocol) {
        deeplinkLauncher = nil
    }
    
    /// Method to know if there is any deeplink scheduled
    ///
    /// - Returns: true if there is a deeplink scheduled
    func isDeepLinkScheduled() -> Bool {
        return scheduledDeepLink != nil
    }
    
    /// Use this method to perform the scheduled (if exist) deeplink
    func performScheduledDeepLink() {
        guard let extractedDeepLink = self.scheduledDeepLink, let deeplinkLauncher = self.deeplinkLauncher, sessionManager.isSessionActive else { return }
        deeplinkLauncher.openDeepLink(extractedDeepLink)
        self.scheduledDeepLink = nil
    }
    
    /// Use this method to know if we should open the url into the app. Also it registers the deeplink in case that it was correct.
    ///
    /// - Parameters:
    ///   - url: the url
    ///   - options: the options
    /// - Returns: if the deeplink did register successfully
    @discardableResult func shouldOpenURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return registerDeepLinkWithURL(url)
    }
    
    /// Use this method to register a deeplink directly.
    ///
    /// - Parameter deeplink: the deeplink
    func registerDeepLink(_ deeplink: DeepLinkEnumerationCapable) -> () {
        self.scheduledDeepLink = deeplink
        if let trackerId = deeplink.trackerId {
            deeplinkLauncher?.presentationLauncher?.appOpenedFromDeeplink(deeplinkId: trackerId)
        }
        evaluateBeforePerformingDeepLinkAction { [weak self] in
            self?.performScheduledDeepLink()
        }
    }
}

private extension DeepLinkManager {
    // MARK: - Private methods
    private func evaluateBeforePerformingDeepLinkAction(perform: @escaping () -> Void) {
        guard let presentationLauncher = self.deeplinkLauncher?.presentationLauncher else { return }
        if self.validateAccess(presentationLauncher) {
            Dialog.dismiss { _ in
                perform()
            }
        }
    }
    
    private func registerDeepLinkWithURL(_ url: URL) -> Bool {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let nComponent = urlComponents?.queryItems?.first(where: { $0.name == "n" })
        guard let deeplink = DeepLink(nComponent?.value ?? "", userInfo: deepLinkUserInfo(url)) else {
            return false
        }
        registerDeepLink(deeplink)
        return true
    }
    
    private func deepLinkUserInfo(_ url: URL) -> [DeepLinkUserInfoKeys: String] {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        // iterate into all cases of DeepLinkUserInfoKeys and get the query item in the url (if exist)
        return Dictionary(
            uniqueKeysWithValues: DeepLinkUserInfoKeys.allCases.compactMap { info in
                guard let value = urlComponents?.queryItems?.first(where: { $0.name == info.rawValue })?.value else { return nil }
                return (info, value)
            }
        )
    }
    
    func validateAccess(_ presentationDelegate: DeepLinkLauncherPresentationProtocol) -> Bool {
        guard let deepLink = self.scheduledDeepLink else { return false }
        let deepLinkAccessType = deepLink.accessType
        switch presentationDelegate.launcherAccessType {
        case .publicAccess:
            return deepLinkAccessType == .publicDeepLink || deepLinkAccessType == .generalDeepLink
        case .privateAccess:
            return deepLinkAccessType == .privateDeepLink || deepLinkAccessType == .generalDeepLink
        }
    }
}

// MARK: - DeepLinkLauncher

private class DeepLinkLauncher {
    
    // MARK: - Public attributes
    
    weak var presentationLauncher: DeepLinkLauncherPresentationProtocol?
    let dependencies: PresentationComponent
    let errorHandler: GenericPresenterErrorHandler
    let sessionManager: CoreSessionManager
    private let compilation: CompilationProtocol
    lazy var navigator: DeepLinkNavigatorProtocol = {
        return dependencies.navigatorProvider.deepLinkNavigator
    }()
    private var stringLoader: StringLoader {
        return dependencies.stringLoader
    }
    var genericErrorHandler: GenericPresenterErrorHandler {
        return errorHandler
    }
    lazy var deepLinkApplePayProxy: DeepLinkProxy = {
        return DeepLinkApplePayProxy(dependencies: self.dependencies.navigatorProvider.dependenciesEngine)
    }()
    var cardExternalDependencies: CardExternalDependenciesResolver {
        return dependencies.navigatorProvider.cardExternalDependenciesResolver
    }
    
    // MARK: - Public methods
    
    init(presentationLauncher: DeepLinkLauncherPresentationProtocol) {
        self.presentationLauncher =  presentationLauncher
        self.sessionManager = presentationLauncher.sessionManager
        self.dependencies = presentationLauncher.dependencies
        self.errorHandler = presentationLauncher.genericErrorHandler
        self.compilation = presentationLauncher.dependencies.useCaseProvider.dependenciesResolver.resolve(for: CompilationProtocol.self)
    }
    
    func openDeepLink(_ deepLink: DeepLinkEnumerationCapable) {
        guard let coreDeepLink = deepLink as? DeepLink else {
            self.openCustomDeepLink(deepLink)
            return
        }
        self.openCoreDeepLink(coreDeepLink)
    }
    
    private func openCustomDeepLink(_ deepLink: DeepLinkEnumerationCapable) {
        self.dependenciesResolver
            .resolve(forOptionalType: CustomDeeplinkLauncher.self)?
            .launch(deeplink: deepLink)
    }
    
    private func openCoreDeepLink(_  deepLink: DeepLink) {
        navigator.restoreDefaultViewSettings()
        switch deepLink {
        case .easyPay: goToEasyPay()
        case .directMoney: goToDirectMoney()
        case .payLater: showPayLaterCard(card: nil, delegate: self)
        case .offerLink(let identifier, let location): goToOffer(offerId: identifier, location: location)
        case .extraordinaryContribution: launchExtraordinaryContribution(pension: nil, delegate: self)
        case .fundSuscription:
            showFundSubscription(fund: nil, delegate: self)
        case .billsAndTaxesPay: goToBillsAndTaxes()
        case .activateCard: activateCard(nil, launchedFrom: .pg, delegate: self)
        case .turnOnCard:
            self.dependencies.dependenciesEngine.register(for: CardsHomeModuleCoordinatorDelegate.self) { resolver in
                return self.dependencies.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
            }
            goToCardOnOff(card: nil, option: .turnOn, handler: self)
        case .turnOffCard:
            self.dependencies.dependenciesEngine.register(for: CardsHomeModuleCoordinatorDelegate.self) { resolver in
                return self.dependencies.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
            }
            goToCardOnOff(card: nil, option: .turnOff, handler: self)
        case .pinQuery: showPINQueryCard(nil, delegate: self)
        case .cvvQuery: showCVVQueryCard(nil, delegate: self)
        case .ecash: showCardChargeDischargeCard(nil, delegate: self)
        case .internalTransfer: goToInternalTransfer()
        case .nationalTransfer: showTransfer(nil, delegate: self)
        case .transfer: goToTransfers()
        case .personalArea: goToPersonalArea()
        case .securitySettings: goToSecuritySettings()
        case .atm: goToATM()
        case .analysisArea: goToAnalysisArea()
        case .open: break
        case .cesSignUp: signupCesCard(nil, delegate: self)
        case .withdrawMoneyWithCode:
            showWithdrawMoneyWithCode(nil, delegate: self)
        case .cardPdfExtract: goToCardPdfExtract()
        case .marketplace: showMarketplace()
        case .changeCardPayMethod: modifyPayment(product: nil, delegate: self)
        case .timeline: goToTimeline()
        case .cat(let identifier): goToPurchaseProduct(identifier: identifier)
        case .myManager: goToMyManager()
        case .offersForYou: goToPublicProducts(delegate: self, location: PullOfferLocation.CONTRATAR_SANFLIX)
        case .onlineMessagesInbox: goToOnlineMessagesInbox()
        case .secureDevice: goToSecureDevice()
        case .userBasicInfo: goToUserBasicInfo()
        case .addToApplePay: goToAddToApplePay()
        case .changeSign: goToChangeSign()
        case .financing: goToFinancing()
        case .financingCards: goToFinancingCards()
        case .payOff: goToPayOff(nil, delegate: self)
        case .whatsNew: goToWhatsNew()
        case .whatsNewFractionableCardMovements: goToWhatsNewFractionableCardMovements()
        case .correosCash: goToATMLocator()
        case .cardBoarding: gotoCardBoarding(delegate: self)
        case .tips: self.goToTips()
        case .globalPosition: self.goToGlobalPosition()
        case .authorizationProcess(authorizationId: let authorizationId, scope: let scope): goToAuthorizationProcessor(authorizationId: authorizationId, scope: scope)
        case .custom(let deeplink, let userInfo):
            dependenciesResolver
                .resolve(forOptionalType: CustomDeeplinkLauncher.self)?
                .launch(deeplink: deeplink, with: userInfo)
        }
    }
    
    private func goToFinancing() {
        let useCase = dependencies.useCaseProvider.getFinancingUseCase()
        UseCaseWrapper( with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] response in
            if response.financingEnabled == true {
                self?.dependencies.navigatorProvider.privateHomeNavigator.goToFinancing()
            }
        })
    }
    
    private func goToInternalTransfer() {
        self.dependencies.navigatorProvider.privateHomeNavigator.goToInternalTransfers()
    }
    
    private func goToEasyPay() {
        showEasyPay(product: nil, operativeDataEntity: nil, handler: self)
    }
    
    private func goToOffer(offerId: String, location: PullOfferLocation?) {
        let useCase = dependencies.useCaseProvider.getGetValidPullOfferUseCase(input: GetValidPullOfferUseCaseInput(offerId: offerId))
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] result in
                self?.executeOffer(action: result.offer.action, offerId: result.offer.id, location: location)
            }, onError: { [weak self] _ in
                self?.genericErrorHandler.onError(keyDesc: "deeplink_alert_errorOffer", completion: {})
            }
        )
    }
    
    private func goToPurchaseProduct(identifier: String) {
        let useCase = dependencies.useCaseProvider.getPublicCategoryUseCase(input: GetPublicCategoryUseCaseInput(identifier: identifier))
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] response in
            guard let strongSelf = self else { return }
            guard let offers = response.category?.offers else {
                strongSelf.genericErrorHandler.onError(keyDesc: "deeplink_alert_errorOffer", completion: {})
                return
            }
            strongSelf.dependencies.navigatorProvider.productCollectionNavigator.goToPullOfferBanners(offers, response.category?.id ?? "")
        }, onError: { [weak self] error in
            guard let strongSelf = self else { return }
            strongSelf.genericErrorHandler.onError(keyDesc: error?.getErrorDesc(), completion: {})
        })
    }
}

extension DeepLinkLauncher: CardboardingLauncherDelegate, CardBoardingActivationLauncher {
    func gotoCardsSelectionHomeWithCards(_ cards: [CardEntity]) {
        self.dependencies.navigatorProvider.cardboardingNavigator.gotoCardsSelectionHome(cards: cards)
    }
    
    func goToCardBoardingActivationWithCard(_ card: CardEntity) {
        self.goToCardBoardingActivation(card: card, handler: self)
    }
    
    func gotoCardBoardingCustomizingCard(_ card: CardEntity) {
        self.dependencies.navigatorProvider.cardboardingNavigator.gotoWelcomeWithCard(card)
    }
    
    func startLoading() {
        self.startOperativeLoading {}
    }
    
    func endLoading(completion: (() -> Void)?) {
        self.hideOperativeLoading { completion?() }
    }
}

private protocol DeepLinkPageLauncher {
    func goToPersonalArea()
    func goToSecuritySettings()
    func goToAnalysisArea()
    func goToTransfers()
    func goToBillsAndTaxes()
    func goToCardPdfExtract()
    func showMarketplace()
    func goToMyManager()
    func goToOnlineMessagesInbox()
    func goToFinancingCards()
    func goToTimeline()
    func goToUserBasicInfo()
    func goToAddToApplePay()
    func goToWhatsNew()
    func goToWhatsNewFractionableCardMovements()
    func goToATMLocator()
    func goToATM()
    func goToTips()
    func goToGlobalPosition()
}

extension DeepLinkLauncher: DeepLinkPageLauncher {
    func goToWhatsNew() {
        UseCaseWrapper(with: dependencies.useCaseProvider.getIsWhatsNewEnabledUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) in
            guard result.isEnabled else {
                self?.dependencies.navigatorProvider.privateHomeNavigator.backToGlobalPosition()
                return
            }
            self?.dependencies.navigatorProvider.privateHomeNavigator.goToWhatsNew()
        })
    }
    
    func goToWhatsNewFractionableCardMovements() {
        Scenario(useCase: dependencies.useCaseProvider.getIsWhatsNewEnabledUseCase())
            .execute(on: dependencies.useCaseHandler)
            .onSuccess { [weak self] result in
                if result.isEnabled {
                    self?.dependencies.navigatorProvider.dependenciesEngine.register(for: LastMovementsConfiguration.self) {_ in
                        return LastMovementsConfiguration(.fractionableCards)
                    }
                    self?.dependencies.navigatorProvider.privateHomeNavigator.goToWhatsNewFractionalMovements()
                } else {
                    self?.dependencies.navigatorProvider.privateHomeNavigator.backToGlobalPosition()
                }
            }
    }
    
    func goToPersonalArea() {
        dependencies.navigatorProvider.privateHomeNavigator.goToPersonalArea()
    }
    
    func goToSecuritySettings() {
        dependencies.navigatorProvider.privateHomeNavigator.goToSecuritySettings()
    }
    
    func showMarketplace() {
        UseCaseWrapper(with: dependencies.useCaseProvider.getIsMarketplaceEnabledUseCase(), useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] (result) in
            if result.isEnabled {
                self?.goToMarketPlace()
            } else {
                self?.genericErrorHandler.onError(keyDesc: "deeplink_alert_errorBizum", completion: {})
            }
        })
    }
    
    private func goToMarketPlace() {
        dependencies.locationManager.getCurrentLocation { [weak self] latitude, longitude in
            guard let strongSelf = self else { return }
            UseCaseWrapper(with: strongSelf.useCaseProvider.getMarketplaceUseCase(input: GetMarketplaceWebViewConfigurationInput(latitude: latitude, longitude: longitude)), useCaseHandler: strongSelf.useCaseHandler, errorHandler: strongSelf.genericErrorHandler, onSuccess: { [weak self] (result) in
                guard let self = self else {
                    return
                }
                self.dependencies.navigatorProvider.privateHomeNavigator.goToWebView(with: result.configuration, linkHandler: nil, dependencies: self.dependencies, errorHandler: self.errorHandler, didCloseClosure: nil)
            }, onError: { [weak self] _ in
                self?.genericErrorHandler.onError(keyDesc: "deeplink_alert_errorBizum", completion: {})
            })
        }
    }
    
    func goToAnalysisArea() {
        let useCase = dependencies.useCaseProvider.getIsAnalysisAreaEnabledUseCase()
        UseCaseWrapper( with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] response in
            if response.isEnabled {
                self?.dependencies.navigatorProvider.privateHomeNavigator.goToAnalysisArea()
            } else {
                self?.genericErrorHandler.onError(keyDesc: "deeplink_alert_analysis", completion: {})
            }
        }, onError: { [weak self] _ in
            self?.genericErrorHandler.onError(keyDesc: "deeplink_alert_analysis", completion: {})
        })
    }
    
    func goToTransfers() {
        let useCase = dependencies.useCaseProvider.getPGDataUseCase()
        UseCaseWrapper( with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] response in
            if response.globalPosition.accounts.get().count > 0 {
                self?.dependencies.navigatorProvider.privateHomeNavigator.goToTransfers(section: .home)
            } else {
                self?.genericErrorHandler.onError(keyDesc: "deeplink_alert_errorHomeOnePay", completion: {})
            }
        }, onError: { [weak self] _ in
            self?.genericErrorHandler.onError(keyDesc: "deeplink_alert_errorHomeOnePay", completion: {})
        })
    }
    
    func goToBillsAndTaxes() {
        let useCase = dependencies.useCaseProvider.getPGDataUseCase()
        UseCaseWrapper( with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] response in
            if response.globalPosition.accounts.getVisibles().count > 0 {
                self?.dependencies.navigatorProvider.privateHomeNavigator.goToBillsAndTaxes()
            } else {
                self?.genericErrorHandler.onError(keyDesc: "deeplink_alert_errorBillTax", completion: {})
            }
        }, onError: { [weak self] _ in
            self?.genericErrorHandler.onError(keyDesc: "deeplink_alert_errorBillTax", completion: {})
        })
    }
    
    func goToCardPdfExtract() {
        let useCase = dependencies.useCaseProvider.getGetCreditCardsWithPdfUseCase()
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] result in
                self?.dependencies.navigatorProvider.deepLinkNavigator.goToCardPdfExtract(cards: result.cards)
            }, onError: { [weak self] error in
                guard let errorDesc = error?.getErrorDesc() else {
                    return
                }
                self?.genericErrorHandler.onError(keyDesc: errorDesc, completion: {})
            }
        )
    }
    
    func goToMyManager() {
        dependencies.navigatorProvider.privateHomeNavigator.goToManager()
    }
    
    func goToOnlineMessagesInbox() {
        dependencies.navigatorProvider.inboxHomeNavigator.gotoInboxHome()
    }
    
    func goToFinancingCards() {
        let useCase = dependencies.useCaseProvider.getFinancingCardsDeeplinkUseCase()
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] result in
                guard result.deeplinkCardsEnabled else { return }
                self?.dependencies.navigatorProvider.menuHomeNavigator.gotoFinancingCards()
            }
        )
    }
    
    private func evaluateOpenSecureDevice(_ completion: @escaping (Bool) -> Void) {
        Scenario(useCase: GetOtpPushEnabledUseCase(dependenciesResolver: dependenciesResolver))
            .execute(on: useCaseHandler)
            .onSuccess { response in
                completion(response.otpPushEnabled)
            }
    }
    
    private func goToSecureDevice() {
        evaluateOpenSecureDevice { [weak self] isSecureDeviceEnabled in
            guard
                isSecureDeviceEnabled,
                let strongSelf = self,
                let presentationLauncher = strongSelf.presentationLauncher
            else { return }
            
            let type = LoadingViewType.onScreen(controller: presentationLauncher.viewProxy.viewController, completion: nil)
            let text = LoadingText(title: strongSelf.stringLoader.getString("generic_popup_loading"), subtitle: strongSelf.stringLoader.getString("loading_label_moment"))
            let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
            presentationLauncher.showLoading(info: info, tag: 0)
            CoreFoundationLib.UseCaseWrapper(with: strongSelf.useCaseProvider.getGetOTPPushDeviceUseCase(), useCaseHandler: strongSelf.useCaseHandler, onSuccess: { [weak self] response in
                self?.presentationLauncher?.hideLoading(completion: { [weak self] in
                    self?.dependencies.navigatorProvider.privateHomeNavigator.goToSecureDevice(device: response.device.createEntity())
                }, tag: 0)
            }, onError: { [weak self] error in
                guard let strongSelf = self else { return }
                guard case CoreFoundationLib.UseCaseError.error(let optionalError) = error, let serviceError = optionalError else {
                    strongSelf.presentationLauncher?.hideLoading(completion: nil, tag: 0)
                    return
                }
                strongSelf.presentationLauncher?.hideLoading(completion: { [weak self] in
                    guard let self = self else { return }
                    switch serviceError.codeError {
                    case .technicalError:
                        self.genericErrorHandler.onError(keyDesc: serviceError.getErrorDesc(), completion: {})
                    case .unregisteredDevice:
                        self.dependencies.navigatorProvider.privateHomeNavigator.goToSecureDevice(device: nil)
                    case .differentsDevices:
                        self.genericErrorHandler.onError(keyDesc: serviceError.getErrorDesc(), completion: {})
                    case .serviceFault:
                        self.genericErrorHandler.onError(keyDesc: serviceError.getErrorDesc(), completion: {})
                    }
                }, tag: 0)
            })
        }
    }
    
    func goToTimeline() {
        let useCase = dependencies.useCaseProvider.getGetTimeLineIsEnabledUseCase()
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] result in
                if result.isTimelineEnabled {
                    self?.dependencies.navigatorProvider.privateHomeNavigator.goToTimeline()
                }
            }, onError: { [weak self] error in
                guard let errorDesc = error?.getErrorDesc() else {
                    return
                }
                self?.genericErrorHandler.onError(keyDesc: errorDesc, completion: {})
            }
        )
    }
    
    func goToUserBasicInfo() {
        self.dependencies.navigatorProvider.privateHomeNavigator.goToUserBasicInfo()
    }
    
    func goToAddToApplePay() {
        self.dependencies.navigatorProvider
            .dependenciesEngine
            .register(for: GenericPresenterErrorHandler.self) {_ in
                return self.genericErrorHandler
            }
        self.dependencies.navigatorProvider
            .dependenciesEngine
            .register(for: PreSetupAddToApplePayUseCase.self) { _ in
                return self.dependencies.useCaseProvider.getPreSetupAddToApplePayUseCase()
            }
        self.deepLinkApplePayProxy.begin()
    }
    
    func goToChangeSign() {
        let useCase = dependencies.useCaseProvider.getSignatureOperativeConfigurationUseCase()
        MainThreadUseCaseWrapper(with: useCase, errorHandler: nil, onSuccess: { [weak self] response in
            guard let self = self else { return }
            let operative: Operative
            if response.isSignatureActivationPending {
                operative = ActivateSignOperative(dependencies: self.dependencies)
            } else {
                operative = ChangeSignOperative(dependencies: self.dependencies)
            }
            self.navigatorOperativeLauncher.goToOperative(operative, withParameters: [response.operativeConfig], dependencies: self.dependencies)
        }, onError: { [weak self] error in
            guard let errorDesc = error?.getErrorDesc() else { return }
            self?.genericErrorHandler.onError(keyDesc: errorDesc, completion: {})
        })
    }
    
    func goToATMLocator() {
        dependencies.navigatorProvider.privateHomeNavigator.goToATMLocator(keepingNavigation: true)
    }
    
    func goToATM() {
        dependencies.navigatorProvider.privateHomeNavigator.goToAtm()
    }
    
    func goToDirectMoney(_ cardEntity: CardEntity? = nil) {
        guard let isEnablePBI = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self).getBool(DirectMoneyConstants.appConfigEnablePBI),
              isEnablePBI else {
            goToDirectMoneyOperative(card: nil, launchedFrom: .pg, delegate: self)
            return
        }
        self.dependencies.navigatorProvider.productsNavigator.showCardsHome(with: cardEntity, cardSection: .directMoney)
    }
    
    func goToTips() {
        self.dependencies.navigatorProvider.privateHomeNavigator.goToTips()
    }
    
    func goToGlobalPosition() {
        self.dependencies.navigatorProvider.privateHomeNavigator.backToGlobalPosition()
    }
}

extension DeepLinkLauncher: OperativeLauncherDelegate {
    var navigatorOperativeLauncher: OperativesNavigatorProtocol {
        return navigator
    }
    var operativeDelegate: OperativeLauncherPresentationDelegate {
        return self
    }
}

extension DeepLinkLauncher: OperativeLauncherPresentationDelegate {
    var errorOperativeHandler: GenericPresenterErrorHandler {
        return errorHandler
    }
    
    func startOperativeLoading(completion: @escaping () -> Void) {
        guard let presentationLauncher = presentationLauncher else {
            return
        }
        let type = LoadingViewType.onScreen(controller: presentationLauncher.viewProxy.viewController, completion: completion)
        let text = LoadingText(title: stringLoader.getString("generic_popup_loading"), subtitle: stringLoader.getString("loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil)
        presentationLauncher.showLoading(info: info, tag: 0)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        presentationLauncher?.hideLoading(completion: completion, tag: 0)
    }
    
    func showOperativeAlert(title: LocalizedStylableText?, body message: LocalizedStylableText, withAcceptComponent accept: DialogButtonComponents, withCancelComponent cancel: DialogButtonComponents?) {
        guard let presentationLauncher = presentationLauncher else {
            return
        }
        Dialog.alert(title: title, body: message, withAcceptComponent: accept, withCancelComponent: cancel, source: presentationLauncher.viewProxy.viewController)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        presentationLauncher?.showError(keyTitle: keyTitle, keyDesc: keyDesc, phone: nil, completion: completion)
    }
}

extension DeepLinkLauncher: PullOfferActionsPresenter {
    
    var presentationView: ViewControllerProxy {
        return presentationLauncher?.viewProxy ?? navigator.drawer.topVisibleViewController
    }
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension DeepLinkLauncher: PublicProductsLauncherDelegate {
    var offerPresenter: PullOfferActionsPresenter { self }
}

extension DeepLinkManager: UserActivityHandler {
    /// Use this method to know if you should open the userActivity into the app (Universal links). Also it registers the deeplink in case that it was correct.
    ///
    /// - Parameters:
    ///   - userActivity: the user activity
    /// - Returns: if the deeplink did register successfully
    func shouldContinueUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard let webpageURL = userActivity.webpageURL, userActivity.activityType == NSUserActivityTypeBrowsingWeb else { return false }
        return registerDeepLinkWithURL(webpageURL)
    }
}

extension DeepLinkLauncher: CardPayLaterCardLauncher, TransferLauncher, ExtraordinaryContributionLauncher, CardDirectMoneyLauncher, CardOnOffOperativeLauncher, CardWithdrawalMoneyWithCodeLauncher, CardPINQueryCardLauncher, CardCVVQueryCardLauncher, CardCESSignUpLauncher, CardActivationLauncher, CardChargeDischargeLauncher, FundOperativeDeepLinkLauncher, CardModifyPaymentFormLauncher, CardPayOffLauncher, EnableOtpPushOperativeLauncher, PublicProductsLauncher, CardBoardingLauncher, OneAuthorizationProcessorLauncher {
    
    var origin: OperativeLaunchedFrom {
        return navigator.placeWhereDeeplinkLaunches()
    }
    
    var transferExternalDependencies: OneTransferHomeExternalDependenciesResolver {
        return dependencies.navigatorProvider.legacyExternalDependenciesResolver
    }
}

extension DeepLinkLauncher: OperativeLauncherHandler, EasyPayLauncher {
    var dependenciesResolver: DependenciesResolver {
        self.dependencies.navigatorProvider.dependenciesEngine
    }
    
    func showOperativeLoading(completion: @escaping () -> Void) {
        self.startOperativeLoading(completion: completion)
    }
    
    var operativeNavigationController: UINavigationController? {
        return navigator.navigationController
    }
}

extension DeepLinkManager: DeepLinkManagerProtocol {}
