//
//  SpainGetAccountTransactionsUseCase.swift
//  Santander
//
//  Created by Hernán Villamil on 1/3/22.
//

import Account
import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import OpenCombine

class SpainGetAccountTransactionsUseCase: UseCase<GetAccountTransactionsUseCaseInput, GetAccountTransactionsUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    private let appConfig: AppConfigRepositoryProtocol
    private let pfmController: PfmControllerProtocol
    private let useCaseHandler: UseCaseHandler
    private let setReadAccountTransactionsUseCase: SetReadAccountTransactionsUseCase
    let dependenciesResolver: DependenciesResolver
    var subscriptions: Set<AnyCancellable> = []
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfig = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.pfmController = self.dependenciesResolver.resolve(for: PfmControllerProtocol.self)
        self.useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        self.setReadAccountTransactionsUseCase = self.dependenciesResolver.resolve(for: SetReadAccountTransactionsUseCase.self)
    }
    
    override func executeUseCase(requestValues: GetAccountTransactionsUseCaseInput) throws -> UseCaseResponse<GetAccountTransactionsUseCaseOkOutput, StringErrorOutput> {
        // Wait for the PFM
        wait(untilFinished: requestValues.account)
        let futureBill = self.getAccountFutureBills(requestValues)
        var transactionEntity: AccountTransactionListEntity?
        // Bill are not mandatory
        let transactionsDTO = try self.getAccountTransactions(requestValues)
        if transactionsDTO.isSuccess(), let data = try transactionsDTO.getResponseData() {
            transactionEntity = AccountTransactionListEntity(data)
        }
        if requestValues.filters !=  nil {
            let transactionsType = self.getTransactionsState(for: transactionEntity, requestValues: requestValues)
            // update Pfm With Read Account
            updatePfmWithReadAccount(requestValues.account)
            return .ok(GetAccountTransactionsUseCaseOkOutput(transactionsType: transactionsType, futureBillList: nil))
        }
        if transactionEntity == nil, futureBill == nil {
            // update Pfm With Read Account
            updatePfmWithReadAccount(requestValues.account)
            return .error(StringErrorOutput(nil))
        } else {
            let transactionsType = self.getTransactionsState(for: transactionEntity, requestValues: requestValues)
            
            // update Pfm With Read Account
            updatePfmWithReadAccount(requestValues.account)
            return .ok(GetAccountTransactionsUseCaseOkOutput(transactionsType: transactionsType, futureBillList: futureBill))
        }
    }
    
    private func getAccountTransactions(_ requestValues: GetAccountTransactionsUseCaseInput) throws -> BSANResponse<AccountTransactionsListDTO> {
        let accountsManager = provider.getBsanAccountsManager()
        if requestValues.filters == nil {
            return try accountsManager.getAccountTransactions(forAccount: requestValues.account.dto, pagination: requestValues.pagination?.dto, dateFilter: nil)
        } else {
            let filters = createFilters(from: requestValues)
            return try accountsManager
                .getAccountTransactions(forAccount: requestValues.account.dto, pagination: requestValues.pagination?.dto, filter: filters)
        }
    }
    
    private func getTransactionsState(for transactionEntity: AccountTransactionListEntity?,
                                      requestValues: GetAccountTransactionsUseCaseInput) -> GetAccountTransactionsState {

        guard let transactionEntity = transactionEntity,
            !transactionEntity.transactions.isEmpty else {
            return .noTransactions
        }
        return getAccountTransactionsState(for: transactionEntity, requestValues: requestValues)
    }
    
    private func getAccountTransactionsState(for transactionEntity: AccountTransactionListEntity,
                                             requestValues: GetAccountTransactionsUseCaseInput) -> GetAccountTransactionsState {
        guard let accountTransactionModifier = self.dependenciesResolver.resolve(forOptionalType: AccountTransactionsModifierProtocol.self) else {
            switch requestValues.scaState {
            case .notApply, .none:
                return .transactionsAfter90Days(transactionEntity)
            default:
                if transactionEntity.arePrior90Days() {
                    let beforeTransactions = transactionEntity.getLast90Days()
                    let afterTransactions = transactionEntity.getAfter90Days()
                    return .transactionsPrior90Days(before: beforeTransactions, after: afterTransactions)
                } else {
                    return .transactionsAfter90Days(transactionEntity)
                }
            }
        }
        let filtersIsShown = requestValues.filtersIsShown ?? true
        return accountTransactionModifier.getTransactionsState(for: transactionEntity, filtersIsShown: filtersIsShown)
    }
    
    struct Constans {
        static let numberOfElements = 3
        static let page = 0
    }
    
    private func getAccountFutureBills(_ requestValues: GetAccountTransactionsUseCaseInput) -> AccountFutureBillListRepresentable? {
        guard self.appConfig.getBool(AccountsConstants.isEnableAccountsHomeFutureBills) == true else { return nil }
        let globalPosition = self.dependenciesResolver.resolve(for: CoreFoundationLib.GlobalPositionRepresentable.self)
        _ = try? self.provider.getBsanPGManager().loadGlobalPositionV2(onlyVisibleProducts: true, isPB: globalPosition.isPb ?? false)
        do {
            let response = try self.provider.getBsanBillTaxesManager().loadFutureBills(account: requestValues.account.dto, status: "AUT", numberOfElements: Constans.numberOfElements, page: Constans.page)
            guard response.isSuccess() else { return nil }
            guard let data = try response.getResponseData() else { return nil }
            return data
        } catch {
            return nil
        }
    }
}

private extension SpainGetAccountTransactionsUseCase {
    func updatePfmWithReadAccount(_ selected: AccountEntity?) {
        guard let selectedAccount =  selected, self.pfmController.isPFMAccountReady(account: selectedAccount) else { return }
        let useCaseInput = SetReadAccountTransactionsUseCaseInput(account: selectedAccount)
        UseCaseWrapper(with:
                        self.setReadAccountTransactionsUseCase.setRequestValues(requestValues: useCaseInput),
                       useCaseHandler: self.useCaseHandler
        )
    }
    
    func dateRange(filter: TransactionFiltersEntity?) -> DateFilter {
        guard let dates = filter?.getDateRange() else {
            return self.getDefaultDateFilter()
        }
        return DateFilter(from: dates.fromDate, to: dates.toDate)
    }
    
    func getDefaultDateFilter() -> DateFilter {
        if let accountTransaction = self.dependenciesResolver.resolve(forOptionalType: AccountTransactionProtocol.self) {
            return DateFilter.getDateFilterFor(numberOfDays: accountTransaction.defaultNumberOfDateSearchFilter)
        } else {
            return DateFilter.getDateFilterFor(numberOfYears: -1)
        }
    }
    
    func fromAmountDTO(currency: CurrencyDTO?, filter: TransactionFiltersEntity?) -> AmountDTO? {
        guard let currency = currency, let amount = filter?.fromAmountDecimal else {
            return nil
        }
        return AmountDTO(value: amount, currency: currency)
    }
    
    func toAmountDTO(currency: CurrencyDTO?, filter: TransactionFiltersEntity?) -> AmountDTO? {
       guard let currency = currency, let amount = filter?.toAmountDecimal else {
           return nil
       }
       return AmountDTO(value: amount, currency: currency)
    }
    
    func transferType(filters: TransactionFiltersEntity?) -> TransferType {
       guard let transactionType = filters?.getTransactionOperationType() else {
           return .all
       }
       let transactionCode: String = convertToTransferType(transactionType).code
       return TransferType(rawValue: transactionCode) ?? .all
    }
    
    func movementType(filter: TransactionFiltersEntity?) -> MovementType {
        guard let movementCode = filter?.getMovementTypeCode() else {
            return .all
        }
        return MovementType(rawValue: movementCode) ?? .all
    }
    // [.all, .expenses, .incomes]
    func convertToTransferType(_ transactionType: TransactionOperationTypeEntity?) -> TransferType {
        switch transactionType {
        case .all?:
            return .all
        case .checkDeposit?:
            return .incomechecks
        case .checkPayment?:
            return .payChecks
        case .cashDeposit?:
            return .cashIncome
        case .cashPayment?:
            return .payIncome
        case .receivedTransfer?:
            return .transfersReceived
        case .issuedTransfer?:
            return .transfersIssued
        case .severalDocumentCharges?:
            return .chargeDocuments
        case .receiptsCharges?:
            return .chargeReceipts
        default:
            return .all
        }
    }
    
    func createFilters(from requestValues: GetAccountTransactionsUseCaseInput) -> AccountTransferFilterInput {
        let filter = AccountTransferFilterInput(
            endAmount: toAmountDTO(currency: requestValues.account.dto.currency, filter: requestValues.filters),
            startAmount: fromAmountDTO(currency: requestValues.account.dto.currency, filter: requestValues.filters),
            transferType: transferType(filters: requestValues.filters),
            movementType: movementType(filter: requestValues.filters),
              dateFilter: dateRange(filter: requestValues.filters) )
        return filter
    }
}
extension SpainGetAccountTransactionsUseCase: GetAccountTransactionsUseCaseProtocol, AccountPFMWaiter {}
