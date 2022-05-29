import CoreFoundationLib
import Menu
import Cards
import CoreDomain
import PersonalArea

final class MenuCoordinatorNavigator: ModuleCoordinatorNavigator { }

extension MenuCoordinatorNavigator: HelperCenterCoordinatorProtocol {
    func goToWhatsapp(_ urlWhatsapp: URL) {
        if UIApplication.shared.canOpenURL(urlWhatsapp) {
            UIApplication.shared.open(url: urlWhatsapp)
        }
    }
    
    func didSelectMenu() {
        drawer?.toggleSideMenu()
    }
    
    func didSelectDismiss() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func didSelectSearch() {
        navigatorProvider.privateHomeNavigator.goToGlobalSearch()
    }
    
    func didSelectOffer(_ offer: OfferRepresentable?) {
        guard let offer = offer else { return }
        self.executeOffer(offer)
    }
    
    func didSelectedGetMoneyWithCode() {
        showWithdrawMoneyWithCode(nil, delegate: self)
    }
    
    func didSelectedCardLimitManagement() {
        goToCardLimitManagementOperative(card: nil, delegate: self)
    }
    
    func didSelectSearchAtm() {
        navigatorProvider.privateHomeNavigator.goToATMLocator(keepingNavigation: true)
    }
    
    func goToWebview() {
        openVirtualAssistant()
    }

    func goToHomeTips() {
        guard let navigationController = self.viewController?.navigationController else { return }
        let coordinator = self.dependenciesResolver.resolve(for: RetailLegacyExternalDependenciesResolver.self).publicMenuHomeTipsCoordinator()
        coordinator.start()
    }

    func showTransactionDetailFromBalanceEntities(_ transactions: [AccountTransactionWithAccountEntity], selectedTransaction: AccountTransactionWithAccountEntity) {
        let transactionsList = transactions.sorted(by: { ($0.accountTransactionEntity.operationDate ?? Date()).compare($1.accountTransactionEntity.operationDate ?? Date()) == .orderedDescending })
        navigatorProvider.privateHomeNavigator.showAccountTransaction(selectedTransaction.accountTransactionEntity,
                                                                in: transactionsList,
                                                                for: selectedTransaction.accountEntity,
                                                                associated: true)
    }

    func didSelectEmergency(action: HelpCenterEmergencyAction) {
        switch action {
        case .blockSign:
            self.goToSignature()
        case .pin:
            showPINQueryCard(nil, delegate: self)
        case .cvv:
            showCVVQueryCard(nil, delegate: self)
        case .cash:
            showWithdrawMoneyWithCode(nil, delegate: self)
        case .changeMagic:
            goToChangePassword(handler: self)
        case .sendMoney:
            navigatorProvider.privateHomeNavigator.goToTransfers(section: .home)
        case .chat:
            gotoChat()
        default:
            return
        }
    }
    
    private func gotoChat() {
        openChatInbenta()
    }
    
    func goToPhoneCall(_ phoneNumber: String) {
        guard let phone = URL(string: "tel://\(phoneNumber.replacingOccurrences(of: " ", with: ""))") else { return }
        open(phone)
    }
    
    func goToGlobalSearch() {
        navigatorProvider.privateHomeNavigator.goToGlobalSearch()
    }
    
    func didSelectCard(_ card: CardEntity, transactionList: [CardTransactionEntity], transaction: CardTransactionEntity) {
        let productsNavigator = navigatorProvider.productsNavigator
        self.dependenciesEngine.register(for: CardTransactionDetailConfiguration.self) { _ in
            return CardTransactionDetailConfiguration(selectedCard: card, selectedTransaction: transaction, allTransactions: transactionList)
        }
        self.navigatorProvider.dependenciesEngine.register(for: CardsHomeModuleCoordinatorDelegate.self) { _ in
                   return self.navigatorProvider.getModuleCoordinator(type: CardsHomeCoordinatorNavigator.self)
        }
        productsNavigator.showCardsHome(with: card, cardSection: .detail)
    }
    
    func didSelectHireCard(_ location: PullOfferLocation?) {
        goToPublicProducts(delegate: self, location: location)
    }
    
    func didSelectPurchase(_ card: CardEntity, movementId: String, movements: [FinanceableMovementEntity]) {
        self.dependenciesEngine.register(for: FractionablePurchaseDetailConfiguration.self) { _ in
            return FractionablePurchaseDetailConfiguration(
                card: card,
                movementID: movementId,
                movements: movements
            )
        }
        let coordinator = FractionablePurchaseDetailCoordinator(
            dependenciesResolver: dependenciesEngine,
            navigationController: viewController?.navigationController ?? UINavigationController()
        )
        coordinator.start()
    }
}

extension MenuCoordinatorNavigator: UrlActionsCapable {}

extension MenuCoordinatorNavigator: ChatInbentaLauncher {
    var chatInbentaNavigator: BaseWebViewNavigatable {
        return baseWebViewNavigatable
    }
}

extension MenuCoordinatorNavigator: CardCVVQueryCardLauncher, CardPINQueryCardLauncher, CardWithdrawalMoneyWithCodeLauncher, CardLimitManagementLauncher, ComingFeaturesCoordinatorDelegate, OldAnalysisAreaCoordinatorDelegate, FinancingCoordinatorDelegate, AtmCoordinatorDelegate, ChangePasswordLauncher {

    func didSelectAdobeTargetOffer(_ viewModel: AdobeTargetOfferViewModel) {
        let useCase = AdobeTargetOfferURLConfigurationUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase, input: AdobeTargetOfferURLConfigurationUseCaseInput(viewModel: viewModel))
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                guard let adobeWebConfiguration = response.urlConfiguration else { return }
                self?.navigatorProvider.privateHomeNavigator.goToWebView(configuration: adobeWebConfiguration, type: .adobeTarget, didCloseClosure: nil)
            }
            .onError { _ in }
    }
    
    func didSelectShowFractionablePayments(_ paymentType: PaymentBoxType) {
        let useCase = GetFractionablePaymentWebViewConfigurationUseCase(dependenciesResolver: self.dependenciesResolver)
        Scenario(useCase: useCase, input: GetFractionablePaymentWebViewConfigUseCaseInput(type: paymentType))
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                self?.navigatorProvider.privateHomeNavigator.goToWebView(configuration: response.webViewConfiguration,
                                                                         type: nil,
                                                                         didCloseClosure: nil)
            }
            .onError { _ in }
    }

    func didSelectCardFinanciableTransaction(_ card: CardEntity, transactionList: [CardTransactionEntity], transaction: CardTransactionEntity) {
        self.gotoCardTransactionDetail(card: card, selectedTransaction: transaction, in: transactionList)
    }
    
    func didSelectTryFeatures() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func didSelectNewFeature(withOpinator opinator: OpinatorInfoRepresentable) {
        self.handleOpinator(opinator)
    }
}

// MARK: - SignatureLauncherDelegate

extension MenuCoordinatorNavigator: SignatureLauncher {
    var signatureLauncherNavigator: OperativesNavigatorProtocol {
        return self.navigator
    }
    
    func showError(keyDesc: String?) {
        self.showAlertError(keyTitle: nil, keyDesc: keyDesc, completion: nil)
    }
}
extension MenuCoordinatorNavigator: EasyPayLauncher {}
extension MenuCoordinatorNavigator: FinanceableTransactionCoordinatorDelegate {
    
    func gotoCardTransactionDetail(card: CardEntity, selectedTransaction: CardTransactionEntity, in transactionList: [CardTransactionEntity]) {
        let transactionsWithCard = transactionList.map({CardTransactionWithCardEntity(cardTransactionEntity: $0, cardEntity: card) })
        self.navigatorProvider.privateHomeNavigator.showCardTransaction(selectedTransaction, in: transactionsWithCard, for: card)
    }
}

extension MenuCoordinatorNavigator: PublicProductsLauncher, PublicProductsLauncherDelegate {
    var offerPresenter: PullOfferActionsPresenter { self }
}

extension MenuCoordinatorNavigator: AccountFinanceableTransactionCoordinatorDelegate {}
