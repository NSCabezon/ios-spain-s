import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain
import Foundation

class AccounTransactionsListPdfUseCase: UseCase<AccounTransactionsListPdfUseCaseInput, AccounTransactionsListPdfUseCaseOkOutput, StringErrorOutput> {
    private let bsanManagersProvider: BSANManagersProvider
    
    init(bsanManagersProvider: BSANManagersProvider) {
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: AccounTransactionsListPdfUseCaseInput) throws -> UseCaseResponse<AccounTransactionsListPdfUseCaseOkOutput, StringErrorOutput> {
        let dto: AccountDTO = requestValues.account.accountDTO
        let dateFilter: DateFilter? = {
            guard requestValues.filters?.dateRange.dateFrom != nil, requestValues.filters?.dateRange.dateTo != nil else { return nil }
            return DateFilter(from: requestValues.filters?.dateRange.dateFrom, to: requestValues.filters?.dateRange.dateTo)
        }()
        if dateFilter?.toDateModel == nil {
            dateFilter?.toDateModel = DateModel(date: Date())
        }
        let isDateFilterNotNil: Bool = dateFilter != nil
        let transactionType: TransferType = convertToTransferType(requestValues.filters?.transactionType)
        let concept: MovementType = convertToConcept(requestValues.filters?.concept)
        let endAmountDTO: AmountDTO? = requestValues.filters?.amountTo.flatMap({ Decimal(string: $0) }).flatMap(Amount.createWith(value:))?.amountDTO
        let startAmountDTO: AmountDTO? = requestValues.filters?.amountFrom.flatMap({ Decimal(string: $0) }).flatMap(Amount.createWith(value:))?.amountDTO
        let filter: AccountTransferFilterInput? = dateFilter.map {
            return AccountTransferFilterInput(
                endAmount: endAmountDTO,
                startAmount: startAmountDTO,
                transferType: transactionType,
                movementType: concept,
                dateFilter: $0
            )
        }
        let transactions = try fetchTransactions(forAccount: dto, dateScaBloqued: requestValues.dateScaBloqued, isDateFilterNotNil: isDateFilterNotNil, filter: filter)
        return UseCaseResponse.ok(AccounTransactionsListPdfUseCaseOkOutput(transactions: transactions))
    }
    
    private func fetchTransactions(forAccount accountDTO: AccountDTO, dateScaBloqued: Date?, isDateFilterNotNil: Bool, filter: AccountTransferFilterInput?) throws -> [AccountTransaction] {
        let accountsManager = bsanManagersProvider.getBsanAccountsManager()
        var shouldAskForMoreTransactions: Bool = true
        var pagination: PaginationDTO?
        var transactions: [AccountTransaction] = []
        var response: BSANResponse<AccountTransactionsListDTO> = try {
            if let filter = filter {
                 return try accountsManager.getAccountTransactions(forAccount: accountDTO, pagination: pagination, filter: filter)
            } else {
                return try accountsManager.getAccountTransactions(forAccount: accountDTO, pagination: pagination, dateFilter: nil)
            }
        }()
        while response.isSuccess(), let list = try response.getResponseData(), shouldAskForMoreTransactions {
            pagination = list.pagination
            let transactionDTOs: [AccountTransactionDTO] = list.transactionDTOs
            let newTransactions: [AccountTransaction]
            if let dateScaBloqued: Date = dateScaBloqued, !isDateFilterNotNil {
                newTransactions = transactionDTOs.compactMap {
                    if let targetDate: Date = $0.operationDate, targetDate < dateScaBloqued {
                        return nil
                    } else {
                        return AccountTransaction($0)
                    }
                }
            } else {
                newTransactions = transactionDTOs.map { AccountTransaction($0) }
            }
            transactions.append(contentsOf: newTransactions)
            
            shouldAskForMoreTransactions = pagination?.endList == false && (isDateFilterNotNil || transactions.count <= 40) && newTransactions.count == transactionDTOs.count
            
            response = try {
                if let filter = filter {
                    return try accountsManager.getAccountTransactions(forAccount: accountDTO, pagination: pagination, filter: filter)
                } else {
                    return try accountsManager.getAccountTransactions(forAccount: accountDTO, pagination: pagination, dateFilter: nil)
                }
            }()
        }
        if !isDateFilterNotNil, transactions.count > 40 {
            transactions = [AccountTransaction](transactions[0...39])
        }
        return transactions
    }
    
    private func convertToTransferType(_ transactionType: TransactionOperationType?) -> TransferType {
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
    
    private func convertToConcept(_ transactionConcept: AccountConcept?) -> MovementType {
        switch transactionConcept {
        case .all?:
            return .all
        case .expense?:
            return .expenses
        case .income?:
            return .income
        default:
            return .all
        }
    }
}

struct AccounTransactionsListPdfUseCaseInput {
    let account: Account
    let filters: AccountSearchParameters?
    let dateScaBloqued: Date?
}

struct AccounTransactionsListPdfUseCaseOkOutput {
    let transactions: [AccountTransaction]
}
