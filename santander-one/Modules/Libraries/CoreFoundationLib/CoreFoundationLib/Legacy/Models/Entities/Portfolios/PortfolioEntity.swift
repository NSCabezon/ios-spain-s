//
//  PortfolioEntity.swift
//  Models
//
//  Created by alvola on 14/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public final class PortfolioEntity {
    public let representable: PortfolioRepresentable
    public var isVisible: Bool = true
    public var productId: String = "Portfolio"
    
    public init(_ dto: PortfolioDTO) {
        self.representable = dto
    }
    
    // swiftlint:disable force_cast
    public var dto: PortfolioDTO {
        precondition((representable as? PortfolioDTO) != nil)
        return representable as! PortfolioDTO
    }
    // swiftlint:enable force_cast
    
    public init(_ representable: PortfolioRepresentable) {
        self.representable = representable
    }
    
    public var productIdentifier: String {
        return representable.contractRepresentable?.formattedValue ?? ""
    }
    
    public var alias: String? {
        return representable.alias?.camelCasedString
    }
    
    public var detailUI: String? {
        return representable.portfolioId?.trim()
    }
    
    public var amountUI: String? {
        guard let value = representable.consolidatedBalanceRepresentable?.value else { return nil }
        return String(describing: value)
    }
    
    public var shortContract: String {
        guard let contract = representable.portfolioId else { return "****" }
        return "*" + (contract.substring(contract.count - 4) ?? "*")
    }
    
    public var contract: String {
        return representable.portfolioId ?? ""
    }
}

extension PortfolioEntity: GlobalPositionProduct {}
