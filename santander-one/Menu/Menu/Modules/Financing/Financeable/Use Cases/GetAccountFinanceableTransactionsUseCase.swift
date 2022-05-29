import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class GetAccountFinanceableTransactionsUseCase: UseCase<GetAccountFinanceableTransactionsUseCaseInput, GetAccountFinanceableTransactionsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let bsanManagersProvider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let globalPosition: GlobalPositionRepresentable
    private let operationCode = "174"
    private let days = -60
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.bsanManagersProvider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
    }
    
    override func executeUseCase(requestValues: GetAccountFinanceableTransactionsUseCaseInput) throws -> UseCaseResponse<GetAccountFinanceableTransactionsUseCaseOkOutput, StringErrorOutput> {
        let isAccountEasyPayEnabled = self.appConfigRepository.getBool(AccountsConstants.appConfigEnableAccountEasyPayForBills) ?? false
        guard isAccountEasyPayEnabled else {
            return .error(StringErrorOutput(nil))
        }
        let startDate = Date().startOfDay().getUtcDate()?.addDay(days: self.days) ?? Date()
        let endDate = Date().getUtcDate() ?? Date()
        let params = AccountMovementListParams(
            fromDate: startDate,
            toDate: endDate,
            movementType: AccountMovementListParams.MovementType.debit,
            operationCode: [self.operationCode]
        )
        guard let response = try? self.bsanManagersProvider.getBsanAccountsManager().getAccountMovements(params: params, account: requestValues.account.dto.oldContract?.contratoPKWithNoSpaces ?? "") else {
            return .error(StringErrorOutput(nil))
        }
        guard response.isSuccess(), let data = try response.getResponseData() else {
            return .error(StringErrorOutput(nil))
        }
        let easyPayTransactions = data.movements.map({
            EasyPayTransactionFinanceable(
                movement: $0,
                offers: requestValues.offers,
                easyPay: requestValues.easyPayAccount)
        })
        var easyPayTransactionsFinanceables = easyPayTransactions.filter({ $0.isEasyPayEnabled })
        easyPayTransactionsFinanceables = easyPayTransactionsFinanceables.sorted(by: { $0.operationDate > $1.operationDate })
        
        return .ok(GetAccountFinanceableTransactionsUseCaseOkOutput(
            account: requestValues.account,
            transactions: easyPayTransactionsFinanceables)
        )
    }
}

extension GetAccountFinanceableTransactionsUseCase: AccountEasyPayChecker {}

struct GetAccountFinanceableTransactionsUseCaseInput {
    let account: AccountEntity
    let easyPayAccount: AccountEasyPay
    let offers: [PullOfferLocation: OfferEntity]
}

struct GetAccountFinanceableTransactionsUseCaseOkOutput {
    let account: AccountEntity
    let transactions: [EasyPayTransactionFinanceable]
}
