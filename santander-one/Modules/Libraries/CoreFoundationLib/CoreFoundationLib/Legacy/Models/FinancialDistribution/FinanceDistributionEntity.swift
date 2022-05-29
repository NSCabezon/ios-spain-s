//
//  FinanceDistributionEntity.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 03/09/2020.
//

import Foundation
import SANLegacyLibrary
 
public enum FinancialDistributionType {
    case personalLoans
    case creditCards
}

public  enum GroupIdentifier: String {
     case discounts
     case factoring
     case loans = "allLoans"
     case credits
     case leasing
     case renting
     case creditsCards = "credit_cards"
     case pasive = "pasivo"
     case accounts
     case funds
     case pensionPlans = "pension_plans"
     case deposits
     case portfolios = "managed_portfolios"
     case markets = "securities_market"
     case savindgsInsurance = "investment_savings_insurance"
     case ppaInsurance = "ppa_insurance"
     case incomesInsurance = "incomes_insurance"
     case unitLinkInsurance = "unit_link_insurance"
 }

/// represent Financial agregator
public class FinanceDistributionEntity {
    private var dto: FinancialAgregatorDTO
    public var items = [FinanceDistributionItemEntity]()
    public var groupCount: Int {
        dto.productGroups.count
    }
    
    public init(_ dto: FinancialAgregatorDTO) {
        self.dto = dto
        self.items = extractValuesFromDTO(dto)
    }
}

public struct FinanceDistributionItemEntity {
    public let value: Decimal
    public let financingType: FinancialDistributionType
    public init(value: Decimal, type: FinancialDistributionType) {
        self.value = value
        self.financingType = type
    }
}

private extension FinanceDistributionEntity {
    func extractValuesFromDTO(_ dto: FinancialAgregatorDTO) -> [FinanceDistributionItemEntity] {
        var items = [FinanceDistributionItemEntity]()
        
        let loans = sumValuesFromGroupWithIdentifier(.loans)
        let credits = sumValuesFromGroupWithIdentifier(.credits)
        let creditCards = sumValuesFromGroupWithIdentifier(.creditsCards)

        // loans section
        if credits != 0 || loans != 0 {
            items.append(FinanceDistributionItemEntity(value: Decimal(loans+credits), type: .personalLoans))
        }
        
        // credit cards section
        if creditCards != 0 {
            items.append(FinanceDistributionItemEntity(value: Decimal(creditCards), type: .creditCards))
        }
        return items
    }
    
    func sumValuesFromGroupWithIdentifier(_ groupIdentifier: GroupIdentifier) -> Double {
        return dto.productGroups
            .compactMap({$0.groups?.first(where: {$0.identifier == groupIdentifier.rawValue})})
            .flatMap({$0.aggregations})
            .reduce(0) { (result, dto) -> Double in
                result + dto.value.amount }
    }
}
