//
//  PFMMovementsUseCase.swift
//  Menu
//
//  Created by Boris Chirino Fernandez on 10/06/2020.
//

import CoreFoundationLib

final class GetAccountMonthTransactionsUseCase: UseCase<GetAccountsMonthAccountTransactionsInput, GetAccountsMonthTransactionsOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private var visibleAccountsAndHolder = [AccountEntity]()
    private lazy var pfmHelper: PfmHelperProtocol = {
        dependenciesResolver.resolve(for: PfmHelperProtocol.self)
    }()
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetAccountsMonthAccountTransactionsInput) throws -> UseCaseResponse<GetAccountsMonthTransactionsOkOutput, StringErrorOutput> {
        let globalPosition: GlobalPositionRepresentable = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        let merger = GlobalPositionPrefsMergerEntity(resolver: dependenciesResolver, globalPosition: globalPosition, saveUserPreferences: false)
        guard let userId = globalPosition.userCodeType else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        // extract IBAN of accounts wich are: visibles AND the current user is the Holder (titularRetail or titularPB)
        visibleAccountsAndHolder = merger.accounts.visibles()
            .filter({$0.isAccountHolder()})
        
        var queryDate = requestValues.date
        let today = Date()
        guard let startOfMonthDate = requestValues.date.startOfMonthLocalTime(), let daysUntilReachSCALimit = today.days(from: queryDate) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }

        if daysUntilReachSCALimit > 89 { // se esta pidiendo mas de 89 dias
            let beyondDays = daysUntilReachSCALimit - 89
            let adjustedDate = queryDate.addDay(days: beyondDays)
            queryDate = adjustedDate
        } else {
            queryDate = startOfMonthDate
        }
        
        guard let queryEndDate = queryDate.endOfMonthPfm() else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        var balanceTransactionsBucket: [BalanceTransactionEntity] = [BalanceTransactionEntity]()

        visibleAccountsAndHolder.forEach { (account) in
            let transactions = pfmHelper.getMovementsFor(userId: userId, account: account, startDate: queryDate, endDate: queryEndDate, includeInternalTransfers: true)
            let transactionsList = transactions.sorted(by: { ($0.operationDate ?? Date()).compare($1.operationDate ?? Date()) == .orderedDescending })
            if transactionsList.count > 0 {
                let balance = BalanceTransactionEntity(transactions: transactionsList, account: account)
                balanceTransactionsBucket.append(balance)
            }
        }
        return UseCaseResponse.ok(GetAccountsMonthTransactionsOkOutput(items: balanceTransactionsBucket))
    }
}

struct GetAccountsMonthAccountTransactionsInput {
    let date: Date
}

struct GetAccountsMonthTransactionsOkOutput {
    let items: [BalanceTransactionEntity]
}

public struct BalanceTransactionEntity {
    public let transactions: [AccountTransactionEntity]
    public let account: AccountEntity
}
