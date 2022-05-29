//
//  AccountsHomeCoordinatorNavigator.swift
//  RetailClean
//
//  Created by Jose Carlos Estela Anguita on 12/11/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//

import TransferOperatives
import CoreFoundationLib
import CoreDomain
import PdfCommons
import Transfer
import Account
import Bills
import OpenCombine

final class AccountsHomeCoordinatorNavigator: ModuleCoordinatorNavigator {
    private var pdfCreator: PDFCreator?
    private var subscriptions: Set<AnyCancellable> = []
    private var localAppConfig: LocalAppConfig {
        self.dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    private var accountNumberFormatter: AccountNumberFormatterProtocol? {
        self.dependenciesResolver.resolve(forOptionalType: AccountNumberFormatterProtocol.self)
    }
    
    var internalTransferDependencies: InternalTransferLauncherDependenciesResolver {
        return dependencies.navigatorProvider.legacyExternalDependenciesResolver
    }
        
    func didSelectAction(action: AccountActionType, entity: AccountEntity?) {
        switch action {
        case .billsAndTaxes: navigatorProvider.accountProfileNavigator.goToBillsAndTaxes(account: entity)
        case .requestMoney: Toast.show(localized("generic_alert_notAvailableOperation"))
        case .transfer: self.goToTransfers(account: entity)
        case .internalTransfer: goToInternalTransfer(account: entity?.representable)
        case .favoriteTransfer: navigatorProvider.accountProfileNavigator.goToTransfers(account: entity)
        case .fxPay(let offer): self.executeOffer(offer)
        case .payBill:
            didSelectPayment(accountEntity: entity, type: .bills)
        case .payTax:
            didSelectPayment(accountEntity: entity, type: .taxes)
        case .returnBill: navigatorProvider.accountProfileNavigator.goToBillsAndTaxes(account: entity)
        case .foreignExchange(let offer): self.executeOffer(offer)
        case .changeDomicileReceipt: navigatorProvider.privateHomeNavigator.goToDirectDebitBillAndTaxes(entity)
        case .donation(let offer): self.executeOffer(offer)
        case .cancelBill:
            navigatorProvider.accountProfileNavigator.goToBillsAndTaxes(account: entity)
        case .accountDetail: goToAccountDetail(withAccount: entity)
        case .historicalEmitted: navigatorProvider.accountProfileNavigator.goToHistoricalEmittedTransfer(account: entity)
        case .one(let offer): self.executeOffer(offer)
        case .ownershipCertificate(let offer): self.executeOffer(offer)
        case .contractAccount(let location): self.goToHireOffer(location)
        case .correosCash(let offer): self.executeOffer(offer)
        case .receiptFinancing(let offer): self.executeOffer(offer)
        case .automaticOperations(let offer): self.executeOffer(offer)
        case .custome: return
        }
    }
    
    func didSelectDetail(for account: AccountEntity) {
        let account = Account(account)
        let useCase = dependencies.useCaseProvider.getAccountDetailUseCase(input: GetAccountDetailUseCaseInput(account: account))
        startLoading()
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] result in
                self?.hideAllLoadings { [weak self] in
                    self?.navigatorProvider.productHomeNavigator.goToProductDetail(product: account, productDetail: result.getAccountDetail(), .accounts)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    self?.showAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                }
            }
        )
    }
    
    func didSelectSearch() {
        if self.localAppConfig.isEnabledMagnifyingGlass {
            self.navigatorProvider.privateHomeNavigator.goToGlobalSearch()
        } else {
            Toast.show(localized("generic_alert_notAvailableOperation"))
        }
    }
    
    func didSelectDownloadTransactions(for account: AccountEntity, withFilters: TransactionFiltersEntity?, withScaSate scaState: ScaState?) {
        loadPdf(for: Account(account), withFilters: withFilters, scaState: scaState)
    }
    
    func didGenerateTransactionsPDF(for account: AccountEntity, holder: String?, fromDate: Date?, toDate: Date?, transactions: [AccountTransactionEntity], showDisclaimer: Bool) {
        generatePdf(for: account, holder: holder, fromDate: fromDate, toDate: toDate, transactions: transactions, showDisclaimer: showDisclaimer)
    }
    
    func didSelectDismiss() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func didSelectMenu() {
        drawer?.toggleSideMenu()
    }
    
    func didSelectTransaction(_ transaction: AccountTransactionEntity, in transactions: [AccountTransactionEntity], for account: AccountEntity) {
        navigatorProvider.productHomeNavigator.goToTransactionDetail(
            product: Account(account),
            transactions: transactions.map({ AccountTransaction($0.dto) }),
            selectedPosition: transactions.firstIndex(where: { $0 == transaction }) ?? 0,
            productHome: .accounts,
            syncDelegate: nil,
            optionsDelegate: nil
        )
    }
    
    func didSelectShare(for account: AccountEntity) {
        Toast.show(localized("generic_alert_notAvailableOperation"))
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
    
    func goToAccountsOTP(delegate: OtpScaAccountPresenterDelegate, scaTransactionParams: SCATransactionParams) {
        self.dependencies.navigatorProvider.productHomeNavigator.goToLisboaAccountsOTP(delegate: delegate, scaTransactionParams: scaTransactionParams)
    }
    
    override func executeOffer(_ offer: OfferRepresentable?) {
        guard let offer = offer else { return }
        super.executeOffer(offer)
    }
    
    func goToWebView(configuration: WebViewConfiguration) {
        self.dependencies.navigatorProvider.privateHomeNavigator.goToWebView(with: configuration, linkHandlerType: .pdfViewer, dependencies: self.dependencies, errorHandler: self.errorHandler, didCloseClosure: nil)
    }

    func showLoading() {
        self.startLoading()
    }
}

extension AccountsHomeCoordinatorNavigator: AccountsHomeCoordinatorDelegate {}
extension AccountsHomeCoordinatorNavigator: LegacyInternalTransferLauncher {
    var transferExternalDependencies: OneTransferHomeExternalDependenciesResolver {
        return dependencies.navigatorProvider.legacyExternalDependenciesResolver
    }
}

extension AccountsHomeCoordinatorNavigator: AccountTransactionDetailCoordinatorDelegate {
    func didSelectAction(_ action: AccountTransactionDetailAction,
                         _ transaction: AccountTransactionEntity,
                         detail: AccountTransactionDetailEntity?,
                         account: AccountEntity) {
        switch action {
        case .pdf: self.goToPdf(account: account, transaction: transaction)
        case .transfers: self.goToTransfers(account: account)
        case .billsAndTaxes, .returnBill: self.goToBillsAndTaxes(account: account)
        case .share: self.goToShare(transaction: transaction)
        case .splitExpense(let operation):
            if let operation = operation {
                self.goToSplitExpenses(operation: operation)
            }
        case .payBill: self.goToPayBill()
        }
    }
    
    func didSelectOffer(offer: OfferEntity) {
        self.executeOffer(offer)
    }
}

private extension AccountsHomeCoordinatorNavigator {
    func goToHireOffer(_ location: PullOfferLocation?) {
        goToPublicProducts(delegate: self, location: location)
    }
    
    func goToAccountDetail(withAccount entity: AccountEntity?) {
        guard let accountEntity = entity else { return }
        let account = Account(accountEntity)
        let useCase = dependencies.useCaseProvider.getAccountDetailUseCase(input: GetAccountDetailUseCaseInput(account: account))
        startLoading()
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] result in
                self?.hideAllLoadings { [weak self] in
                    self?.navigatorProvider.productHomeNavigator.goToProductDetail(product: account, productDetail: result.getAccountDetail(), .accounts)
                }
            },
            onError: { [weak self] error in
                self?.hideAllLoadings { [weak self] in
                    self?.showAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                }
            }
        )
    }
    
    func goToShare(transaction: AccountTransactionEntity) {
        Toast.show(localized("generic_alert_notAvailableOperation"))
    }
    
    func goToTransfers(account: AccountEntity?) {
        let booleanFeatureFlag: BooleanFeatureFlag = self.dependencies.useCaseProvider.dependenciesResolver.resolve()
        booleanFeatureFlag.fetch(CoreFeatureFlag.transferHome)
            .filter { $0 == true }
            .sink { [unowned self] _ in
                let homeCoordinator = self.transferExternalDependencies.oneTransferHomeCoordinator()
                if let account = account {
                    _ = homeCoordinator.set(account.representable)
                }
                homeCoordinator.start()
            }.store(in: &subscriptions)
        booleanFeatureFlag.fetch(CoreFeatureFlag.transferHome)
            .filter { $0 == false }
            .sink { [unowned self] _ in
                self.navigatorProvider.transferHomeNavigator.gotoTransferHome(for: account)
            }.store(in: &subscriptions)
    }
    
    func goToBillsAndTaxes(account: AccountEntity) {
        self.navigatorProvider.accountProfileNavigator.goToBillsAndTaxes(account: account)
    }
    
    func goToPdf(account: AccountEntity, transaction: AccountTransactionEntity) {
        self.startLoading()
        let input = GetAccountPdfTransactionUseCaseInput(account: Account(account), transaction: AccountTransaction(entity: transaction))
        let useCase = self.dependencies.useCaseProvider.getAccountPdfTransactionUseCase(input: input)
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: self.dependencies.useCaseHandler,
            errorHandler: self.errorHandler,
            onSuccess: { [weak self] response in
                self?.hideAllLoadings {
                    self?.navigatorProvider.productHomeNavigator.goToPdf(with: response.document, pdfSource: .accountTransactionDetail)
                }
            }, onError: { [weak self] error in
                self?.hideAllLoadings {
                    self?.showAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                }
            }
        )
    }
    
    func goToSplitExpenses(operation: SplitableExpenseProtocol) {
        guard let splitExpensesCoordinator: SplitExpensesCoordinatorLauncher = self.dependenciesResolver.resolve(forOptionalType: SplitExpensesCoordinatorLauncher.self) else { return }
        splitExpensesCoordinator.showSplitExpenses(operation)
    }
    
    func goToPayBill() {
        guard let payBillModifier: AccountTransactionDetailCustomActionModifierProtocol = self.dependenciesResolver.resolve(forOptionalType: AccountTransactionDetailCustomActionModifierProtocol.self) else { return }
        payBillModifier.getPayBillAction()
    }
}

private extension AccountsHomeCoordinatorNavigator {
    func loadPdf(for account: Account, withFilters: TransactionFiltersEntity?, scaState: ScaState?) {
        startLoading()
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getAccountDetailUseCase(input: GetAccountDetailUseCaseInput(account: account)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] result in
                self?.createTransactionsPdf(for: result.getAccountDetail(), withFilters: withFilters, scaState: scaState, holder: result.getHolder())
            }, onError: { [weak self] _ in
                self?.endLoading {
                    self?.showAlertError(keyTitle: nil, keyDesc: "generic_error_errorPdf", completion: nil)
                }
            }
        )
    }
    
    func createTransactionsPdf(for account: AccountDetail, withFilters: TransactionFiltersEntity?, scaState: ScaState?, holder: String?) {
        guard
            let holder = holder,
            let ibanDto = account.accountDTO.iban,
            let availableAmount = account.getAvailableAmount()
            else {
                self.endLoading {
                    self.showAlertError(keyTitle: nil, keyDesc: "generic_error_errorPdf", completion: nil)
                }
                return
        }
        var searchParameters: AccountSearchParameters?
        if let filters = withFilters {
            searchParameters = AccountSearchParameters(
                searchString: filters.getTransactionDescription(),
                dateRange: DateRangeSearchParameters(dateFrom: filters.getDateRange()?.fromDate, dateTo: filters.getDateRange()?.toDate),
                amountFrom: filters.fromAmountDecimal?.getLocalizedStringValue(),
                amountTo: filters.toAmountDecimal?.getLocalizedStringValue(),
                transactionType: TransactionOperationType(filters.getTransactionOperationType()),
                concept: AccountConcept(filters.getMovementType()), accountEasyPay: nil)
        }
        let ibanEntity = IBANEntity(ibanDto)
        let iban = self.accountNumberFormatter?.getIBANFormatted(ibanEntity) ?? IBAN(dto: ibanEntity.dto).description
        let info: AccountTransactionListPdfHeaderInfo = AccountTransactionListPdfHeaderInfo(holder: holder, iban: iban, undrawnBalance: availableAmount, fromDate: searchParameters?.dateRange.dateFrom, toDate: searchParameters?.dateRange.dateTo)
        pdfCreator = PDFCreator(renderer: AccountTransactionListPrintPageRenderer(info: info, dependencies: dependencies))
        let builder = AccountTransactionsPdfBuilder(stringLoader: dependencies.stringLoader, timeManager: dependencies.timeManager)
        let dateScaBloqued: Date? = {
            switch scaState {
            case .notApply?, .none:
                return nil
            case .error(date: let date), .requestOtp(date: let date), .temporaryLock(date: let date):
                return date
            }
        }()
        UseCaseWrapper(
            with: dependencies.useCaseProvider.getAccounTransactionsListPdfUseCase(input: AccounTransactionsListPdfUseCaseInput(account: account, filters: searchParameters, dateScaBloqued: dateScaBloqued)),
            useCaseHandler: dependencies.useCaseHandler,
            errorHandler: errorHandler,
            onSuccess: { [weak self] result in
                builder.addHeader()
                builder.addTransactionsInfo(result.transactions)
                self?.pdfCreator?.createPDF(
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
            }, onGenericErrorType: { [weak self] _ in
                self?.endLoading {
                    self?.showAlertError(keyTitle: nil, keyDesc: "generic_error_errorPdf", completion: nil)
                }
            }
        )
    }
    
    func generatePdf(for account: AccountEntity, holder: String?, fromDate: Date?, toDate: Date?, transactions: [AccountTransactionEntity], showDisclaimer: Bool) {
        startLoading()
        guard let holder = holder, let ibanEntity = account.getIban(), let availableAmountdto = account.availableAmount?.dto else {
            self.endLoading {
                self.showAlertError(keyTitle: nil, keyDesc: "generic_error_errorPdf", completion: nil)
            }
            return
        }
        let transactionsTransformed = transactions.map({ entity in
            AccountTransaction(entity.dto)
        })
        let iban = self.accountNumberFormatter?.getIBANFormatted(ibanEntity) ?? IBAN(dto: ibanEntity.dto).description
        let info: AccountTransactionListPdfHeaderInfo = AccountTransactionListPdfHeaderInfo(holder: holder, iban: iban, undrawnBalance: Amount.createFromDTO(availableAmountdto), fromDate: fromDate, toDate: toDate)
        pdfCreator = PDFCreator(renderer: AccountTransactionListPrintPageRenderer(info: info, dependencies: dependencies))
        let builder = AccountTransactionsPdfBuilder(stringLoader: dependencies.stringLoader, timeManager: dependencies.timeManager)
        builder.addHeader()
        builder.addTransactionsInfo(transactionsTransformed)
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
    
    func goToInternalTransfer(account: AccountRepresentable?) {
        let internalTransferLauncher: InternalTransferLauncher = self.transferExternalDependencies.resolve()
        if let account = account {
            internalTransferLauncher.set(account)
        }
        internalTransferLauncher.start()
    }
}

extension AccountsHomeCoordinatorNavigator: BillsAndTaxesScannerLauncher {
    func didSelectPayment(accountEntity: AccountEntity?, type: BillsAndTaxesTypeOperativePayment?) {
        self.showBillsAndTaxesScannerOperative(accountEntity.map({ Account($0) }), type: type, delegate: self)
    }
}
extension AccountsHomeCoordinatorNavigator: PublicProductsLauncher, PublicProductsLauncherDelegate {
    var offerPresenter: PullOfferActionsPresenter { self }
}
