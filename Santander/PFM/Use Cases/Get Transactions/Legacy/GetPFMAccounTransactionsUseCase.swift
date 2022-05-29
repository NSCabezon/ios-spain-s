//
//  GetPFMAccounTransactionsUseCase.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 1/2/22.
//

import Foundation
import CoreFoundationLib
import OpenCombine
import CoreDomain
import Account

final class GetAccountTransactionsPFMUseCase: UseCase<GetFilteredAccountTransactionsUseCaseInput, GetFilteredAccountTransactionsUseCaseOkOutput, StringErrorOutput> {
    
    let dependenciesResolver: DependenciesResolver
    var subscriptions: Set<AnyCancellable> = []
    
    private var pfmHelper: PfmHelperProtocol {
        return dependenciesResolver.resolve(for: PfmHelperProtocol.self)
    }
    private var globalPosition: GlobalPositionRepresentable {
        return dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: GetFilteredAccountTransactionsUseCaseInput) throws -> UseCaseResponse<GetFilteredAccountTransactionsUseCaseOkOutput, StringErrorOutput> {
        wait(untilFinished: requestValues.account)
        guard let userId = globalPosition.userCodeType else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let searchByTransactionDescription = requestValues.filters?.getTransactionDescription() ?? ""
        let dateInterval = requestValues.filters?.getDateRange()
        let fallbackDate = Date().getDateByAdding(days: -89, ignoreHours: true)
        let initialDate = dateInterval?.fromDate ?? fallbackDate
        let startDate = initialDate > fallbackDate ? initialDate : fallbackDate
        let transactions = pfmHelper.getMovementsFor(userId: userId, date: startDate, account: requestValues.account, searchText: searchByTransactionDescription, toDate: dateInterval?.toDate)
        let transactionList = AccountTransactionListEntity(transactions: transactions)
        if transactionList.transactions.count > 0 {
            return UseCaseResponse.ok(GetFilteredAccountTransactionsUseCaseOkOutput(transactionList: transactionList))
        } else {
            return UseCaseResponse.error(StringErrorOutput(localized("generic_label_emptyListResult")))
        }
    }
}

extension GetAccountTransactionsPFMUseCase: GetFilteredAccountTransactionsUseCaseProtocol, AccountPFMWaiter { }
