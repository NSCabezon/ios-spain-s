//
//  TransfersHomeCoordinatorNavigator.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 12/24/19.
//  Copyright © 2019 Ciber. All rights reserved.
//

import SANLegacyLibrary
import GlobalPosition
import CoreDomain
import Foundation
import Transfer
import Operative
import CoreFoundationLib
import OpenCombine
import TransferOperatives

extension NSNotification.Name {
    static let transfersFaqsAnalytics: NSNotification.Name = .init("transfer_faqs")
}

final class TransfersHomeCoordinatorNavigator: ModuleCoordinatorNavigator {
    private var type: TransferActionType? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(forName: .transfersFaqsAnalytics, object: nil, queue: nil) { [weak self] (notification) in
                guard let userInfo = notification.userInfo,
                      let parameters = userInfo["parameters"] as? [String : String]
                else { return }
                var screenName = ""
                switch self?.type {
                case .transfer:
                    screenName = "send_money_transfers"
                case .transferBetweenAccounts:
                    screenName = "send_money_switch"
                default:
                    return
                }
                let event = parameters.keys.contains("faq_link") ? "click_link_faq" : "click_show_faq"
                self?.dependencies.trackerManager.trackEvent(screenId: screenName, eventId: event, extraParameters: parameters)
            }
        }
    }
    private var contactDetailModifier: ContactDetailModifierProtocol? {
        return dependenciesResolver.resolve(forOptionalType: ContactDetailModifierProtocol.self)
    }
    
    private var subscriptions: Set<AnyCancellable> = []
    private var launchOperativeSubject = PassthroughSubject<AccountEntity?, Never>()
    
    required init(drawer: BaseMenuViewController?,
                  dependencies: PresentationComponent,
                  navigator: OperativesNavigatorProtocol,
                  stringLoader: StringLoader,
                  dependenciesEngine: DependenciesResolver & DependenciesInjector,
                  coordinatorIdentifier: String) {
        super.init(drawer: drawer, dependencies: dependencies, navigator: navigator, stringLoader: stringLoader, dependenciesEngine: dependenciesEngine, coordinatorIdentifier: coordinatorIdentifier)
        bindLaunchOperative()
    }
}

extension TransfersHomeCoordinatorNavigator: ModifyDeferredTransferLauncher, ModifyPeriodicTransferLauncher {
    func modifyDeferredTransfer(account: AccountEntity, transfer: TransferScheduledEntity, transferDetail: ScheduledTransferDetailEntity) {
        showModifyDeferredTransfer(
            account: Account(dto: account.dto),
            transfer: TransferScheduled(dto: transfer.transferDTO),
            scheduledTransferDetail: ScheduledTransferDetail(dto: transferDetail.transferDetailDTO),
            delegate: self
        )
    }
    func modifyPeriodicTransfer(account: AccountEntity, transfer: TransferScheduledEntity, transferDetail: ScheduledTransferDetailEntity) {
        showModifyPeriodicTransfer(
            account: Account(dto: account.dto),
            transfer: TransferScheduled(dto: transfer.transferDTO),
            scheduledTransferDetail: ScheduledTransferDetail(dto: transferDetail.transferDetailDTO),
            delegate: self
        )
    }
}

extension TransfersHomeCoordinatorNavigator: TransferHomeModuleCoordinatorDelegate {
    
    func didSelectTransferAction(type: TransferActionType, account: AccountEntity?) {
        self.type = type
        switch type {
        case .transfer:
            self.didSelectTransfer(account)
        case .transferBetweenAccounts:
            self.didSelectTransferBetweenAccounts(account)
        case .onePayFX(let offer):
            self.didSelectOnePayFX(offer)
        case .atm:
            self.didSelectATMs()
        case .donations(let offer):
            self.didSelectDonations(account, offer)
        case .correosCash(let offer):
            self.didSelectCorreosCash(account, offer)
        case .reuse(let ibanEntity, let beneficiary):
            self.didSelectReuseFromAccount(account, iban: ibanEntity, beneficiary: beneficiary)
        default: break
        }
    }
    
    func didSelectVirtualAssistant() {
        openVirtualAssistant()
    }
    
    func didSelectNewContact() {
        if self.dependenciesResolver.resolve(forOptionalType: PreValidateNewFavouriteUseCaseProtocol.self) != nil {
            self.goToNewFavourite(handler: self)
        } else {
            self.showCreateUsualTransfer(delegate: self)
        }
    }
    
    func didSelectTransfer(_ account: AccountEntity?) {
        self.closeModalViewControllers { [weak self] in
            guard let self = self else { return }
            self.launchOperativeSubject.send(account)
        }
    }
    
    func didSelectReuseFromAccount(_ account: AccountEntity?, iban: IBANEntity, beneficiary: String) {
        guard let accountEntity = account else { return }
        let ibanModel = IBAN.create(fromCountryCode: iban.countryCode,
                                    checkDigits: iban.dto.checkDigits,
                                    codBban: iban.dto.codBban)
        self.showReuseTransferFromAccount(Account(accountEntity),
                                          iban: ibanModel,
                                          beneficiary: beneficiary,
                                          delegate: self)
    }
    
    func didSelectTransferBetweenAccounts(_ account: AccountEntity?) {
        self.closeModalViewControllers { [weak self] in
            self?.goToInternalTransfer(account: account)
        }
    }
    
    func closeNewShipmentView(_ completion: @escaping (() -> Void)) {
        self.closeModalViewControllers(completion)
    }
    
    func didSelectOnePayFX(_ offer: OfferEntity?) {
        self.closeModalViewControllers { [weak self] in
            guard let self = self else { return }
            self.executeOffer(action: offer?.action, offerId: offer?.id, location: PullOfferLocation.FXPAY_TRANSFER_HOME)
        }
    }
    
    func didSelectATMs() {
        self.closeModalViewControllers { [weak self] in
            guard let self = self else { return }
            self.showWithdrawMoneyWithCode(nil, delegate: self)
        }
    }
    
    func didSelectScheduleTransfers() {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func didSelectDonations(_ account: AccountEntity?, _ offer: OfferEntity?) {
        self.closeModalViewControllers { [weak self] in
            guard let self = self else { return }
            self.executeOffer(action: offer?.action, offerId: offer?.id, location: PullOfferLocation.TRANSFER_HOME_DONATIONS)
        }
    }
    
    func didSelectCorreosCash(_ account: AccountEntity?, _ offer: OfferEntity?) {
        self.closeModalViewControllers { [weak self] in
            guard let self = self else { return }
            self.executeOffer(action: offer?.action, offerId: offer?.id, location: PullOfferLocation.CORREOS_CASH_TRANSFER_HOME)
        }
    }
    
    func showTransferDetail(_ transfer: TransferEmittedEntity, fromAccount: AccountEntity?, toAccount: AccountEntity, presentationBlock: @escaping (TransferDetailConfiguration) -> Void) {
        self.closeModalViewControllers { [weak self] in
            guard let self = self else { return }
            if transfer.type == .sepa {
                self.showTransferDetailSepa(transfer, fromAccount: fromAccount, toAccount: toAccount, presentationBlock: presentationBlock)
            } else if transfer.type == .noSepa {
                self.showTransferDetailNoSepa(transfer, fromAccount: fromAccount, toAccount: toAccount)
            }
        }
    }
    
    func didSelectDismiss() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func didSelectMenu() {
        drawer?.toggleSideMenu()
    }
    
    func didSelectSearch() {
        navigatorProvider.privateHomeNavigator.goToGlobalSearch()
    }
    
    func showDialog(configuration: DialogConfiguration) {
        var error: LocalizedStylableText = .empty
        var titleError: LocalizedStylableText = .empty
        if let title = configuration.title {
            titleError = localized(title)
        }
        if let body = configuration.body {
            error = localized(body)
        }
        guard !error.text.isEmpty else {
            return self.showGenericErrorDialog(withDependenciesResolver: self.dependenciesEngine)
        }
        let acceptComponents = DialogButtonComponents(titled: localized(configuration.acceptTitle ?? ""), does: configuration.acceptAction)
        var cancelComponents: DialogButtonComponents?
        if let cancelTitle = configuration.cancelTitle {
            cancelComponents = DialogButtonComponents(titled: localized(cancelTitle), does: configuration.cancelAction)
        }
        Dialog.alert(title: titleError, body: error, withAcceptComponent: acceptComponents, withCancelComponent: cancelComponents, source: configuration.source)
    }
    
    func goToWebView(configuration: WebViewConfiguration) {
        self.dependencies.navigatorProvider.privateHomeNavigator.goToWebView(with: configuration, linkHandler: nil, dependencies: self.dependencies, errorHandler: self.errorHandler, didCloseClosure: nil)
    }
    
    func didSelectContact(contact: PayeeRepresentable, launcher: ModuleLauncher, delegate: ModuleLauncherDelegate) {
        self.navigatorProvider.privateHomeNavigator.didSelectContact(contact, launcher: launcher, delegate: delegate)
    }
}

private extension TransfersHomeCoordinatorNavigator {
    private func goToInternalTransfer(account: AccountEntity?) {
        launchTransferSection(.internalTransfer, selectedAccount: account)
    }
    
    private func showTransferDetailSepa(_ transferEmmitted: TransferEmittedEntity,
                                        fromAccount: AccountEntity?,
                                        toAccount: AccountEntity,
                                        presentationBlock: @escaping (TransferDetailConfiguration) -> Void) {
        let transfer = TransferEmitted(dto: transferEmmitted.dto)
        let input = GetEmittedTransferDetailUseCaseInput(transfer: transfer)
        let useCase = dependencies.useCaseProvider.getEmittedTransferDetailUseCase(input: input)
        self.startLoading()
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler
        ) { [weak self] response in
            guard let self = self else { return }
            self.hideAllLoadings(completion: {
                guard let transferDetail = response.transferEmittedDetail else { return }
                var accountOrigin: Account?
                if let fromAccount = fromAccount {
                    accountOrigin = Account(dto: fromAccount.dto)
                }
                let detail = TransferEmittedDetailData(transferDetail: transferDetail,
                                                       account: Account(dto: toAccount.dto),
                                                       transfer: transfer,
                                                       sepaInfo: response.sepaList,
                                                       originAccount: accountOrigin,
                                                       stringLoader: self.stringLoader,
                                                       dependencies: self.dependencies,
                                                       shareDelegate: self)
                let configuration = self.transferDetailConfigurationFromEmittedData(transferDetail: transferDetail,
                                                                                    transfer: transfer,
                                                                                    account: Account(dto: toAccount.dto),
                                                                                    sepaInfo: response.sepaList)
                presentationBlock(configuration)
            })
        } onError: { [weak self] error in
            self?.hideAllLoadings(completion: {
                self?.showAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            })
        }
    }
    
    private func transferDetailConfigurationFromEmittedData(transferDetail: EmittedTransferDetail, transfer: TransferEmitted, account: Account, sepaInfo: SepaInfoList) -> TransferDetailConfiguration {
        let baseURLProvider = self.dependenciesResolver.resolve(for: BaseURLProvider.self)
        var detailConfiguration = TransferDetailConfiguration(transferType: TransferDetailType.emitted(transferDetail: TransferEmittedDetailEntity(dto: transferDetail.transferDetailDTO),
                                                                                                       transfer: transfer.entity,
                                                                                                       account: account.accountEntity))
        if let dto = transferDetail.transferAmount?.amountDTO {
            detailConfiguration.config.append(TransferDetailConfiguration.Amount(amount: AmountEntity(dto),
                                                                                 concept: nil))
        }
        if let concept = transfer.concept {
            detailConfiguration.config.append(TransferDetailConfiguration.DefaultViewConfig(
                title: "deliveryDetails_label_concept",
                localized: localized(concept.camelCasedString),
                accessibilityIdentifier: TransferEmittedDetailAccessibilityIdentifier.concept
            ))
        }
        detailConfiguration.config.append(TransferDetailConfiguration.OriginAccount(
            title: "deliveryDetails_label_originAccount",
            beneficiary: localized(account.getAlias() ?? "generic_confirm_associatedAccount"),
            balance: " (\(account.getLongAmountUI()))",
            accessibilityIdentifier: TransferEmittedDetailAccessibilityIdentifier.transferEmittedLabelOriginAccount
        ))
        detailConfiguration.config.append(TransferDetailConfiguration.DefaultViewConfig(
            title: "deliveryDetails_label_sendType",
            content: transferDetail.transferDetailDTO.descTransferType?.camelCasedString,
            accessibilityIdentifier: TransferEmittedDetailAccessibilityIdentifier.transferEmittedLabelTransferType
        ))
        var bankIconUrl: String? {
            guard let entityCode = transferDetail.beneficiary?.ibanElec.substring(4, 8),
                  let contryCode = transferDetail.beneficiary?.countryCode,
                  let baseUrl = baseURLProvider.baseURL else { return nil }
            return String(format: "%@%@/%@_%@%@", baseUrl,
                          GenericConstants.relativeURl,
                          contryCode.lowercased(),
                          entityCode,
                          GenericConstants.iconBankExtension)
        }
        detailConfiguration.config.append(TransferDetailConfiguration.DestinationAccount(
            beneficiary: transfer.beneficiary?.camelCasedString,
            iban: transferDetail.beneficiary?.formatted,
            bankIconUrl: bankIconUrl
        ))
        detailConfiguration.maxViewsNotExpanded = detailConfiguration.config.count
        let country = sepaInfo.getSepaCountryInfo(transferDetail.beneficiary?.countryCode).name
        let currency = sepaInfo.getSepaCurrencyInfo(transfer.amount?.currency?.currencyName).name
        detailConfiguration.config.append(TransferDetailConfiguration.DefaultViewConfig(
            title: "deliveryDetails_label_destinationCountry",
            content: "\(country) - \(currency)",
            accessibilityIdentifier: TransferEmittedDetailAccessibilityIdentifier.transferEmittedLabelDestinationCountry
        ))
        let emissionDate = dateToString(date: transferDetail.emisionDate, outputFormat: .dd_MMM_yyyy)
        detailConfiguration.config.append(TransferDetailConfiguration.DefaultViewConfig(
            title: "deliveryDetails_label_issuanceDate",
            content: emissionDate,
            accessibilityIdentifier: TransferEmittedDetailAccessibilityIdentifier.transferEmittedLabelEmissionDate
        ))
        let valueDate = dateToString(date: transferDetail.valueDate, outputFormat: .dd_MMM_yyyy)
        detailConfiguration.config.append(TransferDetailConfiguration.DefaultViewConfig(
            title: "deliveryDetails_label_valueDate",
            content: valueDate,
            accessibilityIdentifier: TransferEmittedDetailAccessibilityIdentifier.transferEmittedLabelValueDate
        ))
        detailConfiguration.config.append(TransferDetailConfiguration.DefaultViewConfig(
            title: "deliveryDetails_label_commission",
            content: transferDetail.fees?.getFormattedAmountUI(),
            accessibilityIdentifier: TransferEmittedDetailAccessibilityIdentifier.transferEmittedLabelFee
        ))
        detailConfiguration.config.append(TransferDetailConfiguration.DefaultViewConfig(
            title: "deliveryDetails_label_amountToDebt",
            content: transferDetail.totalAmount?.getFormattedAmountUI(),
            accessibilityIdentifier: TransferEmittedDetailAccessibilityIdentifier.amount
        ))
        return detailConfiguration
    }
    
    private func showTransferDetailNoSepa(_ transferEmmitted: TransferEmittedEntity,
                                          fromAccount: AccountEntity?,
                                          toAccount: AccountEntity) {
        let transfer = TransferEmitted(dto: transferEmmitted.dto)
        let input = GetEmittedNoSepaTransferDetailUseCaseInput(transfer: transfer)
        let useCase = useCaseProvider.getEmittedNoSepaTransferDetailUseCase(input: input)
        self.startLoading()
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler
        ) { [weak self] response in
            guard let self = self else { return }
            self.hideAllLoadings(completion: {
                guard let transferDetail = response.noSepaTransferEmittedDetail else { return }
                
                var accountOrigin: Account?
                if let fromAccount = fromAccount {
                    accountOrigin = Account(dto: fromAccount.dto)
                }
                let detail = NoSepaTransferEmittedDetailData(transferDetail: transferDetail,
                                                             account: Account(dto: toAccount.dto),
                                                             transfer: transfer,
                                                             sepaInfo: response.sepaList,
                                                             originAccount: accountOrigin,
                                                             stringLoader: self.stringLoader,
                                                             dependencies: self.dependencies,
                                                             shareDelegate: self)
                self.navigatorProvider.transfersHomeNavigator.navigateToTransferDetail(with: detail)
            })
        } onError: { [weak self] error in
            self?.hideAllLoadings(completion: {
                self?.showAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            })
        }
    }
    
    func bindLaunchOperative() {
        launchOperativeSubject
            .flatMap(fetchDomesticSendMoney)
            .sink { [unowned self] (flag, account) in
                guard !flag else {
                    self.goToSendMoney(handler: self, account: account?.representable)
                    return
                }
                guard let account = account else {
                    self.showTransfer(nil, delegate: self)
                    return
                }
                self.showTransfer(Account(account), delegate: self)
            }
            .store(in: &subscriptions)
    }
    
    func fetchDomesticSendMoney(_ account: AccountEntity?) -> AnyPublisher<(Bool, AccountEntity?), Never> {
        let booleanFeatureFlag = self.dependenciesResolver.resolve(for: BooleanFeatureFlag.self)
        return booleanFeatureFlag
            .fetch(CoreFeatureFlag.domesticSendMoney)
            .map { resp in
                (resp,account)
            }
            .eraseToAnyPublisher()
    }
}

extension TransfersHomeCoordinatorNavigator: TransferLauncher, LegacyInternalTransferLauncher, CardWithdrawalMoneyWithCodeLauncher, UpdateUsualTransferOperativeLauncher, UpdateNoSepaUsualTransferOperativeLauncher, NewFavouriteLauncher, CreateUsualTransferOperativeLauncher, ReemittedNoSepaTransferLauncher, DeleteFavouriteLauncher, DeleteScheduledTransferLauncher, EditFavouriteLauncher {
    var origin: OperativeLaunchedFrom {
        return .home
    }
    
    var transferExternalDependencies: OneTransferHomeExternalDependenciesResolver {
        return dependencies.navigatorProvider.legacyExternalDependenciesResolver
    }
}

extension TransfersHomeCoordinatorNavigator: ShowShareType {
    func shareContent(_ content: String) {
        guard let viewController = self.viewController else { return }
        ShareCase.share(content: content).show(from: viewController)
    }
}

extension TransfersHomeCoordinatorNavigator: ScheduledTransfersCoordinatorDelegate {
    func deleteScheduledOrder(_ order: ScheduledTransferRepresentable, account: AccountEntity, detail: ScheduledTransferDetailEntity) {
        self.deleteStandingOrder(order, account: account, detail: detail, handler: self)
    }
    
    func didSelectNewShipment(for account: AccountEntity?) {
        if let account = account {
            self.showTransfer(Account(account), delegate: self)
        } else {
            self.showTransfer(nil, delegate: self)
        }
    }
    
    func didSelectScheduledTransferDetail(for entity: ScheduledTransferEntity,
                                          account: AccountEntity, originAcount: AccountEntity?) {
        let transfer = TransferScheduled(dto: entity.transferDTO)
        let account = Account(account)
        var destinationAccount: Account?
        let input = GetScheduledTransferDetailUseCaseInput(account: account, transfer: transfer)
        let useCase = self.useCaseProvider.getScheduledTransferDetailUseCase(input: input)
        self.startLoading()
        if let account = originAcount {
            destinationAccount = Account(account)
        }
        
        UseCaseWrapper(
            with: useCase.setRequestValues(requestValues: input),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] response in
                guard let detail = response.scheduledTransferDetail else { return }
                guard let self = self else { return }
                self.hideAllLoadings {
                    let detail = TransferScheduledDetailData(
                        transferDetail: detail,
                        account: account,
                        transfer: transfer,
                        sepaInfo: response.sepaList,
                        originAccount: destinationAccount,
                        stringLoader: self.stringLoader,
                        dependencies: self.dependencies,
                        shareDelegate: self)
                    self.navigatorProvider.transfersHomeNavigator.navigateToTransferDetail(with: detail)
                }
            }, onError: { [weak self] error in
                self?.hideAllLoadings {
                    self?.showAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                }
            }
        )
    }
}

extension TransfersHomeCoordinatorNavigator: ChatInbentaLauncher {
    var chatInbentaNavigator: BaseWebViewNavigatable {
        return baseWebViewNavigatable
    }
}

extension TransfersHomeCoordinatorNavigator: ContactDetailCoordinatorDelegate {
    func didSelectUpdateFavorite(favoriteType: CoreFoundationLib.FavoriteType) {
        if self.contactDetailModifier != nil {
            self.goToEditFavourite(selectedFavouriteType: favoriteType, handler: self)
        } else {
            let entity = Favourite(favorite: favoriteType.favorite)
            self.showUpdateUsualTransfer(favourite: entity, delegate: self)
        }
    }
    
    func didDeleteFavourite(favoriteType: CoreFoundationLib.FavoriteType) {
        self.deleteFavourite(favoriteType: favoriteType, handler: self)
    }
    
    func didSelectUpdateNoSepaFavorite(favorite: PayeeRepresentable, noSepaPayeeDetailEntity: NoSepaPayeeDetailEntity) {
        let favorite = Favourite(favorite: favorite)
        let noSepaPayeeDetail = NoSepaPayeeDetail(entity: noSepaPayeeDetailEntity)
        self.showUpdateNoSepaFavourite(favorite, noSepaDetail: noSepaPayeeDetail, delegate: self)
    }
    
    func didSelectNewShipment(favorite: PayeeRepresentable, accountEntity: AccountEntity?) {
        let favorite = Favourite(favorite: favorite)
        let fromAccount: Account? = accountEntity.map { Account($0) }
        self.showUsualTransfer(fromAccount, favourite: favorite, delegate: self)
    }
    
    func didSelectNoSepaNewShipment(_ favorite: PayeeRepresentable, accountEntity: AccountEntity?, noSepaPayeeDetailEntity: NoSepaPayeeDetailEntity) {
        let favorite = Favourite(favorite: favorite)
        let fromAccount: Account? = accountEntity.map { Account($0) }
        let noSepaPayeeDetail = NoSepaPayeeDetail(entity: noSepaPayeeDetailEntity)
        self.showReemittedNoSepaTransfer(transferDetail: noSepaPayeeDetail, account: fromAccount, delegate: self, launchedFrom: .favorite, accountType: favorite.accountType)
    }
    
    func didSelectTransferForFavorite(_ favorite: PayeeRepresentable, accountEntity: AccountEntity?, enabledFavouritesCarrusel: Bool) {
        let fromAccount: Account? = accountEntity.map { Account($0) }
        let favourite = Favourite(favorite: favorite)
        self.didSelectTransferForFavorite(favourite, account: fromAccount, enabledFavouritesCarrusel: enabledFavouritesCarrusel, delegate: self)
    }
}

// MARK: - SendMoneyOperativeLauncher
extension TransfersHomeCoordinatorNavigator: SendMoneyOperativeLauncher { }
