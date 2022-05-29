//
//  FilterMassiveDirectDebitUseCase.swift
//  RetailLegacy
//
//  Created by Rubén Márquez Fernández on 19/8/21.
//

import CoreFoundationLib

class FilterMassiveDirectDebitUseCase: UseCase<FilterMassiveDirectDebitUseCaseInput, FilterMassiveDirectDebitUseCaseOkOutput, StringErrorOutput> {
    
    private let appConfigRepository: AppConfigRepository

    init(appConfigRepository: AppConfigRepository) {
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: FilterMassiveDirectDebitUseCaseInput) throws -> UseCaseResponse<FilterMassiveDirectDebitUseCaseOkOutput, StringErrorOutput> {
        var filteredAccounts: [Account] = requestValues.accounts
        let accountsToFilterValue: String = self.appConfigRepository.getAppConfigNode(nodeName: FilterMassiveDirectDebitUseCaseConstants.accountsExcludedInChargeAccountChange) ?? ""
        if let accountsToFilter: [[String: String]] = CodableParser<[[String: String]]>().serialize(accountsToFilterValue) {
            for accountToFilter in accountsToFilter {
                filteredAccounts = filteredAccounts.filter {
                    !($0.productType == accountToFilter[FilterMassiveDirectDebitUseCaseConstants.productType] &&
                        $0.productSubtype?.productSubtype == accountToFilter[FilterMassiveDirectDebitUseCaseConstants.productSubType])
                }
            }
        }
        return .ok(FilterMassiveDirectDebitUseCaseOkOutput(accounts: filteredAccounts))
    }
}

struct FilterMassiveDirectDebitUseCaseInput {
    let accounts: [Account]
}

struct FilterMassiveDirectDebitUseCaseOkOutput {
    let accounts: [Account]
}

enum FilterMassiveDirectDebitUseCaseConstants {
    public static let accountsExcludedInChargeAccountChange = "accountsExcludedInChargeAccountChange"
    public static let productType = "productType"
    public static let productSubType = "productSubType"
}
