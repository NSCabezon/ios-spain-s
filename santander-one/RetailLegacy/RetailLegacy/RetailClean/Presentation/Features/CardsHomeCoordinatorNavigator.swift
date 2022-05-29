import CoreFoundationLib
import Cards
import UI
import Operative
import CoreDomain
import PdfCommons

final class CardsHomeCoordinatorNavigator: ModuleCoordinatorNavigator {
    private var pdfCreator: PDFCreator?
    private lazy var delegate: CardsTransactionsPDFGeneratorProtocol? = {
        self.dependenciesEngine.resolve(forOptionalType: CardsTransactionsPDFGeneratorProtocol.self)
    }()
    
    var cardExternalDependencies: CardExternalDependenciesResolver {
        return navigatorProvider.cardExternalDependenciesResolver
    }

    func didSelectDownloadTransactions(for entity: CardEntity, withFilters: TransactionFiltersEntity?) {
        if let modifier = self.delegate {
            startLoading()
            modifier.generatePDF(for: entity, withFilters: withFilters)
        }
    }
    
    func didSelectDismiss() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func didSelectMenu() {
        drawer?.toggleSideMenu()
    }
    
    func didSelectSettlementAction(_ action: NextSettlementActionType, entity: CardEntity) {
        let card = CardFactory.getCard(entity)
        switch action {
        case .postponeReceipt: showPayLaterCard(card: card, delegate: self)
        case .changePaymentMethod: modifyPayment(product: card, delegate: self)
        case .historicExtractPDF: goToHistoricExtractOperative(card.cardEntity)
        case .shoppingMap: break
        }
    }
    
    func didSelectSearch(for loan: CardEntity) {
        if self.localAppConfig.isEnabledMagnifyingGlass {
            self.navigatorProvider.privateHomeNavigator.goToGlobalSearch()
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    func didSelectAddToApplePay(card: CardEntity?, delegate: ApplePayEnrollmentDelegate) {
        self.dependenciesEngine.register(for: ApplePayEnrollmentDelegate.self) { _ in
            return delegate
        }
        if let entity = card {
            self.showAddToApplePay(card: Card(entity), delegate: self)
        } else {
            self.showAddToApplePay(card: nil, delegate: self)
        }
    }
    
    func showDialog(acceptTitle: LocalizedStylableText?, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText?, body: LocalizedStylableText?, showsCloseButton: Bool = false, source: UIViewController, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        var error: LocalizedStylableText = .empty
        var titleError: LocalizedStylableText = .empty
        
        if let title = title {
            titleError = title
        }
        if let body = body {
            error = body
        }
        guard !error.text.isEmpty else {
            return self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesEngine)
        }
        let acceptComponents = DialogButtonComponents(titled: acceptTitle ?? localized("generic_button_accept"), does: acceptAction)
        var cancelComponents: DialogButtonComponents?
        if let cancelTitle = cancelTitle {
            cancelComponents = DialogButtonComponents(titled: cancelTitle, does: cancelAction)
        }
        Dialog.alert(title: titleError, body: error, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, showsCloseButton: showsCloseButton, source: source)
    }
    
    override func executeOffer(_ offer: OfferRepresentable?) {
        guard let offer = offer else { return }
        super.executeOffer(offer)
    }
}

extension CardsHomeCoordinatorNavigator: CardBoardingActivationLauncher {
    func goToCardBoardingActivation(card: CardEntity) {
        self.goToCardBoardingActivation(card: card, handler: self)
    }
}

extension CardsHomeCoordinatorNavigator: CardOnOffOperativeLauncher {
    func goToCardOnOff(card: CardEntity?, option: CardBlockType) {
        self.goToCardOnOff(card: card, option: option, handler: self)
    }
}

extension CardsHomeCoordinatorNavigator: CardBlockOperativeLauncher {
    func goToCardBlock(card: CardEntity?) {
        self.goToCardBlock(card: card, handler: self)
    }
}

extension CardsHomeCoordinatorNavigator: CardsHomeModuleCoordinatorDelegate {

    func didGenerateTransactionsPDF(for card: CardEntity, holder: String?, fromDate: Date?, toDate: Date?, transactions: [CardTransactionEntityProtocol], showDisclaimer: Bool) {
        generatePdf(for: card,
                       holder: holder,
                       fromDate: fromDate,
                       toDate: toDate,
                       transactions: transactions,
                       showDisclaimer: showDisclaimer)
    }
    
    func didSelectInExtractPdf(_ cardEntity: CardEntity, selectedMonth: String) {
        let card = CardFactory.getCard(cardEntity)
        pdf(forCard: card, month: selectedMonth)
    }
    
    func didSelectOffer(offer: OfferRepresentable) {
        self.executeOffer(offer)
    }
    func openSettings() {
        self.navigateToSettings()
    }
    
    func easyPay(entity: CardEntity, transactionEntity: CardTransactionEntity, easyPayOperativeDataEntity: EasyPayOperativeDataEntity?) {
        let prod = CardTransactionWithCardEntity(cardTransactionEntity: transactionEntity,
                                                 cardEntity: entity)
        self.showEasyPay(product: prod, operativeDataEntity: easyPayOperativeDataEntity, handler: self)
    }
    
    // MARK: - Legacy
    func didSelectAction(_ action: OldCardActionType, _ entity: CardEntity) {
        let card = CardFactory.getCard(entity)
        switch action {
        case .enable:
            guard let cardBoardingModfier = dependenciesResolver.resolve(forOptionalType: CardBoardingModifierProtocol.self),
                  cardBoardingModfier.alwaysActivateCardOnCardboarding() else {
                self.gotoActivateCard(card: card, entity: entity)
                return
            }
            self.goToCardBoardingActivation(card: entity)
        case .onCard: self.goToCardOnOff(card: entity, option: .turnOn)
        case .offCard: self.goToCardOnOff(card: entity, option: .turnOff)
        case .instantCash: goToDirectMoney(card, entity: entity)
        case .pin: showPINQueryCard(card, delegate: self)
        case .pdfExtract: dateForPdf(product: card)
        case .historicPdfExtract: goToHistoricExtractOperative(card.cardEntity)
        case .mobileTopUp: mobileTopUp(card: card, delegate: self)
        case .modifyLimits: goToCardLimitManagementOperative(card: card, delegate: self)
        case .chargeDischarge: showCardChargeDischargeCard(card, delegate: self)
        case .cvv: showCVVQueryCard(card, delegate: self)
        case .block:
            guard let cardBlockModifier = dependenciesResolver.resolve(forOptionalType: CardBlockModifierProtocol.self),
                  cardBlockModifier.isCardBlockAvailable() else {
                blockCard(card, delegate: self)
                return
            }
            self.goToCardBlock(card: entity)
        case .delayPayment: showPayLaterCard(card: card, delegate: self)
        case .payOff: goToPayOff(card, delegate: self)
        case .withdrawMoneyWithCode: showWithdrawMoneyWithCode(card, delegate: self)
        case .ces: signupCesCard(card, delegate: self)
        case .solidarityRounding(let offer): executeOffer(offer)
        case .changePaymentMethod: modifyPayment(product: card, delegate: self)
        case .hireCard(let location): goToHireCardOffer(location)
        case .fraud(let offer): executeOffer(offer)
        case .divide(let operation): self.goToSplitExpenses(operation: operation)
        case .share: Toast.show(localized("generic_alert_notAvailableOperation"))
        case .chargePrepaid: showCardChargeDischargeCard(card, delegate: self)
        case .suscription(let offer): executeOffer(offer)
        case .configure: self.didSelectCardBoardingWelcome(card: entity)
        case .financingBills(let offer): executeOffer(offer)
        case .custome(_):
            let cardActionModifier = self.dependenciesResolver.resolve(for: CardHomeActionModifier.self)
            cardActionModifier.didSelectAction(action, entity)            
        default: break
        }
    }
    
    func didSelectAction(_ action: CardActionType, _ entity: CardEntity) {
        let card = CardFactory.getCard(entity)
        switch action {
        case .enable:
            guard let cardBoardingModfier = dependenciesResolver.resolve(forOptionalType: CardBoardingModifierProtocol.self),
                  cardBoardingModfier.alwaysActivateCardOnCardboarding() else {
                self.gotoActivateCard(card: card, entity: entity)
                return
            }
            self.goToCardBoardingActivation(card: entity)
        case .onCard: self.goToCardOnOff(card: entity, option: .turnOn)
        case .offCard: self.goToCardOnOff(card: entity, option: .turnOff)
        case .instantCash: goToDirectMoney(card, entity: entity)
        case .pin: showPINQueryCard(card, delegate: self)
        case .pdfExtract: dateForPdf(product: card)
        case .historicPdfExtract: goToHistoricExtractOperative(card.cardEntity)
        case .mobileTopUp: mobileTopUp(card: card, delegate: self)
        case .modifyLimits: goToCardLimitManagementOperative(card: card, delegate: self)
        case .chargeDischarge: showCardChargeDischargeCard(card, delegate: self)
        case .cvv: showCVVQueryCard(card, delegate: self)
        case .block:
            guard let cardBlockModifier = dependenciesResolver.resolve(forOptionalType: CardBlockModifierProtocol.self),
                  cardBlockModifier.isCardBlockAvailable() else {
                blockCard(card, delegate: self)
                return
            }
            self.goToCardBlock(card: entity)
        case .delayPayment: showPayLaterCard(card: card, delegate: self)
        case .payOff: goToPayOff(card, delegate: self)
        case .withdrawMoneyWithCode: showWithdrawMoneyWithCode(card, delegate: self)
        case .ces: signupCesCard(card, delegate: self)
        case .solidarityRounding(let offer): executeOffer(offer)
        case .changePaymentMethod: modifyPayment(product: card, delegate: self)
        case .hireCard(let location):
             guard let pullOffer = location else {
                 break }
             let offer = PullOfferLocation(stringTag: pullOffer.stringTag, hasBanner: pullOffer.hasBanner, pageForMetrics: pullOffer.pageForMetrics)
             goToHireCardOffer(offer)
        case .fraud(let offer): executeOffer(offer)
        case .divide(let operation):
                   guard let spliteableOperation = operation else {
                       break
                   }
                   self.goToSplitExpenses(operation: spliteableOperation)
        case .share: Toast.show(localized("generic_alert_notAvailableOperation"))
        case .chargePrepaid: showCardChargeDischargeCard(card, delegate: self)
        case .suscription(let offer): executeOffer(offer)
        case .configure: self.didSelectCardBoardingWelcome(card: entity)
        case .financingBills(let offer): executeOffer(offer)
        default: break
        }
    }
    
    func goToWebView(configuration: WebViewConfiguration) {
        self.dependencies.navigatorProvider.privateHomeNavigator.goToWebView(with: configuration, linkHandlerType: .pdfViewer, dependencies: self.dependencies, errorHandler: self.errorHandler, didCloseClosure: nil)
    }
}
extension CardsHomeCoordinatorNavigator: CardActivationLauncher, CardDirectMoneyLauncher, CardPINQueryCardLauncher, CardCVVQueryCardLauncher, CardLimitManagementLauncher, CardWithdrawalMoneyWithCodeLauncher, CardBlockCardLauncher, CardChargeDischargeLauncher, CardPayOffLauncher, CardMobileTopUpLauncher, CardPayLaterCardLauncher, CardCESSignUpLauncher, CardModifyPaymentFormLauncher, CardPdfLauncher, AddToApplePayOperativeLauncher, SystemSettingsNavigatable {
    
    var operativePresentationDelegate: OperativeLauncherPresentationDelegate? {
        return self
    }
    
    var origin: OperativeLaunchedFrom {
        return .home
    }
    
    var navigatorLauncher: OperativesNavigatorProtocol {
        return navigator
    }
}

private extension CardsHomeCoordinatorNavigator {
    var localAppConfig: LocalAppConfig {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    
    func goToHireCardOffer(_ location: PullOfferLocation?) {
        goToPublicProducts(delegate: self, location: location)
    }
    
    func didSelectCardBoardingWelcome(card: CardEntity) {
        self.dependenciesEngine.register(for: CardboardingConfiguration.self) { _ in
            return CardboardingConfiguration(card: card)
        }
        let productsNavigator = navigatorProvider.productsNavigator
        productsNavigator.showCardsHome(with: card, cardSection: .cardBoardingWelcome)
    }
    
    func transactionToCardMovement(_ transaction: CardTransactionEntity) -> CardMovement {
        return CardMovement(transaction: CardTransaction(transaction.dto))
    }
    
    func goToSplitExpenses(operation: SplitableExpenseProtocol) {
        guard let splitExpensesCoordinator: SplitExpensesCoordinatorLauncher = self.dependenciesResolver.resolve(forOptionalType: SplitExpensesCoordinatorLauncher.self) else { return }
        splitExpensesCoordinator.showSplitExpenses(operation)
    }
    
    func generatePdf(for card: CardEntity, holder: String?, fromDate: Date?, toDate: Date?, transactions: [CardTransactionEntityProtocol], showDisclaimer: Bool) {
        startLoading()
        guard let holder = holder else { return }
        let cardNumber = card.cardContract
        let info: CardTransactionListPdfHeaderInfo = CardTransactionListPdfHeaderInfo(holder: holder, cardNumber: cardNumber, fromDate: fromDate, toDate: toDate)
        pdfCreator = PDFCreator(renderer: CardTransactionListPrintPageRenderer(info: info, dependencies: dependencies))
        let builder = CardTransactionsPdfBuilder(stringLoader: dependencies.stringLoader, timeManager: dependencies.timeManager)
        builder.addHeader()
        builder.addTransactionsInfo(transactions)
        if showDisclaimer {
            builder.addDisclaimer()
        }
        self.pdfCreator?.createPDF(
            html: builder.build(),
            completion: { [weak self] data in
                self?.endLoading {
                    self?.navigatorProvider.productHomeNavigator.goToPdf(with: data, pdfSource: .accountHome, toolbarTitleKey: "toolbar_title_listTransactions")
                }
            }, failed: { [weak self] in
                self?.endLoading {
                    self?.showAlertError(keyTitle: nil, keyDesc: "generic_error_errorPdf", completion: nil)
                }
            }
        )
    }
}

extension CardsHomeCoordinatorNavigator: PublicProductsLauncher, PublicProductsLauncherDelegate {
    var offerPresenter: PullOfferActionsPresenter { self }
}

extension CardsHomeCoordinatorNavigator: EasyPayLauncher {}

extension CardsHomeCoordinatorNavigator: ApplePayWelcomeCoordinatorDelegate {
    
    func didSelectApplePay(card: CardEntity?, delegate: ApplePayEnrollmentDelegate) {
        if let entity = card {
            self.showAddToApplePay(card: Card(entity), delegate: self)
        } else {
            self.showAddToApplePay(card: nil, delegate: self)
        }
    }
}

extension CardsHomeCoordinatorNavigator: ApplePayEnrollmentDelegate {
    func applePayEnrollmentDidFinishSuccessfully() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let applePaySuccessView = ApplePaySuccessView()
        window.addSubview(applePaySuccessView)
        applePaySuccessView.fullFit()
    }
    
    func applePayEnrollmentDidFinishWithError(_ error: ApplePayError) {}
}

extension CardsHomeCoordinatorNavigator: CardBoardingCoordinatorDelegate {
    func goToSettings(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText, title: LocalizedStylableText?, body: LocalizedStylableText, cancelAction: (() -> Void)?) {
        let buttonAction: (() -> Void)?  = { [weak self] in
            self?.navigateToSettings()
        }
        guard let viewController = viewController else { return }
        let acceptComponents = DialogButtonComponents(titled: acceptTitle, does: buttonAction)
        let cancelComponents = DialogButtonComponents(titled: cancelTitle, does: cancelAction)
        Dialog.alert(title: nil, body: body, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: viewController)
    }
}

extension CardsHomeCoordinatorNavigator: HistoricExtractOperativeLauncher {
    func goToHistoricExtractOperative(_ card: CardEntity) {
        goToHistoricExtract(card, handler: self, externalDependencies: cardExternalDependencies)
    }
}

private extension CardsHomeCoordinatorNavigator {
    func gotoActivateCard(card: Card, entity: CardEntity) {
        guard let cardBoardingModifier = dependenciesResolver.resolve(forOptionalType: CardBoardingModifierProtocol.self),
              cardBoardingModifier.alwaysActivateCardOnCardboarding() else {
            if card.isPrepaidCard {
                activateCard(card, launchedFrom: origin, delegate: self)
            } else {
                self.goToCardBoardingActivation(card: entity)
            }
            return
        }
        self.goToCardBoardingActivation(card: entity)
    }
    
    func goToDirectMoney(_ card: Card, entity: CardEntity) {
        guard let isEnablePBI = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self).getBool(DirectMoneyConstants.appConfigEnablePBI),
              isEnablePBI else {
            goToDirectMoneyOperative(card: card, launchedFrom: origin, delegate: self)
            return
        }
        let productsNavigator = navigatorProvider.productsNavigator
        productsNavigator.showCardsHome(with: entity, cardSection: .directMoney)
    }
}
